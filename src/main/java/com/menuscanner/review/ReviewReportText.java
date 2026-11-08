package com.menuscanner.review;

import com.menuscanner.review.model.ReviewPlatform;

import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.Map;

/** The WhatsApp-ready monthly summary (*bold* is WhatsApp markup), shared by admin and owner screens. */
public final class ReviewReportText {

    public static final DateTimeFormatter MONTH_LABEL = DateTimeFormatter.ofPattern("MMMM yyyy", Locale.ENGLISH);

    public static String build(String businessName, String stickerNo, YearMonth month, int scans,
                               String busiestDay, String busiestTime, Map<ReviewPlatform, Integer> clicks) {
        StringBuilder sb = new StringBuilder();
        sb.append('*').append(businessName).append(" – ").append(month.format(MONTH_LABEL)).append("*\n");
        sb.append("Review QR report\n\n");
        sb.append("Customers who scanned: ").append(scans).append('\n');
        if (scans > 0) {
            if (busiestDay  != null) sb.append("Busiest day: ").append(busiestDay).append('\n');
            if (busiestTime != null) sb.append("Busiest time: ").append(busiestTime).append('\n');
        }
        if (clicks != null && !clicks.isEmpty()) {
            sb.append("\nWhere they went:\n");
            for (ReviewPlatform p : ReviewPlatform.values()) {
                Integer n = clicks.get(p);
                if (n != null && n > 0) sb.append("• ").append(p.getLabel()).append(": ").append(n).append('\n');
            }
        }
        sb.append("\nScanner ").append(stickerNo);
        return sb.toString();
    }

    private ReviewReportText() {}
}
