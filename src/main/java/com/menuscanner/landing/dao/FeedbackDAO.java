package com.menuscanner.landing.dao;

import com.menuscanner.dao.DBConnection;
import com.menuscanner.landing.model.Feedback;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {

    public void save(Feedback f, String visitorHash) throws SQLException {
        String sql = "INSERT INTO landing_feedback (person_name, shop_name, location, product, comment, visitor_hash) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, f.getPersonName());
            ps.setString(2, f.getShopName());
            ps.setString(3, f.getLocation());
            ps.setString(4, f.getProduct());
            ps.setString(5, f.getComment());
            ps.setString(6, visitorHash);
            ps.executeUpdate();
        }
    }

    /** How many feedbacks this visitor posted in the last hour — stops spam floods. */
    public int countRecentByVisitor(String visitorHash) throws SQLException {
        String sql = "SELECT COUNT(*) FROM landing_feedback WHERE visitor_hash = ? " +
                     "AND created_at > (NOW() AT TIME ZONE 'Asia/Kolkata') - INTERVAL '1 hour'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, visitorHash);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /** Public strip: visible feedback, newest first. */
    public List<Feedback> findVisible() throws SQLException {
        return query("SELECT * FROM landing_feedback WHERE is_visible = 1 ORDER BY created_at DESC LIMIT 50");
    }

    /** Admin list: everything, newest first. */
    public List<Feedback> findAll() throws SQLException {
        return query("SELECT * FROM landing_feedback ORDER BY created_at DESC");
    }

    public void updateVisible(long id, boolean visible) throws SQLException {
        String sql = "UPDATE landing_feedback SET is_visible = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, visible ? 1 : 0);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM landing_feedback WHERE id = ?")) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    private List<Feedback> query(String sql) throws SQLException {
        List<Feedback> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    private Feedback mapRow(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setId(rs.getLong("id"));
        f.setPersonName(rs.getString("person_name"));
        f.setShopName(rs.getString("shop_name"));
        f.setLocation(rs.getString("location"));
        f.setProduct(rs.getString("product"));
        f.setComment(rs.getString("comment"));
        f.setVisible(rs.getInt("is_visible") == 1);
        f.setCreatedAt(rs.getTimestamp("created_at"));
        return f;
    }
}
