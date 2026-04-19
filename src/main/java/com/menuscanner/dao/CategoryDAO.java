package com.menuscanner.dao;

import com.menuscanner.model.Category;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> findByRestaurantId(long restaurantId) throws SQLException {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, restaurant_id, name FROM categories WHERE restaurant_id = ? ORDER BY name";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Category cat = new Category();
                cat.setId(rs.getLong("id"));
                cat.setRestaurantId(rs.getLong("restaurant_id"));
                cat.setName(rs.getString("name"));
                list.add(cat);
            }
        }
        return list;
    }

    public void save(Category cat) throws SQLException {
        String sql = "INSERT INTO categories (restaurant_id, name) VALUES (?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, cat.getRestaurantId());
            ps.setString(2, cat.getName());
            ps.executeUpdate();
        }
    }

    public void delete(long id, long restaurantId) throws SQLException {
        String sql = "DELETE FROM categories WHERE id = ? AND restaurant_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, restaurantId);
            ps.executeUpdate();
        }
    }
}
