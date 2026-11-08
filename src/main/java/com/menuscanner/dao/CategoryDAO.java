package com.menuscanner.dao;

import com.menuscanner.model.Category;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> findByRestaurantId(long restaurantId) throws SQLException {
        List<Category> list = new ArrayList<>();
        // Owner's arrangement first; categories never arranged (NULL) fall back to A–Z
        String sql = "SELECT id, restaurant_id, name FROM categories WHERE restaurant_id = ? " +
                     "ORDER BY display_order ASC NULLS LAST, name";
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

    /**
     * Swaps a category with its neighbour (direction -1 = earlier, +1 = later), then saves the
     * whole current order so every category of the restaurant has a position from now on.
     */
    public void move(long id, long restaurantId, int direction) throws SQLException {
        List<Category> cats = findByRestaurantId(restaurantId);
        int from = -1;
        for (int i = 0; i < cats.size(); i++) if (cats.get(i).getId() == id) from = i;
        int to = from + direction;
        if (from < 0 || to < 0 || to >= cats.size()) return;
        cats.add(to, cats.remove(from));

        String sql = "UPDATE categories SET display_order = ? WHERE id = ? AND restaurant_id = ?";
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                for (int i = 0; i < cats.size(); i++) {
                    ps.setInt(1, i);
                    ps.setLong(2, cats.get(i).getId());
                    ps.setLong(3, restaurantId);
                    ps.addBatch();
                }
                ps.executeBatch();
                c.commit();
            } catch (SQLException e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
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
