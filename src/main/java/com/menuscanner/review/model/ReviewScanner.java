package com.menuscanner.review.model;

import java.sql.Timestamp;
import java.util.Collections;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.Map;

/** A pre-printed Google review QR sticker (Product 2). */
public class ReviewScanner {

    private long      id;
    private String    code;
    private String    businessName;
    private String    ownerPhone;
    private String    googleReviewUrl;
    private String    instagramUrl;
    private String    facebookUrl;
    private String    youtubeUrl;
    private String    whatsappUrl;     // WhatsApp Channel link
    private Long      ownerId;
    private String    ownerName;       // the owner login's name, if set
    private String    loginPhone;      // the owner login's phone, if a login exists
    private boolean   active;
    private boolean   joinForm;        // show the "join" form (and so always the scan page)
    private Timestamp assignedAt;
    private Timestamp createdAt;

    // Scan counts since assignedAt — filled by ReviewScannerDAO.findAll()
    private int scansThisMonth;
    private int scansLastMonth;
    private int scansTotal;

    /** Number printed on the sticker, e.g. "#001". */
    public String getStickerNo() { return String.format("#%03d", id); }

    /**
     * Live-able: has a business and something to show, meaning at least one link, or the
     * join form (the owner may add links later, until then the page shows just the form).
     */
    public boolean isAssigned() {
        return businessName != null && !businessName.isBlank() && (joinForm || !getLinks().isEmpty());
    }

    /** Configured links only, in display order (Google first). */
    public Map<ReviewPlatform, String> getLinks() {
        Map<ReviewPlatform, String> links = new EnumMap<>(ReviewPlatform.class);
        for (ReviewPlatform p : ReviewPlatform.values()) {
            String url = getLink(p);
            if (url != null && !url.isBlank()) links.put(p, url);
        }
        return Collections.unmodifiableMap(links);
    }

    public int getLinkCount() { return getLinks().size(); }

    public String getLink(ReviewPlatform p) {
        return switch (p) {
            case GOOGLE    -> googleReviewUrl;
            case INSTAGRAM -> instagramUrl;
            case FACEBOOK  -> facebookUrl;
            case WHATSAPP  -> whatsappUrl;
            case YOUTUBE   -> youtubeUrl;
        };
    }

    public void setLink(ReviewPlatform p, String url) {
        switch (p) {
            case GOOGLE    -> googleReviewUrl = url;
            case INSTAGRAM -> instagramUrl    = url;
            case FACEBOOK  -> facebookUrl     = url;
            case WHATSAPP  -> whatsappUrl     = url;
            case YOUTUBE   -> youtubeUrl      = url;
        }
    }

    /** Keyed by lower-case platform name, for EL: ${s.linksByKey.instagram}. */
    public Map<String, String> getLinksByKey() {
        Map<String, String> m = new HashMap<>();
        for (ReviewPlatform p : ReviewPlatform.values()) {
            String url = getLink(p);
            m.put(p.getKey(), url == null ? "" : url);
        }
        return m;
    }

    public boolean isHasLogin() { return ownerId != null; }

    public long getId()                         { return id; }
    public void setId(long id)                  { this.id = id; }

    public String getCode()                     { return code; }
    public void setCode(String code)            { this.code = code; }

    public String getBusinessName()             { return businessName; }
    public void setBusinessName(String n)       { this.businessName = n; }

    public String getOwnerPhone()               { return ownerPhone; }
    public void setOwnerPhone(String p)         { this.ownerPhone = p; }

    public String getGoogleReviewUrl()          { return googleReviewUrl; }
    public void setGoogleReviewUrl(String u)    { this.googleReviewUrl = u; }

    public String getInstagramUrl()             { return instagramUrl; }
    public void setInstagramUrl(String u)       { this.instagramUrl = u; }

    public String getFacebookUrl()              { return facebookUrl; }
    public void setFacebookUrl(String u)        { this.facebookUrl = u; }

    public String getYoutubeUrl()               { return youtubeUrl; }
    public void setYoutubeUrl(String u)         { this.youtubeUrl = u; }

    public String getWhatsappUrl()              { return whatsappUrl; }
    public void setWhatsappUrl(String u)        { this.whatsappUrl = u; }

    public Long getOwnerId()                    { return ownerId; }
    public void setOwnerId(Long ownerId)        { this.ownerId = ownerId; }

    public String getOwnerName()                { return ownerName; }
    public void setOwnerName(String n)          { this.ownerName = n; }

    public String getLoginPhone()               { return loginPhone; }
    public void setLoginPhone(String p)         { this.loginPhone = p; }

    public boolean isActive()                   { return active; }
    public boolean isJoinForm()                 { return joinForm; }
    public void setJoinForm(boolean joinForm)   { this.joinForm = joinForm; }
    public void setActive(boolean active)       { this.active = active; }

    public Timestamp getAssignedAt()            { return assignedAt; }
    public void setAssignedAt(Timestamp t)      { this.assignedAt = t; }

    public Timestamp getCreatedAt()             { return createdAt; }
    public void setCreatedAt(Timestamp t)       { this.createdAt = t; }

    public int getScansThisMonth()              { return scansThisMonth; }
    public void setScansThisMonth(int n)        { this.scansThisMonth = n; }

    public int getScansLastMonth()              { return scansLastMonth; }
    public void setScansLastMonth(int n)        { this.scansLastMonth = n; }

    public int getScansTotal()                  { return scansTotal; }
    public void setScansTotal(int n)            { this.scansTotal = n; }
}
