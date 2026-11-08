package com.menuscanner.review.servlet;

import com.menuscanner.review.ReviewConfig;
import com.menuscanner.review.ReviewReportText;
import com.menuscanner.review.dao.ReviewOwnerDAO;
import com.menuscanner.review.dao.ReviewScannerDAO;
import com.menuscanner.review.model.ReviewMonthlyReport;
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
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;

/** Super-admin screen for Product 2: create, assign and report on Google review stickers. */
@WebServlet("/admin/review-scanners")
public class ReviewAdminServlet extends HttpServlet {

    private static final ZoneId IST = ZoneId.of("Asia/Kolkata");
    private static final DateTimeFormatter MONTH_LABEL = ReviewReportText.MONTH_LABEL;
    private static final int MAX_BATCH = 100;

    private final ReviewScannerDAO scannerDAO = new ReviewScannerDAO();
    private final ReviewOwnerDAO   ownerDAO   = new ReviewOwnerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        YearMonth month = parseMonth(req.getParameter("month"));
        try {
            List<ReviewScanner> scanners = scannerDAO.findAll();
            Map<Long, ReviewMonthlyReport> reports = scannerDAO.monthlyReports(month);

            Map<Long, String> reportTexts = new HashMap<>();
            Map<Long, Integer> monthScans = new HashMap<>();
            Map<Long, String>  scanUrls   = new HashMap<>();
            long assigned = 0, scansThisMonth = 0;
            for (ReviewScanner s : scanners) {
                ReviewMonthlyReport r = reports.get(s.getId());
                monthScans.put(s.getId(), r == null ? 0 : r.getTotalScans());
                scanUrls.put(s.getId(), ReviewConfig.scanUrl(s.getCode()));
                if (s.isAssigned()) {
                    assigned++;
                    reportTexts.put(s.getId(), buildReportText(s, month, r));
                }
                scansThisMonth += s.getScansThisMonth();
            }

            req.setAttribute("scanners",        scanners);
            req.setAttribute("reportTexts",     reportTexts);
            req.setAttribute("monthScans",      monthScans);
            req.setAttribute("scanUrls",        scanUrls);
            req.setAttribute("totalCount",      scanners.size());
            req.setAttribute("assignedCount",   assigned);
            req.setAttribute("unassignedCount", scanners.size() - assigned);
            req.setAttribute("scansThisMonth",  scansThisMonth);
            req.setAttribute("platforms",       ReviewPlatform.values());
            req.setAttribute("ownerLoginUrl",   ReviewConfig.ownerLoginUrl());
        } catch (SQLException e) {
            getServletContext().log("Review scanners load error", e);
            req.setAttribute("loadError", "Could not load scanners: " + e.getMessage());
        }
        req.setAttribute("month",      month.toString());          // yyyy-MM for <input type=month>
        req.setAttribute("monthLabel", month.format(MONTH_LABEL));
        req.getRequestDispatcher("/WEB-INF/views/review/admin-review-scanners.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action   = req.getParameter("action");
        String redirect = req.getContextPath() + "/admin/review-scanners";

        try {
            switch (action == null ? "" : action) {

                case "generate" -> {
                    int count = Integer.parseInt(req.getParameter("count"));
                    if (count < 1 || count > MAX_BATCH) {
                        resp.sendRedirect(redirect + "?error=" + encode("Enter a number between 1 and " + MAX_BATCH));
                        return;
                    }
                    List<Long> ids = scannerDAO.createBatch(count);
                    resp.sendRedirect(redirect + "?success=" + encode(ids.size() + " new scanner(s) created"));
                }

                case "assign" -> {
                    long id          = Long.parseLong(req.getParameter("id"));
                    String name      = trimToNull(req.getParameter("businessName"));
                    String rawPhone  = trimToNull(req.getParameter("ownerPhone"));
                    String password  = req.getParameter("loginPassword");
                    String ownerName = trimToNull(req.getParameter("ownerName"));
                    String sticker   = String.format("#%03d", id);
                    if (name == null) {
                        resp.sendRedirect(redirect + "?error=" + encode("Business name is required"));
                        return;
                    }
                    String phone = rawPhone == null ? null : ReviewOwner.normalizePhone(rawPhone);
                    if (rawPhone != null && phone == null) {
                        resp.sendRedirect(redirect + "?error=" + encode("Owner phone must be a 10-digit mobile number"));
                        return;
                    }

                    Map<ReviewPlatform, String> links = new EnumMap<>(ReviewPlatform.class);
                    for (ReviewPlatform p : ReviewPlatform.values()) {
                        try {
                            String url = p.normalize(req.getParameter(p.getKey()));
                            if (url != null) links.put(p, url);
                        } catch (IllegalArgumentException e) {
                            resp.sendRedirect(redirect + "?error=" + encode(e.getMessage()));
                            return;
                        }
                    }
                    boolean joinForm = req.getParameter("joinForm") != null;
                    if (links.isEmpty() && !joinForm) {
                        resp.sendRedirect(redirect + "?error=" + encode("Add at least one link (Google, Instagram, Facebook or YouTube), or switch on the VIP Club form"));
                        return;
                    }

                    boolean wantsLogin = password != null && !password.isBlank();
                    if (wantsLogin && phone == null) {
                        resp.sendRedirect(redirect + "?error=" + encode("Owner phone is needed to create a login — it's the username"));
                        return;
                    }
                    if (wantsLogin && password.length() < 6) {
                        resp.sendRedirect(redirect + "?error=" + encode("Login password must be at least 6 characters"));
                        return;
                    }

                    ReviewScanner before = scannerDAO.findById(id);
                    scannerDAO.assign(id, name, phone, links, joinForm);

                    String note = "";
                    if (wantsLogin) {
                        scannerDAO.setOwner(id, ownerDAO.upsert(phone, PasswordUtil.hash(password)));
                        note = ". Owner login: " + phone;
                    } else if (before != null && before.getOwnerId() != null
                               && !Objects.equals(before.getLoginPhone(), phone)) {
                        // Phone changed: move to that phone's existing login, or drop the old one
                        ReviewOwner other = phone == null ? null : ownerDAO.findByPhone(phone);
                        scannerDAO.setOwner(id, other == null ? null : other.getId());
                        note = other == null ? ". Owner login removed (phone changed) — set a password to create one" : "";
                    }
                    ReviewScanner after = scannerDAO.findById(id);
                    if (ownerName != null && after != null && after.getOwnerId() != null) {
                        ownerDAO.updateName(after.getOwnerId(), ownerName.length() > 100 ? ownerName.substring(0, 100) : ownerName);
                    }
                    resp.sendRedirect(redirect + "?success=" + encode("Scanner " + sticker + " saved" + note));
                }

                case "unassign" -> {
                    long id = Long.parseLong(req.getParameter("id"));
                    scannerDAO.unassign(id);
                    resp.sendRedirect(redirect + "?success=" + encode("Scanner " + String.format("#%03d", id) + " is free again"));
                }

                case "toggleActive" -> {
                    long id        = Long.parseLong(req.getParameter("id"));
                    boolean active = "true".equals(req.getParameter("active"));
                    scannerDAO.updateActive(id, active);
                    resp.sendRedirect(redirect + "?success=" + encode(active ? "Scanner activated" : "Scanner deactivated"));
                }

                default -> resp.sendRedirect(redirect);
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(redirect + "?error=Invalid+number");
        } catch (SQLException e) {
            getServletContext().log("Review scanner action error", e);
            resp.sendRedirect(redirect + "?error=" + encode(e.getMessage()));
        }
    }

    /** WhatsApp-ready monthly summary for the business owner. */
    private String buildReportText(ReviewScanner s, YearMonth month, ReviewMonthlyReport r) {
        return r == null
            ? ReviewReportText.build(s.getBusinessName(), s.getStickerNo(), month, 0, null, null, null)
            : ReviewReportText.build(s.getBusinessName(), s.getStickerNo(), month, r.getTotalScans(),
                                     r.getBusiestDay(), r.getBusiestTime(), r.getClicks());
    }

    private YearMonth parseMonth(String s) {
        try {
            if (s != null && !s.isBlank()) return YearMonth.parse(s);
        } catch (DateTimeParseException ignored) {
            // fall through to current month
        }
        return YearMonth.now(IST);
    }

    private String trimToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private String encode(String s) {
        return URLEncoder.encode(s == null ? "error" : s, StandardCharsets.UTF_8);
    }
}
