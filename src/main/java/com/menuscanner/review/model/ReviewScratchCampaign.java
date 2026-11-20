package com.menuscanner.review.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * A scratch-card campaign. AMOUNT mode gives money off from a fixed set of slabs
 * (e.g. ₹10 × 20, ₹50 × 2 with a minimum bill each) until they run out; OFFER mode shows
 * one of the owner's offer texts on every scratch.
 */
public class ReviewScratchCampaign {

    public static final String AMOUNT = "AMOUNT";
    public static final String OFFER  = "OFFER";
    public static final int DEFAULT_WIN_PERCENT = 40;

    private long        id;
    private long        scannerId;
    private String      mode;
    private int         winPercent;
    private boolean     active;
    private Timestamp   createdAt;
    private List<Slab>   slabs  = new ArrayList<>();
    private List<String> offers = new ArrayList<>();

    public boolean isAmountMode()            { return AMOUNT.equals(mode); }

    /** Total money the campaign started with. */
    public int getBudgetTotal() {
        int t = 0;
        for (Slab s : slabs) t += s.amount * s.totalCount;
        return t;
    }

    /** Money still left to win. */
    public int getBudgetLeft() {
        int t = 0;
        for (Slab s : slabs) t += s.amount * s.remaining;
        return t;
    }

    public boolean isUsedUp() { return isAmountMode() && getBudgetLeft() == 0; }

    public long getId()                      { return id; }
    public void setId(long v)                { this.id = v; }
    public long getScannerId()               { return scannerId; }
    public void setScannerId(long v)         { this.scannerId = v; }
    public String getMode()                  { return mode; }
    public void setMode(String v)            { this.mode = v; }
    public int getWinPercent()               { return winPercent; }
    public void setWinPercent(int v)         { this.winPercent = v; }
    public boolean isActive()                { return active; }
    public void setActive(boolean v)         { this.active = v; }
    public Timestamp getCreatedAt()          { return createdAt; }
    public void setCreatedAt(Timestamp v)    { this.createdAt = v; }
    public List<Slab> getSlabs()             { return slabs; }
    public List<String> getOffers()          { return offers; }

    /** "₹50 off × 2, min bill ₹500" */
    public static class Slab {
        private long id;
        private int  amount;
        private int  minBill;
        private int  totalCount;
        private int  remaining;

        public Slab() {}
        public Slab(int amount, int minBill, int count) {
            this.amount = amount; this.minBill = minBill; this.totalCount = count; this.remaining = count;
        }

        public long getId()                  { return id; }
        public void setId(long v)            { this.id = v; }
        public int getAmount()               { return amount; }
        public void setAmount(int v)         { this.amount = v; }
        public int getMinBill()              { return minBill; }
        public void setMinBill(int v)        { this.minBill = v; }
        public int getTotalCount()           { return totalCount; }
        public void setTotalCount(int v)     { this.totalCount = v; }
        public int getRemaining()            { return remaining; }
        public void setRemaining(int v)      { this.remaining = v; }
    }

    /** One customer's scratch on one day. */
    public static class Play {
        private long      id;
        private String    phone;
        private String    name;
        private Integer   billAmount;
        private boolean   won;
        private Integer   amount;
        private String    offerText;
        private String    code;
        private Timestamp redeemedAt;
        private Timestamp createdAt;
        private boolean   already;     // customer had scratched today already (same result shown again)

        /** What the card says under the scratch layer. */
        public String getPrizeText() {
            if (!won) return null;
            return amount != null ? "₹" + amount + " off" : offerText;
        }

        public long getId()                  { return id; }
        public void setId(long v)            { this.id = v; }
        public String getPhone()             { return phone; }
        public void setPhone(String v)       { this.phone = v; }
        public String getName()              { return name; }
        public void setName(String v)        { this.name = v; }
        public Integer getBillAmount()       { return billAmount; }
        public void setBillAmount(Integer v) { this.billAmount = v; }
        public boolean isWon()               { return won; }
        public void setWon(boolean v)        { this.won = v; }
        public Integer getAmount()           { return amount; }
        public void setAmount(Integer v)     { this.amount = v; }
        public String getOfferText()         { return offerText; }
        public void setOfferText(String v)   { this.offerText = v; }
        public String getCode()              { return code; }
        public void setCode(String v)        { this.code = v; }
        public Timestamp getRedeemedAt()     { return redeemedAt; }
        public void setRedeemedAt(Timestamp v) { this.redeemedAt = v; }
        public Timestamp getCreatedAt()      { return createdAt; }
        public void setCreatedAt(Timestamp v) { this.createdAt = v; }
        public boolean isAlready()           { return already; }
        public void setAlready(boolean v)    { this.already = v; }
    }
}
