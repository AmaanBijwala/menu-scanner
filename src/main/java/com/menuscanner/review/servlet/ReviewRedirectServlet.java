package com.menuscanner.review.servlet;

import com.menuscanner.review.ReviewConfig;
import com.menuscanner.review.dao.ReviewContactDAO;
import com.menuscanner.review.dao.ReviewScannerDAO;
import com.menuscanner.review.model.ReviewContact;
import com.menuscanner.review.model.ReviewOwner;
import com.menuscanner.review.model.ReviewPlatform;
import com.menuscanner.review.model.ReviewScanner;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.HexFormat;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Public landing for a review sticker.
 * <pre>
 * /s/{code}                 one link configured  → count the scan, 302 straight to it
 *                           two or more links    → count the scan, show the "choose an app" page
 *                           unassigned / paused  → info page (sales pitch for unassigned stickers)
 * /s/{code}/go/{platform}   from the choose page → count the trip to that app, 302 to it
 * POST /s/{code}/join       the "Join our VIP Club" form on the choose page → JSON
 * </pre>
 * With the join form switched on, the choose page is shown even for a single link.
 * Add ?preview=1 to see the page without counting (used by the owner dashboard).
 */
@WebServlet("/s/*")
public class ReviewRedirectServlet extends HttpServlet {

    /** /{code} or /{code}/go/{platform} */
    private static final Pattern PATH_PATTERN =
            Pattern.compile("^/([A-Za-z0-9]{4,12})/?(?:go/([a-z]{3,12})/?)?$");

    /** Link-preview fetchers and scripts — not real customers, so don't count them. */
    private static final Pattern BOT_UA = Pattern.compile(
            "(?i)bot|crawl|spider|slurp|preview|facebookexternalhit|whatsapp|telegram|skype|discord" +
            "|curl|wget|python|java/|okhttp|headless|lighthouse");

    private static final Pattern JOIN_PATH = Pattern.compile("^/([A-Za-z0-9]{4,12})/join/?$");

