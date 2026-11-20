package com.menuscanner.review;

import com.menuscanner.review.dao.ReviewRewardsDAO;
import com.menuscanner.review.model.ReviewScanner;
import com.menuscanner.review.model.ReviewScratchCampaign;
import com.menuscanner.review.model.ReviewStampProgram;

import java.sql.SQLException;

/**
 * Which rewards a sticker's customers can get right now: the stamp card if the super admin
 * allowed it and the owner switched it on, the scratch card if allowed and a campaign is running.
 * Nothing is offered until WhatsApp verification is configured.
 */
public final class RewardsState {

    private final ReviewStampProgram    stamp;      // null = no stamp card
    private final ReviewScratchCampaign scratch;    // null = no scratch card

    private RewardsState(ReviewStampProgram stamp, ReviewScratchCampaign scratch) {
        this.stamp = stamp;
        this.scratch = scratch;
    }

    public static RewardsState none() { return new RewardsState(null, null); }

    public static RewardsState load(ReviewScanner s, ReviewRewardsDAO dao) throws SQLException {
        if (s == null || !s.isAssigned() || !s.isActive() || !s.isRewardsAllowed() || !ReviewConfig.waVerifyReady()) {
            return new RewardsState(null, null);
        }
        ReviewStampProgram p = s.isStampAllowed() ? dao.findProgram(s.getId()) : null;
        ReviewScratchCampaign c = s.isScratchAllowed() ? dao.activeCampaign(s.getId()) : null;
        if (c != null && !c.isAmountMode() && c.getOffers().isEmpty()) c = null;
        return new RewardsState(p != null && p.isActive() ? p : null, c);
    }

    public ReviewStampProgram getStamp()      { return stamp; }
    public ReviewScratchCampaign getScratch() { return scratch; }
    public boolean isStampOn()                { return stamp != null; }
    public boolean isScratchOn()              { return scratch != null; }
    public boolean isAny()                    { return stamp != null || scratch != null; }
    /** Amount-mode scratch cards ask for the bill, so a prize never exceeds what the slab allows. */
    public boolean isNeedBill()               { return scratch != null && scratch.isAmountMode(); }
}
