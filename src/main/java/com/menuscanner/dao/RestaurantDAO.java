package com.menuscanner.dao;

import com.menuscanner.model.Restaurant;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RestaurantDAO {

    public Restaurant findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM restaurants WHERE email = ? AND is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public Restaurant findBySlug(String slug) throws SQLException {
        String sql = "SELECT * FROM restaurants WHERE slug = ? AND is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public Restaurant findById(long id) throws SQLException {
        String sql = "SELECT * FROM restaurants WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /** Inserts a new restaurant and returns the generated id. */
    public long save(Restaurant r) throws SQLException {
        String sql = "INSERT INTO restaurants " +
                "(name, slug, email, password_hash, phone, plan_type, " +
                " social_whatsapp, social_instagram, social_facebook, social_youtube, social_twitter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[]{"id"})) {
            ps.setString(1, r.getName());
            ps.setString(2, r.getSlug());
            ps.setString(3, r.getEmail());
            ps.setString(4, r.getPasswordHash());
            ps.setString(5, r.getPhone());
            ps.setString(6, r.getPlanType() != null ? r.getPlanType() : "BASIC");
            ps.setString(7, r.getSocialWhatsapp());
            ps.setString(8, r.getSocialInstagram());
            ps.setString(9, r.getSocialFacebook());
            ps.setString(10, r.getSocialYoutube());
            ps.setString(11, r.getSocialTwitter());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getLong(1);
            }
        }
        return -1;
    }

    public void update(Restaurant r) throws SQLException {
        String sql = "UPDATE restaurants " +
                "SET name=?, phone=?, social_whatsapp=?, social_instagram=?, " +
                "    social_facebook=?, social_youtube=?, social_twitter=? " +
                "WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, r.getName());
            ps.setString(2, r.getPhone());
            ps.setString(3, r.getSocialWhatsapp());
            ps.setString(4, r.getSocialInstagram());
            ps.setString(5, r.getSocialFacebook());
            ps.setString(6, r.getSocialYoutube());
            ps.setString(7, r.getSocialTwitter());
            ps.setLong(8, r.getId());
            ps.executeUpdate();
        }
    }

    public List<Restaurant> findAll() throws SQLException {
        String sql =
            "SELECT r.*, COALESCE(m.cnt, 0) AS dish_count " +
            "FROM restaurants r " +
            "LEFT JOIN (SELECT restaurant_id, COUNT(*) AS cnt FROM menu_items GROUP BY restaurant_id) m " +
            "ON r.id = m.restaurant_id " +
            "ORDER BY r.created_at DESC";
        List<Restaurant> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Restaurant r = mapRow(rs);
                r.setDishCount(rs.getInt("dish_count"));
                list.add(r);
            }
        }
        return list;
    }

    public boolean slugExists(String slug) throws SQLException {
        String sql = "SELECT 1 FROM restaurants WHERE slug = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void updatePlan(long id, String planType) throws SQLException {
        String sql = "UPDATE restaurants SET plan_type=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, planType);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void updateActive(long id, boolean active) throws SQLException {
        String sql = "UPDATE restaurants SET is_active=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, active ? 1 : 0);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void updateContact(long id, String name, String email, String phone) throws SQLException {
        String sql = "UPDATE restaurants SET name=?, email=?, phone=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, email.toLowerCase());
            ps.setString(3, phone == null || phone.isBlank() ? null : phone.trim());
            ps.setLong(4, id);
            ps.executeUpdate();
        }
    }

    public void updatePassword(long id, String newHash) throws SQLException {
        String sql = "UPDATE restaurants SET password_hash=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    private Restaurant mapRow(ResultSet rs) throws SQLException {
        Restaurant r = new Restaurant();
        r.setId(rs.getLong("id"));
        r.setName(rs.getString("name"));
        r.setSlug(rs.getString("slug"));
        r.setEmail(rs.getString("email"));
        r.setPasswordHash(rs.getString("password_hash"));
        r.setPhone(rs.getString("phone"));
        r.setPlanType(rs.getString("plan_type"));
        r.setSocialWhatsapp(rs.getString("social_whatsapp"));
        r.setSocialInstagram(rs.getString("social_instagram"));
        r.setSocialFacebook(rs.getString("social_facebook"));
        r.setSocialYoutube(rs.getString("social_youtube"));
        r.setSocialTwitter(rs.getString("social_twitter"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setActive(rs.getInt("is_active") == 1);
        return r;
    }
}
