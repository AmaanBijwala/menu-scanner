package com.menuscanner.dao;

import com.menuscanner.model.Customer;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {

    public List<Customer> findByRestaurantId(long restaurantId) throws SQLException {
        String sql = "SELECT * FROM customers WHERE restaurant_id = ? ORDER BY captured_at DESC";
        List<Customer> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int countByRestaurantId(long restaurantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM customers WHERE restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /** Saves customer and returns generated id. */
    public long save(Customer c) throws SQLException {
        String sql = "INSERT INTO customers " +
                "(restaurant_id, name, phone, age, gender, consent_whatsapp) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[]{"id"})) {
            ps.setLong(1, c.getRestaurantId());
            ps.setString(2, c.getName());
            ps.setString(3, c.getPhone());
            ps.setInt(4, c.getAge());
            ps.setString(5, c.getGender());
            ps.setInt(6, c.isConsentWhatsapp() ? 1 : 0);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getLong(1);
            }
        }
        return -1;
    }

    private Customer mapRow(ResultSet rs) throws SQLException {
        Customer c = new Customer();
        c.setId(rs.getLong("id"));
        c.setRestaurantId(rs.getLong("restaurant_id"));
        c.setName(rs.getString("name"));
        c.setPhone(rs.getString("phone"));
        c.setAge(rs.getInt("age"));
        c.setGender(rs.getString("gender"));
        c.setCapturedAt(rs.getTimestamp("captured_at"));
        c.setConsentWhatsapp(rs.getInt("consent_whatsapp") == 1);
        return c;
    }
}
