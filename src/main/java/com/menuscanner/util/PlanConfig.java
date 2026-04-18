package com.menuscanner.util;

/**
 * Central plan enforcement rules and feature flags.
 *
 * To enable WhatsApp/SMS campaigns:
 *   1. Implement the sending service
 *   2. Set WHATSAPP_ENABLED = true  (or SMS_ENABLED = true)
 *   3. Redeploy — CampaignServlet will automatically start accepting POSTs
 */
public final class PlanConfig {

    // ── Plan identifiers ──────────────────────────────────────────────────
    public static final String PLAN_BASIC = "BASIC";
    public static final String PLAN_PRO   = "PRO";

    // ── Feature flags (flip when ready, no other code changes needed) ─────
    public static final boolean WHATSAPP_ENABLED = false;
    public static final boolean SMS_ENABLED       = false;

    // ── Plan limits ───────────────────────────────────────────────────────
    public static final int  BASIC_MAX_MENU_ITEMS      = 50;
    public static final int  PRO_MAX_MENU_ITEMS         = Integer.MAX_VALUE;

    public static final boolean BASIC_CAMPAIGNS_ENABLED  = false;
    public static final boolean PRO_CAMPAIGNS_ENABLED     = true;

    public static final boolean BASIC_ANALYTICS_ENABLED  = false;
    public static final boolean PRO_ANALYTICS_ENABLED     = true;

    // ── Helper methods ────────────────────────────────────────────────────

    public static int getMaxMenuItems(String planType) {
        return PLAN_PRO.equalsIgnoreCase(planType) ? PRO_MAX_MENU_ITEMS : BASIC_MAX_MENU_ITEMS;
    }

    /**
     * Campaigns are enabled only when:
     *   - restaurant is on PRO plan, AND
     *   - at least one channel feature flag is true
     */
    public static boolean isCampaignsEnabled(String planType) {
        return PLAN_PRO.equalsIgnoreCase(planType)
                && PRO_CAMPAIGNS_ENABLED
                && (WHATSAPP_ENABLED || SMS_ENABLED);
    }

    public static boolean isAnalyticsEnabled(String planType) {
        return PLAN_PRO.equalsIgnoreCase(planType) && PRO_ANALYTICS_ENABLED;
    }

    private PlanConfig() {}
}
