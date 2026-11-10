package com.menuscanner.review.servlet;

import com.menuscanner.review.ReviewConfig;
import com.menuscanner.review.ReviewReportText;
import com.menuscanner.review.dao.ReviewBroadcastDAO;
import com.menuscanner.review.dao.ReviewContactDAO;
import com.menuscanner.review.dao.ReviewOwnerDAO;
import com.menuscanner.review.dao.ReviewScannerDAO;
import com.menuscanner.review.filter.ReviewOwnerAuthFilter;
import com.menuscanner.review.model.ReviewAnalytics;
import com.menuscanner.review.model.ReviewBroadcast;
import com.menuscanner.review.model.ReviewContact;
import com.menuscanner.review.model.ReviewOwner;
import com.menuscanner.review.model.ReviewPlatform;
import com.menuscanner.review.model.ReviewScanner;
import com.menuscanner.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * The business owner's dashboard for their review stickers.
 * Tabs: "analytics" (scans, where customers went, busiest times, report) and
 * "customers" (people who joined the VIP Club form, CSV download) and
 * "links" (Google / Instagram / Facebook / YouTube links, password).
 */
@WebServlet("/review/dashboard")
public class ReviewOwnerDashboardServlet extends HttpServlet {

    private static final ZoneId IST = ZoneId.of("Asia/Kolkata");
    private static final int MIN_PASSWORD = 6;
    private static final int MAX_MESSAGE = 1000;
    private static final int HISTORY_LIMIT = 20;

