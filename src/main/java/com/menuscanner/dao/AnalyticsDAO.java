package com.menuscanner.dao;

import java.sql.*;
import java.util.*;

public class AnalyticsDAO {

    // ── QR Scan tracking ─────────────────────────────────────────────────────

    public void recordScan(long restaurantId, String userAgent, String ipAddress) {
        String sql = "INSERT INTO scan_analytics (restaurant_id, user_agent, ip_address) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            ps.setString(2, userAgent != null ? userAgent.substring(0, Math.min(255, userAgent.length())) : null);
            ps.setString(3, ipAddress);
            ps.executeUpdate();
        } catch (SQLException e) {
            // Non-critical — don't fail menu load over analytics
        }
    }

    public int getTotalScans(long restaurantId) throws SQLException {
        return countScans(restaurantId,
                "SELECT COUNT(*) FROM scan_analytics WHERE restaurant_id = ?");
    }

    public int getTodayScans(long restaurantId) throws SQLException {
        return countScans(restaurantId,
                "SELECT COUNT(*) FROM scan_analytics WHERE restaurant_id = ? AND scanned_at >= CURRENT_DATE");
    }

    public int getThisWeekScans(long restaurantId) throws SQLException {
        return countScans(restaurantId,
                "SELECT COUNT(*) FROM scan_analytics WHERE restaurant_id = ? AND scanned_at >= date_trunc('week', CURRENT_DATE)");
    }

    public int getThisMonthScans(long restaurantId) throws SQLException {
        return countScans(restaurantId,
                "SELECT COUNT(*) FROM scan_analytics WHERE restaurant_id = ? AND scanned_at >= date_trunc('month', CURRENT_DATE)");
    }

    /** Returns [{label, count}] for the last {@code days} days (including today). */
    public List<Map<String, Object>> getDailyScans(long restaurantId, int days) throws SQLException {
        String sql =
            "SELECT TO_CHAR(d::date, 'Mon DD') AS label, COALESCE(s.cnt, 0) AS cnt " +
            "FROM generate_series(CURRENT_DATE - INTERVAL '" + (days - 1) + " days', " +
            "                     CURRENT_DATE, '1 day') AS d " +
            "LEFT JOIN (" +
            "  SELECT DATE(scanned_at) AS day, COUNT(*) AS cnt " +
            "  FROM scan_analytics WHERE restaurant_id = ? GROUP BY DATE(scanned_at)" +
            ") s ON s.day = d::date " +
            "ORDER BY d ASC";

        List<Map<String, Object>> result = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("label", rs.getString("label"));
                    row.put("count", rs.getInt("cnt"));
                    result.add(row);
                }
            }
        }
        return result;
    }

    // ── Item view tracking ────────────────────────────────────────────────────

    /** Upserts view counts for a batch of item IDs. Safe to call fire-and-forget. */
    public void recordItemViews(long restaurantId, List<Long> itemIds) {
        if (itemIds == null || itemIds.isEmpty()) return;
        String sql =
            "INSERT INTO item_view_counts (item_id, restaurant_id, view_count, last_viewed) " +
            "VALUES (?, ?, 1, NOW()) " +
            "ON CONFLICT (item_id) DO UPDATE " +
            "SET view_count = item_view_counts.view_count + 1, last_viewed = NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Long itemId : itemIds) {
                ps.setLong(1, itemId);
                ps.setLong(2, restaurantId);
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            // Non-critical
        }
    }

    /** Returns top {@code limit} items by view count for a restaurant. */
    public List<Map<String, Object>> getTopItems(long restaurantId, int limit) throws SQLException {
        String sql =
            "SELECT m.name, m.category, m.image_path, COALESCE(v.view_count, 0) AS views " +
            "FROM menu_items m " +
            "LEFT JOIN item_view_counts v ON v.item_id = m.id " +
            "WHERE m.restaurant_id = ? AND m.is_available = 1 " +
            "ORDER BY views DESC, m.name ASC " +
            "LIMIT ?";
        List<Map<String, Object>> result = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("name",      rs.getString("name"));
                    row.put("category",  rs.getString("category"));
                    row.put("imagePath", rs.getString("image_path"));
                    row.put("views",     rs.getLong("views"));
                    result.add(row);
                }
            }
        }
        return result;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private int countScans(long restaurantId, String sql) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }
}
