package com.menuscanner.dao;

import com.menuscanner.model.MenuItem;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MenuItemDAO {

    public List<MenuItem> findByRestaurantId(long restaurantId) throws SQLException {
        String sql = "SELECT * FROM menu_items WHERE restaurant_id = ? ORDER BY display_order ASC";
        List<MenuItem> items = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) items.add(mapRow(rs));
            }
        }
        return items;
    }

    /** Fetch a single item — restaurantId enforced to prevent cross-tenant access. */
    public MenuItem findById(long id, long restaurantId) throws SQLException {
        String sql = "SELECT * FROM menu_items WHERE id = ? AND restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public int countByRestaurantId(long restaurantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM menu_items WHERE restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /** Inserts item and returns generated id. */
    public long save(MenuItem item) throws SQLException {
        String sql = "INSERT INTO menu_items " +
                "(restaurant_id, name, description, price, category, image_path, " +
                " is_veg, is_available, display_order) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[]{"id"})) {
            ps.setLong(1, item.getRestaurantId());
            ps.setString(2, item.getName());
            ps.setString(3, item.getDescription());
            ps.setBigDecimal(4, item.getPrice());
            ps.setString(5, item.getCategory());
            ps.setString(6, item.getImagePath());
            ps.setInt(7, item.isVeg() ? 1 : 0);
            ps.setInt(8, item.isAvailable() ? 1 : 0);
            ps.setInt(9, item.getDisplayOrder());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getLong(1);
            }
        }
        return -1;
    }

    /** restaurantId in WHERE clause prevents cross-tenant updates. */
    public void update(MenuItem item) throws SQLException {
        String sql = "UPDATE menu_items " +
                "SET name=?, description=?, price=?, category=?, image_path=?, " +
                "    is_veg=?, is_available=?, display_order=? " +
                "WHERE id=? AND restaurant_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, item.getName());
            ps.setString(2, item.getDescription());
            ps.setBigDecimal(3, item.getPrice());
            ps.setString(4, item.getCategory());
            ps.setString(5, item.getImagePath());
            ps.setInt(6, item.isVeg() ? 1 : 0);
            ps.setInt(7, item.isAvailable() ? 1 : 0);
            ps.setInt(8, item.getDisplayOrder());
            ps.setLong(9, item.getId());
            ps.setLong(10, item.getRestaurantId());
            ps.executeUpdate();
        }
    }

    /** restaurantId in WHERE clause prevents cross-tenant deletes. */
    public void delete(long id, long restaurantId) throws SQLException {
        String sql = "DELETE FROM menu_items WHERE id = ? AND restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, restaurantId);
            ps.executeUpdate();
        }
    }

    public void updateImagePath(long id, long restaurantId, String imagePath) throws SQLException {
        String sql = "UPDATE menu_items SET image_path=? WHERE id=? AND restaurant_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, imagePath);
            ps.setLong(2, id);
            ps.setLong(3, restaurantId);
            ps.executeUpdate();
        }
    }

    private MenuItem mapRow(ResultSet rs) throws SQLException {
        MenuItem item = new MenuItem();
        item.setId(rs.getLong("id"));
        item.setRestaurantId(rs.getLong("restaurant_id"));
        item.setName(rs.getString("name"));
        item.setDescription(rs.getString("description"));
        item.setPrice(rs.getBigDecimal("price"));
        item.setCategory(rs.getString("category"));
        item.setImagePath(rs.getString("image_path"));
        item.setVeg(rs.getInt("is_veg") == 1);
        item.setAvailable(rs.getInt("is_available") == 1);
        item.setDisplayOrder(rs.getInt("display_order"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        return item;
    }
}
