package com.menuscanner.review.servlet;

import com.google.gson.Gson;
import com.menuscanner.review.ReviewConfig;
import com.menuscanner.review.RewardsState;
import com.menuscanner.review.dao.ReviewContactDAO;
import com.menuscanner.review.dao.ReviewRewardsDAO;
import com.menuscanner.review.dao.ReviewScannerDAO;
import com.menuscanner.review.model.ReviewContact;
import com.menuscanner.review.model.ReviewScanner;
import com.menuscanner.review.model.ReviewScratchCampaign;
import com.menuscanner.review.model.ReviewStampProgram;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * The customer's rewards page (public, whitelisted in AuthFilter as /rw/).
 * <pre>
 * GET  /rw/{code}          the page: verify on WhatsApp → details → stamp card / scratch card
 * POST /rw/{code}/verify   start a verification → {"token","waUrl"}
 * GET  /rw/{code}/status   has WhatsApp verified this browser's token yet? → {"verified","known","name"}
 * POST /rw/{code}/claim    details (+ bill, + location) → today's stamp and/or scratch result
 * POST /rw/{code}/forget   "Not you?": forget the remembered number on this phone
 * </pre>
 * A verified number is remembered on the device (signed cookie, 180 days), so regulars don't
 * verify every visit. ?preview=1 shows the page without WhatsApp and saves nothing.
 */
@WebServlet("/rw/*")
public class ReviewRewardsServlet extends HttpServlet {

    private static final Pattern PATH = Pattern.compile("^/([A-Za-z0-9]{4,12})(?:/(verify|status|claim|forget))?/?$");
    private static final int REMEMBER_DAYS = 180;
    private static final int MAX_VERIFY_STARTS = 8;          // per browser session
    private static final double NEAR_SHOP_METRES = 150;
    private static final int MAX_BILL = 1_000_000;
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final Gson GSON = new Gson();

