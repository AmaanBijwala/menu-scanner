package com.menuscanner.review.model;

import java.net.URI;
import java.util.Locale;
import java.util.Set;

/**
 * The apps a review sticker can send customers to. The declaration order is the order
 * they appear everywhere (choice page, dashboard, reports), with Google first.
 */
public enum ReviewPlatform {

    GOOGLE   ("Google",    "Rate us on Google",     Set.of("g.page", "goo.gl", "maps.app.goo.gl", "google.com", "google.co.in")),
    INSTAGRAM("Instagram", "Follow us on Instagram", Set.of("instagram.com", "instagr.am")),
    FACEBOOK ("Facebook",  "Like us on Facebook",    Set.of("facebook.com", "fb.com", "fb.me")),
    WHATSAPP ("WhatsApp Channel", "Join our WhatsApp Channel", Set.of("whatsapp.com", "wa.me")),
    YOUTUBE  ("YouTube",   "Subscribe on YouTube",   Set.of("youtube.com", "youtu.be"));

    private final String label;
    private final String callToAction;
    private final Set<String> hosts;

    ReviewPlatform(String label, String callToAction, Set<String> hosts) {
        this.label        = label;
        this.callToAction = callToAction;
        this.hosts        = hosts;
    }

    public String getLabel()        { return label; }
    public String getCallToAction() { return callToAction; }
    /** Lower-case name, used in URLs (/s/{code}/go/instagram) and form field names. */
    public String getKey()          { return name().toLowerCase(Locale.ROOT); }
    public String getName()         { return name(); }

    /** Case-insensitive lookup by {@link #getKey()}; null when unknown. */
    public static ReviewPlatform fromKey(String key) {
        if (key == null) return null;
        for (ReviewPlatform p : values()) {
            if (p.getKey().equalsIgnoreCase(key.trim())) return p;
        }
        return null;
    }

    /**
     * Cleans up what an owner pastes: adds a missing https://, and for Instagram turns
     * "@handle" or a bare handle into a profile URL.
     *
     * @return null for blank input (= link removed)
     * @throws IllegalArgumentException when the link doesn't belong to this platform
     */
    public String normalize(String input) {
        if (input == null || input.isBlank()) return null;
        String s = input.trim();

        if (this == INSTAGRAM && s.matches("@?[A-Za-z0-9._]{1,30}")) {
            return "https://www.instagram.com/" + s.replaceFirst("^@", "") + "/";
        }
        if (!s.matches("(?i)^https?://.*")) s = "https://" + s;
        if (s.length() > 500) throw new IllegalArgumentException(label + " link is too long");

        try {
            URI uri = new URI(s);
            String host = uri.getHost();
            if (host == null) throw new IllegalArgumentException("That doesn't look like your " + label + " link");
            host = host.toLowerCase(Locale.ROOT);
            for (String h : hosts) {
                if (host.equals(h) || host.endsWith("." + h)) {
                    return "https" + s.substring(s.indexOf(':'));   // always send customers over https
                }
            }
        } catch (java.net.URISyntaxException e) {
            // fall through
        }
        throw new IllegalArgumentException("That doesn't look like your " + label + " link");
    }
}
