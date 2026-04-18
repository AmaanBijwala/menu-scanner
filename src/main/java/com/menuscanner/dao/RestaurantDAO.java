package com.menuscanner.dao;

import com.menuscanner.model.Restaurant;

import java.sql.*;

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
                " social_instagram, social_facebook, social_youtube, social_twitter) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[]{"id"})) {
            ps.setString(1, r.getName());
            ps.setString(2, r.getSlug());
            ps.setString(3, r.getEmail());
            ps.setString(4, r.getPasswordHash());
            ps.setString(5, r.getPhone());
            ps.setString(6, r.getPlanType() != null ? r.getPlanType() : "BASIC");
            ps.setString(7, r.getSocialInstagram());
            ps.setString(8, r.getSocialFacebook());
            ps.setString(9, r.getSocialYoutube());
            ps.setString(10, r.getSocialTwitter());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getLong(1);
            }
        }
        return -1;
    }

    public void update(Restaurant r) throws SQLException {
        String sql = "UPDATE restaurants " +
                "SET name=?, phone=?, social_instagram=?, social_facebook=?, " +
                "    social_youtube=?, social_twitter=? " +
                "WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, r.getName());
            ps.setString(2, r.getPhone());
            ps.setString(3, r.getSocialInstagram());
            ps.setString(4, r.getSocialFacebook());
            ps.setString(5, r.getSocialYoutube());
            ps.setString(6, r.getSocialTwitter());
            ps.setLong(7, r.getId());
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
        r.setSocialInstagram(rs.getString("social_instagram"));
        r.setSocialFacebook(rs.getString("social_facebook"));
        r.setSocialYoutube(rs.getString("social_youtube"));
        r.setSocialTwitter(rs.getString("social_twitter"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setActive(rs.getInt("is_active") == 1);
        return r;
    }
}
