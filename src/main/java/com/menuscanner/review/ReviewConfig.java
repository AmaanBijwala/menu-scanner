package com.menuscanner.review;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/** Product 2 settings read once from application.properties. */
public final class ReviewConfig {

    private static final String BASE_URL;
    private static final String CONTACT_PHONE;
    private static final String CONTACT_NAME;
    private static final String WA_NUMBER;
    private static final String WA_VERIFY_TOKEN;
    private static final String WA_APP_SECRET;
    private static final String WA_ACCESS_TOKEN;
    private static final String WA_PHONE_NUMBER_ID;
    private static final String REWARDS_SECRET;

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
        // WhatsApp Cloud API (Meta) for verifying customers' numbers on the rewards page.
        // review.wa.number: our WhatsApp Business number with country code, e.g. 919876543210
        WA_NUMBER          = props.getProperty("review.wa.number", "").replaceAll("\\D", "");
        WA_VERIFY_TOKEN    = props.getProperty("review.wa.verifyToken", "").trim();     // any string, typed into Meta's webhook setup
        WA_APP_SECRET      = props.getProperty("review.wa.appSecret", "").trim();       // Meta app secret: checks webhook signatures
        WA_ACCESS_TOKEN    = props.getProperty("review.wa.accessToken", "").trim();     // optional: to reply "verified"
        WA_PHONE_NUMBER_ID = props.getProperty("review.wa.phoneNumberId", "").trim();   // optional: to reply "verified"
        REWARDS_SECRET     = props.getProperty("review.rewards.secret", "").trim();     // signs the "remember this phone" cookie
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

    /** Base URL of the app, e.g. https://example.com/menu-scanner */
    public static String baseUrl() { return BASE_URL; }

    public static String waNumber()        { return WA_NUMBER; }
    public static String waVerifyToken()   { return WA_VERIFY_TOKEN; }
    public static String waAppSecret()     { return WA_APP_SECRET; }
    public static String waAccessToken()   { return WA_ACCESS_TOKEN; }
    public static String waPhoneNumberId() { return WA_PHONE_NUMBER_ID; }
    public static String rewardsSecret()   { return REWARDS_SECRET; }

    /** Rewards can only run once customers can verify their number on WhatsApp. */
    public static boolean waVerifyReady() {
        return WA_NUMBER.matches("\\d{10,15}") && !WA_APP_SECRET.isEmpty() && !REWARDS_SECRET.isEmpty();
    }

    private ReviewConfig() {}
}
