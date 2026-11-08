package com.menuscanner.landing;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/** Owner details shown on the public landing page. Edit here to update the page and the vCard. */
public final class LandingProfile {

    public static final String NAME          = "Amaan Bijwala";
    public static final String FULL_NAME     = "Amaan Ashraf Bijwala";
    public static final String TITLE         = "Java Developer";
    public static final String PHONE_E164    = "919029122928";          // digits only, with country code
    public static final String PHONE_DISPLAY = "+91 90291 22928";
    public static final String EMAIL         = "bijwalasolutions@gmail.com";
    public static final String CITY          = "Mumbai, India";

    // Personal profiles
    public static final String GITHUB        = "https://github.com/AmaanBijwala";
    public static final String LINKEDIN      = "https://www.linkedin.com/in/amaan-bijwala-836833213/";

    // Business brand and its social pages
    public static final String BRAND            = "Bijwala Solutions";
    public static final String INSTAGRAM        = "https://www.instagram.com/bijwalasolutions";
    public static final String FACEBOOK         = "https://www.facebook.com/profile.php?id=61595878950093";
    public static final String WHATSAPP_CHANNEL = "https://whatsapp.com/channel/0029Vb9LLAgKWEKnaRtY9X3T";

    /** Restaurant slug used for the live demo menu on the landing page. */
    public static final String DEMO_MENU_SLUG = "al-ayamna";
    public static final String DEMO_MENU_NAME = "Al Ayamna";

    /** app.base.url, e.g. https://dinestack.duckdns.org/menu-scanner */
    public static final String APP_BASE_URL;
    /** Public site root the landing page is served at, e.g. https://dinestack.duckdns.org/ */
    public static final String SITE_URL;

    static {
        Properties props = new Properties();
        try (InputStream is = LandingProfile.class.getClassLoader()
                .getResourceAsStream("application.properties")) {
            if (is != null) props.load(is);
        } catch (IOException ignored) {
            // defaults below
        }
        APP_BASE_URL = props.getProperty("app.base.url", "http://localhost:8080/menu-scanner");
        SITE_URL     = APP_BASE_URL.replaceFirst("^(https?://[^/]+).*$", "$1") + "/";
    }

    private LandingProfile() {}
}
