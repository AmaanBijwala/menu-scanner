package com.menuscanner.review.model;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

/** A sticker's digital stamp card: collect {@code stampsNeeded} stamps (one a day) to get {@code reward}. */
public class ReviewStampProgram {

    private long    scannerId;
    private int     stampsNeeded;
    private String  reward;
    private boolean active;

    public long getScannerId()              { return scannerId; }
    public void setScannerId(long v)        { this.scannerId = v; }
    public int getStampsNeeded()            { return stampsNeeded; }
    public void setStampsNeeded(int v)      { this.stampsNeeded = v; }
    public String getReward()               { return reward; }
    public void setReward(String v)         { this.reward = v; }
    public boolean isActive()               { return active; }
    public void setActive(boolean v)        { this.active = v; }

    /** One customer's card that hasn't been redeemed yet (owner's Rewards tab). */
    public static class Card {
        private String     phone;
        private String     name;
        private List<Date> dates = new ArrayList<>();
        private int        needed;

        public String getPhone()             { return phone; }
        public void setPhone(String v)       { this.phone = v; }
        public String getName()              { return name; }
        public void setName(String v)        { this.name = v; }
        public List<Date> getDates()         { return dates; }
        public int getCount()                { return dates.size(); }
        public int getNeeded()               { return needed; }
        public void setNeeded(int v)         { this.needed = v; }
        public boolean isComplete()          { return needed > 0 && dates.size() >= needed; }
    }

    /** What the customer sees after scanning: the stamp they just got (or not) and their card. */
    public static class Result {
        private boolean already;     // had collected today's stamp already
        private boolean added;       // a stamp was added just now
        private int     count;
        private int     needed;
        private String  reward;

        public boolean isAlready()           { return already; }
        public void setAlready(boolean v)    { this.already = v; }
        public boolean isAdded()             { return added; }
        public void setAdded(boolean v)      { this.added = v; }
        public int getCount()                { return count; }
        public void setCount(int v)          { this.count = v; }
        public int getNeeded()               { return needed; }
        public void setNeeded(int v)         { this.needed = v; }
        public String getReward()            { return reward; }
        public void setReward(String v)      { this.reward = v; }
        public boolean isComplete()          { return count >= needed; }
    }
}
