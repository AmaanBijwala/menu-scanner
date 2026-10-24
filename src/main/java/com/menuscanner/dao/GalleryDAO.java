package com.menuscanner.dao;

import com.menuscanner.model.GalleryImage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GalleryDAO {

    public List<GalleryImage> findByRestaurantId(long restaurantId) throws SQLException {
        String sql = "SELECT * FROM gallery_images WHERE restaurant_id = ? ORDER BY display_order ASC, created_at ASC";
        List<GalleryImage> images = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) images.add(mapRow(rs));
            }
        }
        return images;
    }

    public int countByRestaurantId(long restaurantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM gallery_images WHERE restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public long save(GalleryImage image) throws SQLException {
        String sql = "INSERT INTO gallery_images (restaurant_id, image_path, caption, display_order) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[]{"id"})) {
            ps.setLong(1, image.getRestaurantId());
            ps.setString(2, image.getImagePath());
            ps.setString(3, image.getCaption());
            ps.setInt(4, image.getDisplayOrder());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getLong(1);
            }
        }
        return -1;
    }

    /** Returns image_path before deletion so the caller can remove the file from disk. */
    public String getImagePath(long id, long restaurantId) throws SQLException {
        String sql = "SELECT image_path FROM gallery_images WHERE id = ? AND restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, restaurantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("image_path");
            }
        }
        return null;
    }

    public void updateCaption(long id, long restaurantId, String caption) throws SQLException {
        String sql = "UPDATE gallery_images SET caption = ? WHERE id = ? AND restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, caption == null || caption.isBlank() ? null : caption.trim());
            ps.setLong(2, id);
            ps.setLong(3, restaurantId);
            ps.executeUpdate();
        }
    }

    /** restaurantId in WHERE prevents cross-tenant deletes. */
    public void delete(long id, long restaurantId) throws SQLException {
        String sql = "DELETE FROM gallery_images WHERE id = ? AND restaurant_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, restaurantId);
            ps.executeUpdate();
        }
    }

    private GalleryImage mapRow(ResultSet rs) throws SQLException {
        GalleryImage img = new GalleryImage();
        img.setId(rs.getLong("id"));
        img.setRestaurantId(rs.getLong("restaurant_id"));
        img.setImagePath(rs.getString("image_path"));
        img.setCaption(rs.getString("caption"));
        img.setDisplayOrder(rs.getInt("display_order"));
        img.setCreatedAt(rs.getTimestamp("created_at"));
        return img;
    }
}
