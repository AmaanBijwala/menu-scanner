package com.menuscanner.review.model;

import java.util.EnumMap;
import java.util.Map;

/** One scanner's scan summary for a single month (IST). */
public class ReviewMonthlyReport {

    private static final String[] DAYS = {
        "", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    };

    private int totalScans;
    private int busiestIsoDow;      // 1 = Monday … 7 = Sunday, 0 = no data
    private int busiestHourBlock;   // start hour of the busiest 2-hour block (0, 2, … 22), -1 = no data

    private Map<ReviewPlatform, Integer> clicks = new EnumMap<>(ReviewPlatform.class);

    /** Trips to each app this month (only apps with at least one). */
    public Map<ReviewPlatform, Integer> getClicks()  { return clicks; }
    public void setClicks(Map<ReviewPlatform, Integer> c) { this.clicks = c; }

    public int getTotalScans()               { return totalScans; }
    public void setTotalScans(int n)         { this.totalScans = n; }

    public void setBusiestIsoDow(int d)      { this.busiestIsoDow = d; }
    public void setBusiestHourBlock(int h)   { this.busiestHourBlock = h; }

    /** e.g. "Saturday", or null when there were no scans. */
    public String getBusiestDay() {
        return busiestIsoDow >= 1 && busiestIsoDow <= 7 ? DAYS[busiestIsoDow] : null;
    }

    /** e.g. "8 PM – 10 PM", or null when there were no scans. */
    public String getBusiestTime() {
        if (busiestHourBlock < 0) return null;
        return hourLabel(busiestHourBlock) + " – " + hourLabel((busiestHourBlock + 2) % 24);
    }

    private static String hourLabel(int h) {
        int h12 = h % 12 == 0 ? 12 : h % 12;
        return h12 + (h < 12 ? " AM" : " PM");
    }
}
