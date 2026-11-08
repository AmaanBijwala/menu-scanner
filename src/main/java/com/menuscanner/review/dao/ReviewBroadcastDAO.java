package com.menuscanner.review.dao;

import com.menuscanner.dao.DBConnection;
import com.menuscanner.review.model.ReviewBroadcast;
import com.menuscanner.review.model.ReviewScanner;

import java.security.SecureRandom;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** History of WhatsApp offers sent from the VIP Club tab. */
public class ReviewBroadcastDAO {

    private static final String NOW_IST = "(NOW() AT TIME ZONE 'Asia/Kolkata')";

    /** Same readable alphabet as sticker codes (no 0/O, 1/I/L). */
    private static final String CODE_CHARS = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";
    private static final int    CODE_LEN   = 6;
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Saves a new offer for the given phones. Only phones that are on this sticker's current
     * VIP list are kept (names are copied from that list). With a photo, the offer also gets a
     * public code for its /o/{code} page. Returns the saved offer (id, code), or null if no phone matched.
     */
    public ReviewBroadcast create(ReviewScanner scanner, String message, String imagePath, List<String> phones)
            throws SQLException {
        String insertBroadcast = "INSERT INTO review_broadcasts (scanner_id, message, image_path, code) VALUES (?, ?, ?, ?) RETURNING id";
        String code = imagePath == null ? null : randomCode();
        String insertRecipients =
            "INSERT INTO review_broadcast_recipients (broadcast_id, phone, name) " +
            "SELECT ?, c.phone, c.name FROM review_contacts c " +
            "WHERE c.scanner_id = ? AND c.created_at >= ? AND c.phone = ANY (?) " +
            "ON CONFLICT DO NOTHING";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                long id;
                try (PreparedStatement ps = conn.prepareStatement(insertBroadcast)) {
                    ps.setLong(1, scanner.getId());
                    ps.setString(2, message);
                    ps.setString(3, imagePath);
                    ps.setString(4, code);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        id = rs.getLong(1);
                    }
                }
                int added;
                try (PreparedStatement ps = conn.prepareStatement(insertRecipients)) {
                    ps.setLong(1, id);
                    ps.setLong(2, scanner.getId());
                    ps.setObject(3, scanner.getAssignedAt().toLocalDateTime());   // wall-clock IST, like the column
                    ps.setArray(4, conn.createArrayOf("varchar", phones.toArray()));
                    added = ps.executeUpdate();
                }
                if (added == 0) {
                    conn.rollback();
                    return null;
                }
                conn.commit();
                ReviewBroadcast b = new ReviewBroadcast();
                b.setId(id);
                b.setMessage(message);
                b.setImagePath(imagePath);
                b.setCode(code);
                return b;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /** Marks one customer as sent. Only works on the owner's own stickers. */
    public boolean markSent(long broadcastId, String phone, long ownerId) throws SQLException {
        String sql =
            "UPDATE review_broadcast_recipients r SET sent_at = " + NOW_IST + " " +
            "FROM review_broadcasts b JOIN review_scanners s ON s.id = b.scanner_id " +
            "WHERE r.broadcast_id = b.id AND b.id = ? AND r.phone = ? AND s.owner_id = ? AND r.sent_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, broadcastId);
            ps.setString(2, phone);
            ps.setLong(3, ownerId);
            return ps.executeUpdate() == 1;
        }
    }

    /** The current business's latest offers, newest first, each with its customers. */
    public List<ReviewBroadcast> findRecent(ReviewScanner scanner, int limit) throws SQLException {
        List<ReviewBroadcast> list = new ArrayList<>();
        if (scanner.getAssignedAt() == null) return list;
        String sql =
            "SELECT b.id, b.message, b.image_path, b.code, b.created_at, r.name, r.phone, r.sent_at " +
            "FROM (SELECT * FROM review_broadcasts WHERE scanner_id = ? AND created_at >= ? " +
            "      ORDER BY created_at DESC LIMIT ?) b " +
            "JOIN review_broadcast_recipients r ON r.broadcast_id = b.id " +
            "ORDER BY b.created_at DESC, r.name";
        Map<Long, ReviewBroadcast> byId = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scanner.getId());
            ps.setObject(2, scanner.getAssignedAt().toLocalDateTime());
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReviewBroadcast b = byId.computeIfAbsent(rs.getLong("id"), k -> new ReviewBroadcast());
                    if (b.getMessage() == null) {
                        b.setId(rs.getLong("id"));
                        b.setMessage(rs.getString("message"));
                        b.setImagePath(rs.getString("image_path"));
                        b.setCode(rs.getString("code"));
                        b.setCreatedAt(rs.getTimestamp("created_at"));
                    }
                    b.getRecipients().add(new ReviewBroadcast.Recipient(
                            rs.getString("name"), rs.getString("phone"), rs.getTimestamp("sent_at")));
                }
            }
        }
        list.addAll(byId.values());
        return list;
    }

    /** The public offer page: the offer with its photo, while its sticker still belongs to the same business. */
    public ReviewBroadcast findByCode(String code) throws SQLException {
        String sql =
            "SELECT b.id, b.message, b.image_path, b.code, b.created_at, s.business_name " +
            "FROM review_broadcasts b JOIN review_scanners s ON s.id = b.scanner_id " +
            "WHERE b.code = ? AND s.assigned_at IS NOT NULL AND b.created_at >= s.assigned_at";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ReviewBroadcast b = new ReviewBroadcast();
                b.setId(rs.getLong("id"));
                b.setMessage(rs.getString("message"));
                b.setImagePath(rs.getString("image_path"));
                b.setCode(rs.getString("code"));
                b.setCreatedAt(rs.getTimestamp("created_at"));
                b.setBusinessName(rs.getString("business_name"));
                return b;
            }
        }
    }

    private static String randomCode() {
        StringBuilder sb = new StringBuilder(CODE_LEN);
        for (int i = 0; i < CODE_LEN; i++) sb.append(CODE_CHARS.charAt(RANDOM.nextInt(CODE_CHARS.length())));
        return sb.toString();
    }
}
