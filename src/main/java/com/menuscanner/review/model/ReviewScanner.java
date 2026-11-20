package com.menuscanner.review.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
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
    private boolean   stampAllowed;    // super admin switched on the digital stamp card
    private boolean   scratchAllowed;  // super admin switched on the scratch card
    private boolean   geoCheck;        // rewards only near the shop (shopLat/shopLng)
    private Double    shopLat;
    private Double    shopLng;
    private String    linkOrder;       // e.g. "INSTAGRAM,VIP,GOOGLE,WIFI"; null = default order
    private String    wifiName;        // guest WiFi shown on the scan page (null = no WiFi button)
    private String    wifiPassword;    // null/empty = open network
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
        return businessName != null && !businessName.isBlank() && (joinForm || isHasWifi() || !getLinks().isEmpty());
    }

    /** Configured links only, in the admin's display order (top of the scan page first). */
    public Map<ReviewPlatform, String> getLinks() {
        Map<ReviewPlatform, String> links = new LinkedHashMap<>();
        for (ReviewPlatform p : getPlatformOrder()) {
            String url = getLink(p);
            if (url != null && !url.isBlank()) links.put(p, url);
        }
        return Collections.unmodifiableMap(links);
    }

    /** Stand for the VIP Club form / rewards box and the guest WiFi button in link_order. */
    public static final String VIP  = "VIP";
    public static final String WIFI = "WIFI";

    /** Every platform in display order (VIP and WiFi left out). */
    public List<ReviewPlatform> getPlatformOrder() {
        return orderOf(linkOrder);
    }

    /**
     * Parses "INSTAGRAM,VIP,WIFI,GOOGLE" (any case; unknown or repeated names are skipped) into
     * the full order: every platform once plus VIP and WIFI. Platforms it does not mention go at
     * the end in the default order; a missing VIP goes on top (where it always was), a missing
     * WIFI at the very end.
     */
    public static List<String> orderNames(String order) {
        List<String> list = new ArrayList<>();
        if (order != null) {
            for (String part : order.split(",")) {
                String name = part.trim().toUpperCase(java.util.Locale.ROOT);
                boolean known = VIP.equals(name) || WIFI.equals(name) || ReviewPlatform.fromKey(name) != null;
                if (known && !list.contains(name)) list.add(name);
            }
        }
        if (!list.contains(VIP)) list.add(0, VIP);
        for (ReviewPlatform p : ReviewPlatform.values()) {
            if (!list.contains(p.name())) list.add(p.name());
        }
        if (!list.contains(WIFI)) list.add(WIFI);
        return list;
    }

    public static List<ReviewPlatform> orderOf(String order) {
        List<ReviewPlatform> list = new ArrayList<>();
        for (String name : orderNames(order)) {
            if (!VIP.equals(name) && !WIFI.equals(name)) list.add(ReviewPlatform.valueOf(name));
        }
        return list;
    }

    /**
     * What the scan page shows, top to bottom, as lower-case keys: "vip" (always listed, the
     * page decides whether the VIP form or the rewards box is on), each platform with a link,
     * and "wifi" when a WiFi name is set.
     */
    public List<String> getDisplayKeys() {
        List<String> keys = new ArrayList<>();
        for (String name : orderNames(linkOrder)) {
            boolean show = VIP.equals(name) ? true
                         : WIFI.equals(name) ? isHasWifi()
                         : notBlank(getLink(ReviewPlatform.valueOf(name)));
            if (show) keys.add(name.toLowerCase(java.util.Locale.ROOT));
        }
        return keys;
    }

    /** For EL: ${scanner.platformsByKey['google']}. */
    public Map<String, ReviewPlatform> getPlatformsByKey() {
        Map<String, ReviewPlatform> m = new HashMap<>();
        for (ReviewPlatform p : ReviewPlatform.values()) m.put(p.getKey(), p);
        return m;
    }

    /** "vip,google,instagram,...,wifi" for the admin form. */
    public String getLinkOrderKeys() {
        return String.join(",", orderNames(linkOrder)).toLowerCase(java.util.Locale.ROOT);
    }

    public boolean isHasWifi()                  { return notBlank(wifiName); }
    public String getWifiName()                 { return wifiName; }
    public void setWifiName(String n)           { this.wifiName = n; }
    public String getWifiPassword()             { return wifiPassword; }
    public void setWifiPassword(String p)       { this.wifiPassword = p; }

    private static boolean notBlank(String s)   { return s != null && !s.isBlank(); }

    public String getLinkOrder()                { return linkOrder; }
    public void setLinkOrder(String o)          { this.linkOrder = o; }

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

    public boolean isStampAllowed()             { return stampAllowed; }
    public void setStampAllowed(boolean v)      { this.stampAllowed = v; }
    public boolean isScratchAllowed()           { return scratchAllowed; }
    public void setScratchAllowed(boolean v)    { this.scratchAllowed = v; }
    public boolean isRewardsAllowed()           { return stampAllowed || scratchAllowed; }
    public boolean isGeoCheck()                 { return geoCheck; }
    public void setGeoCheck(boolean v)          { this.geoCheck = v; }
    public Double getShopLat()                  { return shopLat; }
    public void setShopLat(Double v)            { this.shopLat = v; }
    public Double getShopLng()                  { return shopLng; }
    public void setShopLng(Double v)            { this.shopLng = v; }

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
