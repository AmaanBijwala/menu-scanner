package com.menuscanner.landing;

import jakarta.servlet.http.HttpServletRequest;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

/** Small helpers shared by the landing page's public form servlets. */
public final class LandingRequests {

    /** One-way hash of IP + User-Agent: enough to rate-limit a visitor without storing their IP. */
    public static String visitorHash(HttpServletRequest req) {
        String key = req.getRemoteAddr() + "|" + req.getHeader("User-Agent");
        try {
            byte[] h = MessageDigest.getInstance("SHA-256").digest(key.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(h);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);   // SHA-256 is always available
        }
    }

    /** Trimmed value cut to {@code max} chars, or null when blank. */
    public static String clip(String s, int max) {
        if (s == null || s.isBlank()) return null;
        s = s.trim();
        return s.length() > max ? s.substring(0, max) : s;
    }

    /** True when the request came from the page's fetch() call rather than a plain form post. */
    public static boolean isFetch(HttpServletRequest req) {
        return "fetch".equals(req.getHeader("X-Requested-With"));
    }

    private LandingRequests() {}
}
