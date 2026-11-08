package com.menuscanner.review;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/** Product 2 settings read once from application.properties. */
public final class ReviewConfig {

    private static final String BASE_URL;
    private static final String CONTACT_PHONE;
    private static final String CONTACT_NAME;

    static {
        Properties props = new Properties();
        try (InputStream is = ReviewConfig.class.getClassLoader()
                .getResourceAsStream("application.properties")) {
            if (is != null) props.load(is);
        } catch (IOException ignored) {
            // fall back to defaults below
        }
        BASE_URL      = props.getProperty("app.base.url", "http://localhost:8080/menu-scanner");
        CONTACT_PHONE = props.getProperty("review.contact.phone", "").trim();
        CONTACT_NAME  = props.getProperty("review.contact.name", "").trim();
    }

    /** Full URL encoded inside a sticker's QR, e.g. https://example.com/menu-scanner/s/K7P2QX */
    public static String scanUrl(String code) { return BASE_URL + "/s/" + code; }

    /** Public page for an offer with a photo, e.g. https://example.com/menu-scanner/o/K7P2QX */
    public static String offerUrl(String code) { return BASE_URL + "/o/" + code; }

    /** Absolute URL of an uploaded image (WhatsApp needs a full URL for the preview). */
    public static String imageUrl(String relativePath) { return BASE_URL + "/images/" + relativePath; }

    /** Where owners log in to their dashboard, e.g. https://example.com/menu-scanner/review/login */
    public static String ownerLoginUrl() { return BASE_URL + "/review/login"; }

    /** Shown on the page of an unassigned/inactive sticker. Empty = hide the contact block. */
    public static String contactPhone() { return CONTACT_PHONE; }

    /** Human-friendly form, e.g. "+91 90291 22928" for an Indian number. */
    public static String contactPhoneDisplay() {
        if (CONTACT_PHONE.matches("91\\d{10}")) {
            return "+91 " + CONTACT_PHONE.substring(2, 7) + " " + CONTACT_PHONE.substring(7);
        }
        return CONTACT_PHONE.isEmpty() ? "" : "+" + CONTACT_PHONE;
    }
    public static String contactName()  { return CONTACT_NAME; }

    private ReviewConfig() {}
}
