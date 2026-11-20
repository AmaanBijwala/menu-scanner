package com.menuscanner.review.servlet;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.menuscanner.review.ReviewConfig;
import com.menuscanner.review.dao.ReviewRewardsDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.time.Duration;
import java.util.HexFormat;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * WhatsApp Cloud API webhook (public, whitelisted in AuthFilter as /wa/).
 *
 * GET  — Meta's one-time check when the webhook is set up: echoes hub.challenge if
 *        hub.verify_token matches review.wa.verifyToken.
 * POST — incoming messages. A customer on the rewards page sends "VERIFY K7P2QX" to our
 *        WhatsApp Business number; the sender's number (which WhatsApp vouches for) becomes the
 *        verified phone for that token. Every POST must carry Meta's X-Hub-Signature-256
 *        (HMAC-SHA256 of the body with the app secret), otherwise it is ignored.
 *
 * Always answers 200 quickly, as Meta retries anything else.
 */
@WebServlet("/wa/webhook")
public class WhatsAppWebhookServlet extends HttpServlet {

    private static final Pattern VERIFY_TEXT = Pattern.compile("(?i)\\bVERIFY\\s*([A-Z0-9]{6})\\b");
    private static final int MAX_BODY = 256 * 1024;

    private final ReviewRewardsDAO rewardsDAO = new ReviewRewardsDAO();
    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String token = ReviewConfig.waVerifyToken();
        if ("subscribe".equals(req.getParameter("hub.mode")) && !token.isEmpty()
                && MessageDigest.isEqual(token.getBytes(StandardCharsets.UTF_8),
                        String.valueOf(req.getParameter("hub.verify_token")).getBytes(StandardCharsets.UTF_8))) {
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().write(String.valueOf(req.getParameter("hub.challenge")));
            return;
        }
        resp.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        byte[] body = req.getInputStream().readNBytes(MAX_BODY);
        if (!signatureOk(body, req.getHeader("X-Hub-Signature-256"))) {
            getServletContext().log("WhatsApp webhook: bad or missing signature, ignored");
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        resp.setStatus(HttpServletResponse.SC_OK);
        try {
            JsonObject root = JsonParser.parseString(new String(body, StandardCharsets.UTF_8)).getAsJsonObject();
            for (JsonElement entry : array(root, "entry")) {
                for (JsonElement change : array(entry.getAsJsonObject(), "changes")) {
                    JsonObject value = change.getAsJsonObject().getAsJsonObject("value");
                    if (value == null) continue;
                    for (JsonElement m : array(value, "messages")) handleMessage(m.getAsJsonObject());
                }
            }
        } catch (RuntimeException e) {
            getServletContext().log("WhatsApp webhook: could not read payload", e);
        }
    }

    private void handleMessage(JsonObject msg) {
        if (!msg.has("from") || !"text".equals(str(msg, "type")) || !msg.has("text")) return;
        String from = msg.get("from").getAsString().replaceAll("\\D", "");
        String text = str(msg.getAsJsonObject("text"), "body");
        Matcher m = VERIFY_TEXT.matcher(text == null ? "" : text);
        if (!m.find()) return;
        // Indian mobiles only, the same rule as the VIP Club form
        if (!from.matches("91[6-9]\\d{9}")) {
            reply(from, "Sorry, rewards are for Indian (+91) mobile numbers only.");
            return;
        }
        String phone = from.substring(2);
        try {
            boolean ok = rewardsDAO.markVerified(m.group(1).toUpperCase(), phone);
            reply(from, ok
                    ? "✅ Verified! Go back to the page to continue."
                    : "This code has expired. Please open the page again and tap Verify.");
        } catch (SQLException e) {
            getServletContext().log("WhatsApp webhook: could not save verification", e);
        }
    }

    /** Optional "verified" reply. Needs review.wa.accessToken and review.wa.phoneNumberId; fire and forget. */
    private void reply(String to, String text) {
        String token = ReviewConfig.waAccessToken(), numberId = ReviewConfig.waPhoneNumberId();
        if (token.isEmpty() || !numberId.matches("\\d+")) return;
        JsonObject payload = new JsonObject();
        payload.addProperty("messaging_product", "whatsapp");
        payload.addProperty("to", to);
        payload.addProperty("type", "text");
        JsonObject t = new JsonObject();
        t.addProperty("body", text);
        payload.add("text", t);
        HttpRequest request = HttpRequest.newBuilder(URI.create("https://graph.facebook.com/v21.0/" + numberId + "/messages"))
                .timeout(Duration.ofSeconds(10))
                .header("Authorization", "Bearer " + token)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
                .build();
        http.sendAsync(request, HttpResponse.BodyHandlers.ofString()).thenAccept(r -> {
            if (r.statusCode() >= 300) getServletContext().log("WhatsApp reply failed: " + r.statusCode() + " " + r.body());
        });
    }

    private static boolean signatureOk(byte[] body, String header) {
        String secret = ReviewConfig.waAppSecret();
        if (secret.isEmpty() || header == null || !header.startsWith("sha256=")) return false;
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] expected = mac.doFinal(body);
            byte[] given = HexFormat.of().parseHex(header.substring(7));
            return MessageDigest.isEqual(expected, given);
        } catch (Exception e) {
            return false;
        }
    }

    private static JsonArray array(JsonObject o, String key) {
        return o != null && o.has(key) && o.get(key).isJsonArray() ? o.getAsJsonArray(key) : new JsonArray();
    }

    private static String str(JsonObject o, String key) {
        return o != null && o.has(key) && o.get(key).isJsonPrimitive() ? o.get(key).getAsString() : null;
    }
}