    private final ReviewScannerDAO scannerDAO = new ReviewScannerDAO();
    private final ReviewRewardsDAO rewardsDAO = new ReviewRewardsDAO();
    private final ReviewContactDAO contactDAO = new ReviewContactDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setHeader("Cache-Control", "no-store");
        Matcher m = PATH.matcher(req.getPathInfo() == null ? "" : req.getPathInfo());
        if (!m.matches() || (m.group(2) != null && !"status".equals(m.group(2)))) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String code = m.group(1).toUpperCase();
        boolean preview = req.getParameter("preview") != null;
        try {
            ReviewScanner scanner = scannerDAO.findByCode(code);
            RewardsState rewards = RewardsState.load(scanner, rewardsDAO);
            if ("status".equals(m.group(2))) {
                status(req, resp, scanner);
                return;
            }
            if (!rewards.isAny()) {                       // switched off meanwhile: back to the normal page
                resp.sendRedirect(req.getContextPath() + "/s/" + code + (preview ? "?preview=1" : ""));
                return;
            }
            String phone = preview ? null : knownPhone(req, scanner);
            req.setAttribute("scanner",  scanner);
            req.setAttribute("rewards",  rewards);
            req.setAttribute("preview",  preview);
            req.setAttribute("base",     req.getContextPath() + "/rw/" + code);
            req.setAttribute("backUrl",  req.getContextPath() + "/s/" + code + (preview ? "?preview=1" : ""));
            if (phone != null) {
                req.setAttribute("phone", phone);
                req.setAttribute("phoneMasked", phone.substring(0, 2) + "XXXXX" + phone.substring(7));
                req.setAttribute("knownName", rewardsDAO.contactName(scanner, phone));
            }
            req.getRequestDispatcher("/WEB-INF/views/review/rewards.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Rewards page error for " + code, e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        Matcher m = PATH.matcher(req.getPathInfo() == null ? "" : req.getPathInfo());
        if (!m.matches() || m.group(2) == null || "status".equals(m.group(2))) {
            json(resp, 404, Map.of("error", "Not found."));
            return;
        }
        String code = m.group(1).toUpperCase();
        try {
            ReviewScanner scanner = scannerDAO.findByCode(code);
            RewardsState rewards = RewardsState.load(scanner, rewardsDAO);
            if (!rewards.isAny()) {
                json(resp, 404, Map.of("error", "Rewards are not available right now."));
                return;
            }
            switch (m.group(2)) {
                case "verify" -> startVerify(req, resp, scanner);
                case "claim"  -> claim(req, resp, scanner, rewards);
                case "forget" -> {
                    forget(req, resp, scanner);
                    json(resp, 200, Map.of("ok", true));
                }
                default -> json(resp, 404, Map.of("error", "Not found."));
            }
        } catch (SQLException e) {
            getServletContext().log("Rewards action error for " + code, e);
            json(resp, 500, Map.of("error", "Something went wrong. Please try again."));
        }
    }

    // ── Verification ────────────────────────────────────────────────────────

    private void startVerify(HttpServletRequest req, HttpServletResponse resp, ReviewScanner scanner)
            throws IOException, SQLException {
        HttpSession session = req.getSession(true);
        Integer starts = (Integer) session.getAttribute("rw.starts");
        if (starts != null && starts >= MAX_VERIFY_STARTS) {
            json(resp, 429, Map.of("error", "Too many tries. Please wait a while and open the page again."));
            return;
        }
        session.setAttribute("rw.starts", starts == null ? 1 : starts + 1);
        String token = rewardsDAO.createVerification(scanner.getId(), browserKey(session));
        session.setAttribute("rw.token." + scanner.getId(), token);
        String text = "VERIFY " + token + " (" + scanner.getBusinessName() + " rewards)";
        String waUrl = "https://wa.me/" + ReviewConfig.waNumber() + "?text="
                + URLEncoder.encode(text, StandardCharsets.UTF_8).replace("+", "%20");
        json(resp, 200, Map.of("token", token, "waUrl", waUrl));
    }

    private void status(HttpServletRequest req, HttpServletResponse resp, ReviewScanner scanner)
            throws IOException, SQLException {
        resp.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(false);
        String token = session == null || scanner == null ? null : (String) session.getAttribute("rw.token." + scanner.getId());
        String phone = token == null ? null : rewardsDAO.verifiedPhone(token, scanner.getId(), browserKey(session));
        if (phone == null) {
            json(resp, 200, Map.of("verified", false, "pending", token != null));
            return;
        }
        session.setAttribute("rw.phone." + scanner.getId(), phone);
        session.removeAttribute("rw.token." + scanner.getId());
        remember(req, resp, scanner, phone);
        String name = rewardsDAO.contactName(scanner, phone);
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("verified", true);
        out.put("known", name != null);
        if (name != null) out.put("name", firstName(name));
        out.put("phoneMasked", phone.substring(0, 2) + "XXXXX" + phone.substring(7));
        json(resp, 200, out);
    }

    // ── Claim ───────────────────────────────────────────────────────────────

    private void claim(HttpServletRequest req, HttpServletResponse resp, ReviewScanner scanner, RewardsState rewards)
            throws IOException, SQLException {
        boolean preview = req.getParameter("preview") != null;
        String phone = preview ? null : knownPhone(req, scanner);
        if (phone == null && !preview) {
            json(resp, 401, Map.of("error", "Please verify your number on WhatsApp first."));
            return;
        }

        Integer bill = null;
        if (rewards.isNeedBill()) {
            try {
                bill = Integer.valueOf(String.valueOf(req.getParameter("bill")).replaceAll("[^0-9]", ""));
            } catch (NumberFormatException ignored) {
                // handled below
            }
            if (bill == null || bill < 1 || bill > MAX_BILL) {
                json(resp, 400, Map.of("error", "Please enter your bill amount."));
                return;
            }
        }

        if (scanner.isGeoCheck() && !preview && !nearShop(req, scanner)) {
            json(resp, 403, Map.of("error", "Rewards are only for customers at " + scanner.getBusinessName()
                    + ". Please allow location and try again from the shop."));
            return;
        }

        String known = preview ? null : rewardsDAO.contactName(scanner, phone);
        String name = known;
        if (known == null) {
            ReviewContact c = details(req);
            if (c == null) {
                json(resp, 400, Map.of("error", "Please fill your name, age and gender."));
                return;
            }
            name = c.getName();
            if (!preview) {
                c.setScannerId(scanner.getId());
                c.setPhone(phone);
                c.setConsentWhatsapp(true);
                contactDAO.save(c);                         // they also join the VIP Club
            }
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("ok", true);
        out.put("name", firstName(name));
        if (preview) out.put("preview", true);

        if (rewards.isStampOn()) {
            ReviewStampProgram p = rewards.getStamp();
            ReviewStampProgram.Result r;
            if (preview) {
                r = new ReviewStampProgram.Result();
                r.setAdded(true);
                r.setCount(Math.min(3, p.getStampsNeeded()));
                r.setNeeded(p.getStampsNeeded());
                r.setReward(p.getReward());
            } else {
                r = rewardsDAO.collectStamp(scanner, p, phone);
            }
            Map<String, Object> s = new LinkedHashMap<>();
            s.put("added", r.isAdded());
            s.put("already", r.isAlready());
            s.put("count", r.getCount());
            s.put("needed", r.getNeeded());
            s.put("reward", r.getReward());
            s.put("complete", r.isComplete());
            out.put("stamp", s);
        }

        if (rewards.isScratchOn()) {
            ReviewScratchCampaign c = rewards.getScratch();
            ReviewScratchCampaign.Play play;
            if (preview) {
                play = new ReviewScratchCampaign.Play();
                play.setWon(true);
                play.setCode("PREVIEW");
                if (c.isAmountMode()) play.setAmount(c.getSlabs().isEmpty() ? 10 : c.getSlabs().get(0).getAmount());
                else play.setOfferText(c.getOffers().get(0));
            } else {
                play = rewardsDAO.play(scanner.getId(), c.getId(), phone, bill);
            }
            if (play != null) {
                Map<String, Object> s = new LinkedHashMap<>();
                s.put("already", play.isAlready());
                s.put("won", play.isWon());
                if (play.isWon()) {
                    s.put("prize", play.getPrizeText());
                    s.put("code", play.getCode());
                    s.put("redeemed", play.getRedeemedAt() != null);
                }
                out.put("scratch", s);
            }
        }
        json(resp, 200, out);
    }

    private static ReviewContact details(HttpServletRequest req) {
        String name = req.getParameter("name") == null ? "" : req.getParameter("name").trim().replaceAll("\\s+", " ");
        String gender = req.getParameter("gender");
        Integer age = null;
        try {
            age = Integer.valueOf(String.valueOf(req.getParameter("age")).trim());
        } catch (NumberFormatException ignored) {
            // handled below
        }
        if (name.length() < 2 || name.length() > 100 || age == null || age < 5 || age > 110
                || !("Male".equals(gender) || "Female".equals(gender) || "Other".equals(gender))) {
            return null;
        }
        ReviewContact c = new ReviewContact();
        c.setName(name);
        c.setAge(age);
        c.setGender(gender);
        return c;
    }

    /** Within ~150 m of the shop. The phone's own accuracy (up to 100 m) is given the benefit of the doubt. */
    private static boolean nearShop(HttpServletRequest req, ReviewScanner s) {
        if (s.getShopLat() == null || s.getShopLng() == null) return true;
        try {
            double lat = Double.parseDouble(req.getParameter("lat"));
            double lng = Double.parseDouble(req.getParameter("lng"));
            double acc = req.getParameter("acc") == null ? 0 : Double.parseDouble(req.getParameter("acc"));
            return distanceMetres(lat, lng, s.getShopLat(), s.getShopLng()) - Math.min(Math.max(acc, 0), 100) <= NEAR_SHOP_METRES;
        } catch (NumberFormatException | NullPointerException e) {
            return false;
        }
    }

    private static double distanceMetres(double lat1, double lng1, double lat2, double lng2) {
        double r = 6_371_000, dLat = Math.toRadians(lat2 - lat1), dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                 + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * r * Math.asin(Math.sqrt(a));
    }

    // ── Who is this? (session, then the signed cookie) ─────────────────────

    private String knownPhone(HttpServletRequest req, ReviewScanner scanner) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            String p = (String) session.getAttribute("rw.phone." + scanner.getId());
            if (p != null) return p;
        }
        if (req.getCookies() == null) return null;
        for (Cookie c : req.getCookies()) {
            if (!cookieName(scanner).equals(c.getName())) continue;
            String[] parts = c.getValue().split("\\.");
            if (parts.length != 3 || !parts[0].matches("[6-9]\\d{9}") || !parts[1].matches("\\d{1,7}")) return null;
            if (Long.parseLong(parts[1]) < LocalDate.now().toEpochDay()) return null;            // expired
            String expected = sign(parts[0] + "|" + scanner.getId() + "|" + parts[1]);
            if (!MessageDigest.isEqual(expected.getBytes(StandardCharsets.UTF_8), parts[2].getBytes(StandardCharsets.UTF_8))) return null;
            return parts[0];
        }
        return null;
    }

