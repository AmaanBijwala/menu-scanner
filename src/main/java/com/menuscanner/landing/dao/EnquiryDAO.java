package com.menuscanner.landing.dao;

import com.menuscanner.dao.DBConnection;
import com.menuscanner.landing.model.Enquiry;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EnquiryDAO {

    public void save(Enquiry e, String visitorHash) throws SQLException {
        String sql = "INSERT INTO landing_enquiries (name, phone, business_name, interest, message, visitor_hash) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, e.getName());
            ps.setString(2, e.getPhone());
            ps.setString(3, e.getBusinessName());
            ps.setString(4, e.getInterest());
            ps.setString(5, e.getMessage());
            ps.setString(6, visitorHash);
            ps.executeUpdate();
        }
    }

    /** How many enquiries this visitor sent in the last hour — used to stop form spam. */
    public int countRecentByVisitor(String visitorHash) throws SQLException {
        String sql = "SELECT COUNT(*) FROM landing_enquiries WHERE visitor_hash = ? " +
                     "AND created_at > (NOW() AT TIME ZONE 'Asia/Kolkata') - INTERVAL '1 hour'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, visitorHash);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public List<Enquiry> findAll() throws SQLException {
        String sql = "SELECT * FROM landing_enquiries ORDER BY created_at DESC";
        List<Enquiry> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public void updateStatus(long id, String status) throws SQLException {
        String sql = "UPDATE landing_enquiries SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    private Enquiry mapRow(ResultSet rs) throws SQLException {
        Enquiry e = new Enquiry();
        e.setId(rs.getLong("id"));
        e.setName(rs.getString("name"));
        e.setPhone(rs.getString("phone"));
        e.setBusinessName(rs.getString("business_name"));
        e.setInterest(rs.getString("interest"));
        e.setMessage(rs.getString("message"));
        e.setStatus(rs.getString("status"));
        e.setCreatedAt(rs.getTimestamp("created_at"));
        return e;
    }
}
