package com.menuscanner.review.dao;

import com.menuscanner.dao.DBConnection;
import com.menuscanner.review.model.ReviewOwner;

import java.sql.*;

/** Owner logins for the Product 2 dashboard. Phones are stored as 10 digits. */
public class ReviewOwnerDAO {

    public ReviewOwner findByPhone(String phone) throws SQLException {
        return findOne("SELECT * FROM review_owners WHERE phone = ?", phone, 0);
    }

    public ReviewOwner findById(long id) throws SQLException {
        return findOne("SELECT * FROM review_owners WHERE id = ?", null, id);
    }

    /**
     * Creates the login for this phone, or resets its password if it already exists
     * (the same owner can have several stickers). Returns the owner id.
     */
    public long upsert(String phone, String passwordHash) throws SQLException {
        String sql = "INSERT INTO review_owners (phone, password_hash) VALUES (?, ?) " +
                     "ON CONFLICT (phone) DO UPDATE SET password_hash = EXCLUDED.password_hash RETURNING id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setString(2, passwordHash);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getLong(1);
            }
        }
    }

    public void updateName(long id, String name) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE review_owners SET name = ? WHERE id = ?")) {
            ps.setString(1, name);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void updatePassword(long id, String passwordHash) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE review_owners SET password_hash = ? WHERE id = ?")) {
            ps.setString(1, passwordHash);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void touchLogin(long id) {
        String sql = "UPDATE review_owners SET last_login_at = (NOW() AT TIME ZONE 'Asia/Kolkata') WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            // Non-critical
        }
    }

    private ReviewOwner findOne(String sql, String phone, long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (phone != null) ps.setString(1, phone); else ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ReviewOwner o = new ReviewOwner();
                o.setId(rs.getLong("id"));
                o.setPhone(rs.getString("phone"));
                o.setName(rs.getString("name"));
                o.setPasswordHash(rs.getString("password_hash"));
                o.setLastLoginAt(rs.getTimestamp("last_login_at"));
                return o;
            }
        }
    }
}
