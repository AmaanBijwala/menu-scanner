package com.menuscanner.review.dao;

import com.menuscanner.dao.DBConnection;
import com.menuscanner.review.model.ReviewContact;
import com.menuscanner.review.model.ReviewScanner;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/** Customers collected by the "join" form on the scan page (for WhatsApp offers later). */
public class ReviewContactDAO {

    private static final String NOW_IST = "(NOW() AT TIME ZONE 'Asia/Kolkata')";

    /**
     * Saves the form. The same phone on the same sticker updates the existing row instead of
     * adding a duplicate. Returns true if this was a new customer.
     */
    public boolean save(ReviewContact c) throws SQLException {
        String sql =
            "INSERT INTO review_contacts (scanner_id, name, age, gender, phone, consent_whatsapp) " +
            "VALUES (?, ?, ?, ?, ?, ?) " +
            "ON CONFLICT (scanner_id, phone) DO UPDATE SET name = EXCLUDED.name, age = EXCLUDED.age, " +
            "  gender = EXCLUDED.gender, consent_whatsapp = EXCLUDED.consent_whatsapp, updated_at = " + NOW_IST + " " +
            "RETURNING (xmax = 0) AS inserted";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, c.getScannerId());
            ps.setString(2, c.getName());
            if (c.getAge() == null) ps.setNull(3, Types.SMALLINT); else ps.setInt(3, c.getAge());
            ps.setString(4, c.getGender());
            ps.setString(5, c.getPhone());
            ps.setBoolean(6, c.isConsentWhatsapp());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean("inserted");
            }
        }
    }

    /**
     * Owner adds a customer by hand from the dashboard. A phone already on this sticker is left
     * untouched (so a customer's own age/gender are never wiped). Returns false if it was already there.
     */
    public boolean addByOwner(long scannerId, String name, String phone) throws SQLException {
        String sql = "INSERT INTO review_contacts (scanner_id, name, phone, consent_whatsapp) VALUES (?, ?, ?, TRUE) " +
                     "ON CONFLICT (scanner_id, phone) DO NOTHING";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setString(2, name);
            ps.setString(3, phone);
            return ps.executeUpdate() == 1;
        }
    }

    /** The current business's customers, newest first (sign-ups from a previous business never show). */
    public List<ReviewContact> findForScanner(ReviewScanner scanner) throws SQLException {
        String sql = "SELECT * FROM review_contacts WHERE scanner_id = ? AND created_at >= ? ORDER BY created_at DESC";
        List<ReviewContact> list = new ArrayList<>();
        if (scanner.getAssignedAt() == null) return list;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scanner.getId());
            ps.setObject(2, scanner.getAssignedAt().toLocalDateTime());   // wall-clock IST, like the column
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    private static ReviewContact mapRow(ResultSet rs) throws SQLException {
        ReviewContact c = new ReviewContact();
        c.setId(rs.getLong("id"));
        c.setScannerId(rs.getLong("scanner_id"));
        c.setName(rs.getString("name"));
        int age = rs.getInt("age");
        c.setAge(rs.wasNull() ? null : age);
        c.setGender(rs.getString("gender"));
        c.setPhone(rs.getString("phone"));
        c.setConsentWhatsapp(rs.getBoolean("consent_whatsapp"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }
}