    private void remember(HttpServletRequest req, HttpServletResponse resp, ReviewScanner scanner, String phone) {
        long until = LocalDate.now().plusDays(REMEMBER_DAYS).toEpochDay();
        Cookie c = new Cookie(cookieName(scanner), phone + "." + until + "." + sign(phone + "|" + scanner.getId() + "|" + until));
        c.setPath(req.getContextPath() + "/rw/");
        c.setMaxAge(REMEMBER_DAYS * 24 * 3600);
        c.setHttpOnly(true);
        c.setSecure(req.isSecure());
        c.setAttribute("SameSite", "Lax");
        resp.addCookie(c);
    }

    private void forget(HttpServletRequest req, HttpServletResponse resp, ReviewScanner scanner) {
        HttpSession session = req.getSession(false);
        if (session != null) session.removeAttribute("rw.phone." + scanner.getId());
        Cookie c = new Cookie(cookieName(scanner), "");
        c.setPath(req.getContextPath() + "/rw/");
        c.setMaxAge(0);
        resp.addCookie(c);
    }

    private static String cookieName(ReviewScanner s) { return "rw" + s.getId(); }

    private static String sign(String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(ReviewConfig.rewardsSecret().getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return HexFormat.of().formatHex(mac.doFinal(data.getBytes(StandardCharsets.UTF_8))).substring(0, 32);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private static String browserKey(HttpSession session) {
        String k = (String) session.getAttribute("rw.key");
        if (k == null) {
            byte[] b = new byte[16];
            RANDOM.nextBytes(b);
            k = HexFormat.of().formatHex(b);
            session.setAttribute("rw.key", k);
        }
        return k;
    }

    private static String firstName(String name) {
        if (name == null) return null;
        String f = name.trim().split("\\s+")[0];
        return f.length() > 30 ? f.substring(0, 30) : f;
    }

    private static void json(HttpServletResponse resp, int status, Object body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(GSON.toJson(body));
    }
}