    private final ReviewScannerDAO scannerDAO = new ReviewScannerDAO();
    private final ReviewContactDAO contactDAO = new ReviewContactDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handle(req, resp, true);
    }

    /** HEAD requests (link checkers) get the same answer but are never counted. */
    @Override
    protected void doHead(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handle(req, resp, false);
    }

    private void handle(HttpServletRequest req, HttpServletResponse resp, boolean countScan)
            throws ServletException, IOException {
        Matcher m = PATH_PATTERN.matcher(req.getPathInfo() == null ? "" : req.getPathInfo());
        if (!m.matches()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String code         = m.group(1).toUpperCase();
        String platformKey  = m.group(2);

        ReviewScanner scanner;
        try {
            scanner = scannerDAO.findByCode(code);
        } catch (SQLException e) {
            getServletContext().log("Review scanner lookup failed", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
        if (scanner == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // The target can change at any time from the admin screen — never let browsers cache it
        resp.setHeader("Cache-Control", "no-store");

        if (scanner.isAssigned() && scanner.isActive()) {
            String ua = req.getHeader("User-Agent");
            boolean count = countScan && ua != null && !BOT_UA.matcher(ua).find()
                            && req.getParameter("preview") == null;
            String hash = count ? visitorHash(req.getRemoteAddr(), ua) : null;
            Map<ReviewPlatform, String> links = scanner.getLinks();

            if (platformKey != null) {                       // a button on the choose page
                ReviewPlatform p = ReviewPlatform.fromKey(platformKey);
                if (p == null || !links.containsKey(p)) {    // link removed since the page loaded
                    resp.sendRedirect(req.getContextPath() + "/s/" + code);
                    return;
                }
                if (count) scannerDAO.recordClick(scanner.getId(), p, hash);
                resp.sendRedirect(links.get(p));             // 302, not 301: 301 gets cached
                return;
            }

            if (count) scannerDAO.recordScan(scanner.getId(), hash);
            if (links.size() == 1 && !scanner.isJoinForm()) {   // nothing to choose — go straight there
                Map.Entry<ReviewPlatform, String> only = links.entrySet().iterator().next();
                if (count) scannerDAO.recordClick(scanner.getId(), only.getKey(), hash);
                resp.sendRedirect(only.getValue());
                return;
            }

            req.setAttribute("scanner",   scanner);
            req.setAttribute("links",     links.keySet());
            req.setAttribute("goBase",    req.getContextPath() + "/s/" + code + "/go/");
            req.setAttribute("preview",   req.getParameter("preview") != null);
            req.setAttribute("joinUrl",   req.getContextPath() + "/s/" + code + "/join");
            req.getRequestDispatcher("/WEB-INF/views/review/choose-app.jsp").forward(req, resp);
            return;
        }

        if (platformKey != null) {                           // paused/unassigned: show the normal page
            resp.sendRedirect(req.getContextPath() + "/s/" + code);
            return;
        }

        req.setAttribute("state",        scanner.isAssigned() ? "inactive" : "unassigned");
        req.setAttribute("stickerNo",    scanner.getStickerNo());
        req.setAttribute("contactPhone", ReviewConfig.contactPhone());
        req.setAttribute("contactName",  ReviewConfig.contactName());
        req.setAttribute("contactPhoneDisplay", ReviewConfig.contactPhoneDisplay());
        req.setAttribute("waText", URLEncoder.encode(
                "Hi, I scanned review QR " + scanner.getStickerNo() + " and I'm interested.", StandardCharsets.UTF_8)
                .replace("+", "%20"));   // wa.me expects %20, not form-style '+'
        req.getRequestDispatcher("/WEB-INF/views/review/scanner-info.jsp").forward(req, resp);
    }

    /** The "Join our VIP Club" form. Always answers JSON: {"ok":true} or {"error":"..."}. */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        Matcher m = JOIN_PATH.matcher(req.getPathInfo() == null ? "" : req.getPathInfo());
        if (!m.matches()) {
            jsonError(resp, HttpServletResponse.SC_NOT_FOUND, "Not found.");
            return;
        }
        // Honeypot: real people never see this field, bots fill everything
        if (req.getParameter("website") != null && !req.getParameter("website").isBlank()) {
            resp.getWriter().write("{\"ok\":true}");
            return;
        }

        String name   = req.getParameter("name") == null ? "" : req.getParameter("name").trim().replaceAll("\\s+", " ");
        String ageStr = req.getParameter("age");
        String gender = req.getParameter("gender");
        String phone  = ReviewOwner.normalizePhone(req.getParameter("phone") == null ? "" : req.getParameter("phone"));

        if (name.length() < 2 || name.length() > 100) {
            jsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Please enter your name.");
            return;
        }
        Integer age = null;
        try {
            age = Integer.valueOf(ageStr == null ? "" : ageStr.trim());
        } catch (NumberFormatException ignored) {
            // handled below
        }
        if (age == null || age < 5 || age > 110) {
            jsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Please enter a valid age.");
            return;
        }
        if (!"Male".equals(gender) && !"Female".equals(gender) && !"Other".equals(gender)) {
            jsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Please pick your gender.");
            return;
        }
        if (phone == null || !phone.matches("[6-9]\\d{9}")) {
            jsonError(resp, HttpServletResponse.SC_BAD_REQUEST, "Please enter a valid 10-digit mobile number.");
            return;
        }

        try {
            ReviewScanner scanner = scannerDAO.findByCode(m.group(1).toUpperCase());
            if (scanner == null || !scanner.isAssigned() || !scanner.isActive() || !scanner.isJoinForm()) {
                jsonError(resp, HttpServletResponse.SC_NOT_FOUND, "This form is not available right now.");
                return;
            }
            if (req.getParameter("preview") != null) {          // owner trying it out: don't store
                resp.getWriter().write("{\"ok\":true,\"preview\":true}");
                return;
            }
            ReviewContact c = new ReviewContact();
            c.setScannerId(scanner.getId());
            c.setName(name);
            c.setAge(age);
            c.setGender(gender);
            c.setPhone(phone);
            c.setConsentWhatsapp(true);
            boolean isNew = contactDAO.save(c);
            resp.getWriter().write("{\"ok\":true,\"already\":" + !isNew + "}");
        } catch (SQLException e) {
            getServletContext().log("Review join form save failed", e);
            jsonError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Something went wrong. Please try again.");
        }
    }

    private static void jsonError(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        resp.getWriter().write("{\"error\":\"" + message.replace("\"", "'") + "\"}");
    }

    /** One-way hash so we can de-duplicate repeat scans without storing IP addresses. */
    private static String visitorHash(String ip, String ua) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest((ip + "|" + ua).getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);   // SHA-256 is always available
        }
    }
}
