package com.menuscanner.review.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** One scanner's numbers for one month (IST), shaped for the owner dashboard. */
public class ReviewAnalytics {

    /** One bar in a bar chart: label, value and its height as % of the tallest bar. */
    public static class Bar {
        private final String label;
        private final String fullLabel;
        private final int    value;
        private final int    pct;

        Bar(String label, String fullLabel, int value, int max) {
            this.label     = label;
            this.fullLabel = fullLabel;
            this.value     = value;
            this.pct       = max == 0 ? 0 : (int) Math.round(value * 100.0 / max);
        }

        public String getLabel()     { return label; }
        public String getFullLabel() { return fullLabel; }
        public int    getValue()     { return value; }
        public int    getPct()       { return pct; }
    }

    /** One app's row in the "where customers went" list. */
    public static class AppRow {
        private final ReviewPlatform platform;
        private final int value;
        private final int pct;
        private final boolean configured;

        AppRow(ReviewPlatform platform, int value, int max, boolean configured) {
            this.platform   = platform;
            this.value      = value;
            this.pct        = max == 0 ? 0 : (int) Math.round(value * 100.0 / max);
            this.configured = configured;
        }

        public ReviewPlatform getPlatform() { return platform; }
        public int     getValue()           { return value; }
        public int     getPct()             { return pct; }
        public boolean isConfigured()       { return configured; }
    }

    private static final String[] DOW_SHORT = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
    private static final String[] DOW_FULL  = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};

    private int totalScans;
    private int previousMonthScans;
    private int totalClicks;
    private final List<Bar>    daily = new ArrayList<>();
    private final List<Bar>    days  = new ArrayList<>();
    private final List<Bar>    hours = new ArrayList<>();
    private final List<AppRow> apps  = new ArrayList<>();
    private String busiestDay;
    private String busiestTime;
    private AppRow topApp;

    /**
     * @param dailyCounts index 0 = 1st of the month
     * @param dowCounts   index 0 = Monday
     * @param blockCounts index 0 = 12 AM–2 AM, … 11 = 10 PM–12 AM
     */
    public ReviewAnalytics(int totalScans, int previousMonthScans, int[] dailyCounts, int[] dowCounts,
                           int[] blockCounts, Map<ReviewPlatform, Integer> clicks, ReviewScanner scanner,
                           String monthShort) {
        this.totalScans         = totalScans;
        this.previousMonthScans = previousMonthScans;

        int maxDaily = max(dailyCounts);
        for (int i = 0; i < dailyCounts.length; i++) {
            daily.add(new Bar(String.valueOf(i + 1), (i + 1) + " " + monthShort, dailyCounts[i], maxDaily));
        }
        int maxDow = max(dowCounts);
        for (int i = 0; i < 7; i++) days.add(new Bar(DOW_SHORT[i], DOW_FULL[i], dowCounts[i], maxDow));
        int maxBlock = max(blockCounts);
        for (int i = 0; i < 12; i++) {
            hours.add(new Bar(hourShort(i * 2), hourLabel(i * 2) + " – " + hourLabel((i * 2 + 2) % 24),
                              blockCounts[i], maxBlock));
        }

        if (totalScans > 0) {
            busiestDay  = DOW_FULL[argMax(dowCounts)];
            int b = argMax(blockCounts) * 2;
            busiestTime = hourLabel(b) + " – " + hourLabel((b + 2) % 24);
        }

        int maxClicks = 0;
        for (int v : clicks.values()) { maxClicks = Math.max(maxClicks, v); totalClicks += v; }
        for (ReviewPlatform p : ReviewPlatform.values()) {
            boolean configured = scanner.getLinks().containsKey(p);
            int v = clicks.getOrDefault(p, 0);
            if (configured || v > 0) {
                AppRow row = new AppRow(p, v, maxClicks, configured);
                apps.add(row);
                if (v > 0 && (topApp == null || v > topApp.getValue())) topApp = row;
            }
        }
    }

    public int getTotalScans()          { return totalScans; }
    public int getPreviousMonthScans()  { return previousMonthScans; }
    public int getTotalClicks()         { return totalClicks; }
    /** Change vs the previous month in %, or null when there's nothing to compare with. */
    public Integer getChangePct() {
        if (previousMonthScans == 0) return null;
        return (int) Math.round((totalScans - previousMonthScans) * 100.0 / previousMonthScans);
    }
    public List<Bar>    getDaily()      { return daily; }
    public List<Bar>    getDays()       { return days; }
    public List<Bar>    getHours()      { return hours; }
    public List<AppRow> getApps()       { return apps; }
    public String getBusiestDay()       { return busiestDay; }
    public String getBusiestTime()      { return busiestTime; }
    public AppRow getTopApp()           { return topApp; }

    private static int max(int[] a)     { int m = 0; for (int v : a) m = Math.max(m, v); return m; }

    private static int argMax(int[] a) {
        int best = 0;
        for (int i = 1; i < a.length; i++) if (a[i] > a[best]) best = i;
        return best;
    }

    static String hourLabel(int h) {
        int h12 = h % 12 == 0 ? 12 : h % 12;
        return h12 + (h < 12 ? " AM" : " PM");
    }

    private static String hourShort(int h) {
        int h12 = h % 12 == 0 ? 12 : h % 12;
        return h12 + (h < 12 ? "a" : "p");
    }
}