    private final ReviewScannerDAO   scannerDAO   = new ReviewScannerDAO();
    private final ReviewOwnerDAO     ownerDAO     = new ReviewOwnerDAO();
    private final ReviewContactDAO   contactDAO   = new ReviewContactDAO();
    private final ReviewBroadcastDAO broadcastDAO = new ReviewBroadcastDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long ownerId = ownerId(req);
        String firstName = null;
        List<ReviewScanner> scanners = List.of();
        try {
            ReviewOwner me = ownerDAO.findById(ownerId);
            if (me != null) firstName = me.getFirstName();
            scanners = scannerDAO.findByOwner(ownerId);
        } catch (SQLException e) {
            getServletContext().log("Review owner dashboard error", e);
            req.setAttribute("loadError", "Could not load your data. Please refresh in a minute.");
        }
        render(req, resp, scanners, firstName);
    }

    /**
     * Loads the chosen sticker's tab and shows the dashboard. Shared with the super admin's
     * read-only view ({@link ReviewAdminDashboardServlet}), which passes every assigned sticker.
     */
    protected void render(HttpServletRequest req, HttpServletResponse resp,
                          List<ReviewScanner> scanners, String firstName)
            throws ServletException, IOException {
        String tabParam = req.getParameter("tab");
        String tab = "links".equals(tabParam) || "customers".equals(tabParam) ? tabParam : "analytics";
        YearMonth month = parseMonth(req.getParameter("month"));

        try {
            if (firstName != null) req.setAttribute("ownerFirstName", firstName);
            req.setAttribute("scanners", scanners);
            ReviewScanner current = pick(scanners, req.getParameter("scanner"));

            if (current != null) {
                req.setAttribute("current", current);
                req.setAttribute("previewUrl", ReviewConfig.scanUrl(current.getCode()) + "?preview=1");

                if ("customers".equals(tab)) {
                    List<ReviewContact> contacts = contactDAO.findForScanner(current);
                    if ("csv".equals(req.getParameter("export"))) {
                        writeCsv(resp, current, contacts, Boolean.TRUE.equals(req.getAttribute("adminView")));
                        return;
                    }
                    req.setAttribute("contacts", contacts);
                    req.setAttribute("broadcasts", broadcastDAO.findRecent(current, HISTORY_LIMIT));
                }

                if ("analytics".equals(tab)) {
                    ReviewAnalytics a = scannerDAO.analytics(current, month);
                    req.setAttribute("a", a);
                    Map<ReviewPlatform, Integer> clicks = new EnumMap<>(ReviewPlatform.class);
                    a.getApps().forEach(r -> clicks.put(r.getPlatform(), r.getValue()));
                    String report = ReviewReportText.build(current.getBusinessName(), current.getStickerNo(), month,
                            a.getTotalScans(), a.getBusiestDay(), a.getBusiestTime(), clicks);
                    req.setAttribute("reportText", report);
                    req.setAttribute("reportWa", "https://wa.me/?text=" +
                            URLEncoder.encode(report, StandardCharsets.UTF_8).replace("+", "%20"));
                }
            }
        } catch (SQLException e) {
            getServletContext().log("Review owner dashboard error", e);
            req.setAttribute("loadError", "Could not load your data. Please refresh in a minute.");
        }

        YearMonth now = YearMonth.now(IST);
        req.setAttribute("tab",        tab);
        req.setAttribute("platforms",  ReviewPlatform.values());
        req.setAttribute("month",      month.toString());
        req.setAttribute("monthLabel", month.format(ReviewReportText.MONTH_LABEL));
        req.setAttribute("prevMonth",  month.minusMonths(1).toString());
        req.setAttribute("nextMonth",  month.isBefore(now) ? month.plusMonths(1).toString() : null);
        req.setAttribute("isCurrentMonth", month.equals(now));
        req.getRequestDispatcher("/WEB-INF/views/review/owner-dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long ownerId = ownerId(req);
        String action  = req.getParameter("action");
        String scanner = req.getParameter("scanner");
        String back = req.getContextPath() + "/review/dashboard?tab=links"
                    + (scanner != null && scanner.matches("\\d+") ? "&scanner=" + scanner : "");

        try {
            // Offer history: called from the page's JavaScript, answers JSON
            if ("startBroadcast".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                String message = req.getParameter("message") == null ? "" : req.getParameter("message").trim();
                String[] raw = req.getParameterValues("phone");
                List<String> phones = new ArrayList<>();
                if (raw != null) for (String p : raw) if (p != null && p.matches("\\d{10}")) phones.add(p);
                ReviewScanner target = pick(scannerDAO.findByOwner(ownerId), scanner);
                if (message.isEmpty() || message.length() > MAX_MESSAGE || phones.isEmpty()
                        || target == null || !String.valueOf(target.getId()).equals(scanner)) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    resp.getWriter().write("{\"ok\":false}");
                    return;
                }
                String image = req.getParameter("image");
                if (image != null && image.isBlank()) image = null;
                if (image != null && !ReviewOfferImageServlet.isOfferImagePath(image, target.getId())) {
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    resp.getWriter().write("{\"ok\":false}");
                    return;
                }
                ReviewBroadcast saved = broadcastDAO.create(target, message, image, phones);
                if (saved == null) {
                    resp.getWriter().write("{\"ok\":false}");
                } else {
                    resp.getWriter().write("{\"ok\":true,\"id\":" + saved.getId()
                            + (saved.getOfferUrl() == null ? "" : ",\"link\":\"" + saved.getOfferUrl() + "\"") + "}");
                }
                return;
            }
            if ("markSent".equals(action)) {
                resp.setContentType("application/json;charset=UTF-8");
                boolean ok = broadcastDAO.markSent(Long.parseLong(req.getParameter("broadcast")),
                                                   String.valueOf(req.getParameter("phone")), ownerId);
                resp.getWriter().write("{\"ok\":" + ok + "}");
                return;
            }

            if ("addContact".equals(action)) {
                String vipBack = back.replace("tab=links", "tab=customers");
                String name  = req.getParameter("name") == null ? "" : req.getParameter("name").trim().replaceAll("\\s+", " ");
                String phone = ReviewOwner.normalizePhone(req.getParameter("phone") == null ? "" : req.getParameter("phone"));
                if (name.length() < 2 || name.length() > 100) {
                    resp.sendRedirect(vipBack + "&vipError=" + encode("Please enter the customer's name."));
                    return;
                }
                if (phone == null || !phone.matches("[6-9]\\d{9}")) {
                    resp.sendRedirect(vipBack + "&vipError=" + encode("Please enter a valid 10-digit mobile number."));
                    return;
                }
                ReviewScanner target = pick(scannerDAO.findByOwner(ownerId), scanner);
                if (target == null || !String.valueOf(target.getId()).equals(scanner)) {
                    resp.sendRedirect(vipBack + "&vipError=" + encode("That sticker isn't linked to your account."));
                    return;
                }
                boolean added = contactDAO.addByOwner(target.getId(), name, phone);
                resp.sendRedirect(vipBack + (added ? "&vipAdded=1" : "&vipError=" + encode("+91 " + phone + " is already in your VIP Club.")));
                return;
            }

            if ("saveLinks".equals(action)) {
                long id = Long.parseLong(scanner);
                Map<ReviewPlatform, String> links = new EnumMap<>(ReviewPlatform.class);
                for (ReviewPlatform p : ReviewPlatform.values()) {
                    try {
                        String url = p.normalize(req.getParameter(p.getKey()));
                        if (url != null) links.put(p, url);
                    } catch (IllegalArgumentException e) {
                        resp.sendRedirect(back + "&error=" + encode(e.getMessage()));
                        return;
                    }
                }
                ReviewScanner target = scannerDAO.findById(id);
                if (links.isEmpty() && (target == null || !target.isJoinForm())) {
                    resp.sendRedirect(back + "&error=" + encode("Keep at least one link, otherwise the QR has nowhere to go."));
                    return;
                }
                boolean ok = scannerDAO.updateLinksForOwner(id, ownerId, links);
                resp.sendRedirect(back + (ok ? "&saved=1" : "&error=" + encode("That sticker isn't linked to your account.")));
                return;
            }

            if ("changePassword".equals(action)) {
                String current = req.getParameter("currentPassword");
                String next    = req.getParameter("newPassword");
                String confirm = req.getParameter("confirmPassword");
                ReviewOwner owner = ownerDAO.findById(ownerId);
                if (owner == null || current == null || !PasswordUtil.verify(current, owner.getPasswordHash())) {
                    resp.sendRedirect(back + "&pwError=" + encode("Current password is wrong."));
                } else if (next == null || next.length() < MIN_PASSWORD) {
                    resp.sendRedirect(back + "&pwError=" + encode("New password must be at least " + MIN_PASSWORD + " characters."));
                } else if (!next.equals(confirm)) {
                    resp.sendRedirect(back + "&pwError=" + encode("The two new passwords don't match."));
                } else {
                    ownerDAO.updatePassword(ownerId, PasswordUtil.hash(next));
                    resp.sendRedirect(back + "&pwSaved=1");
                }
                return;
            }
            resp.sendRedirect(back);
        } catch (NumberFormatException e) {
            resp.sendRedirect(back + "&error=" + encode("Please pick a sticker."));
        } catch (SQLException e) {
            getServletContext().log("Review owner dashboard save error", e);
            resp.sendRedirect(back + "&error=" + encode("Could not save. Please try again."));
        }
    }

    /** Excel-friendly CSV of the VIP Club list (UTF-8 with BOM so names in any script open correctly). */
    /** maskPhones: the super admin's copy shows only the first 6 digits (98765XXXX style). */
    private static void writeCsv(HttpServletResponse resp, ReviewScanner scanner, List<ReviewContact> contacts,
                                 boolean maskPhones)
            throws IOException {
        String file = scanner.getBusinessName().replaceAll("[^A-Za-z0-9]+", "-").replaceAll("^-|-$", "") + "-vip-club.csv";
        resp.setContentType("text/csv;charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + file + "\"");
        var out = resp.getWriter();
        out.write('\uFEFF');
        out.write("Name,Age,Gender,Mobile,Joined on\r\n");
        var fmt = java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a", java.util.Locale.ENGLISH);
        for (ReviewContact c : contacts) {
            out.write(csv(c.getName()) + "," + (c.getAge() == null ? "" : c.getAge()) + "," + csv(c.getGender()) + ","
                    + "+91" + (maskPhones ? maskPhone(c.getPhone()) : c.getPhone()) + "," + csv(c.getCreatedAt().toLocalDateTime().format(fmt)) + "\r\n");
        }
    }

    private static String maskPhone(String phone) {
        return phone == null || phone.length() <= 4 ? "XXXX" : phone.substring(0, phone.length() - 4) + "XXXX";
    }

    private static String csv(String v) {
        if (v == null) return "";
        if (!v.isEmpty() && "=+-@".indexOf(v.charAt(0)) >= 0) v = "'" + v;   // no formulas when opened in Excel
        return "\"" + v.replace("\"", "\"\"") + "\"";
    }

    private static long ownerId(HttpServletRequest req) {
        return (Long) req.getSession().getAttribute(ReviewOwnerAuthFilter.SESSION_OWNER_ID);
    }

    /** The sticker asked for (only if it belongs to this owner), else the first one. */
    private static ReviewScanner pick(List<ReviewScanner> scanners, String id) {
        if (scanners.isEmpty()) return null;
        if (id != null) {
            for (ReviewScanner s : scanners) if (String.valueOf(s.getId()).equals(id)) return s;
        }
        return scanners.get(0);
    }

    private static YearMonth parseMonth(String s) {
        YearMonth now = YearMonth.now(IST);
        try {
            if (s != null && !s.isBlank()) {
                YearMonth m = YearMonth.parse(s);
                return m.isAfter(now) ? now : m;
            }
        } catch (DateTimeParseException ignored) {
            // fall through to current month
        }
        return now;
    }

    private static String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}
