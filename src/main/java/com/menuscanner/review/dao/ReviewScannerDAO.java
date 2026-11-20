package com.menuscanner.review.dao;

import com.menuscanner.dao.DBConnection;
import com.menuscanner.review.model.ReviewAnalytics;
import com.menuscanner.review.model.ReviewMonthlyReport;
import com.menuscanner.review.model.ReviewPlatform;
import com.menuscanner.review.model.ReviewScanner;

import java.security.SecureRandom;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.*;

/**
 * Product 2 — Google review scanners.
 * All timestamps are IST wall-clock (see review-schema.sql), so every "now" below
 * is written as NOW() AT TIME ZONE 'Asia/Kolkata'.
 */
public class ReviewScannerDAO {

    private static final String NOW_IST = "(NOW() AT TIME ZONE 'Asia/Kolkata')";

    /** No 0/O, 1/I/L — easy to read if anyone ever types a code by hand. */
    private static final String CODE_CHARS = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";
    private static final int    CODE_LEN   = 6;
    private static final SecureRandom RANDOM = new SecureRandom();

    /** Same visitor scanning the same sticker again within this window counts once. */
    private static final int DEDUPE_MINUTES = 30;

    /** Every scanner query selects this, so mapRow() always has the owner login's phone. */
    private static final String SELECT_SCANNER =
        "SELECT s.*, (SELECT o.phone FROM review_owners o WHERE o.id = s.owner_id) AS login_phone, " +
        "       (SELECT o.name  FROM review_owners o WHERE o.id = s.owner_id) AS owner_name ";

    // ── Read ──────────────────────────────────────────────────────────────────

    /** All scanners with this-month / last-month / total scan counts (only scans since assignment). */
    public List<ReviewScanner> findAll() throws SQLException {
        String sql =
            SELECT_SCANNER + ", " +
            "  COUNT(c.id) FILTER (WHERE c.scanned_at >= date_trunc('month', " + NOW_IST + ")) AS this_month, " +
            "  COUNT(c.id) FILTER (WHERE c.scanned_at >= date_trunc('month', " + NOW_IST + ") - INTERVAL '1 month' " +
            "                        AND c.scanned_at <  date_trunc('month', " + NOW_IST + ")) AS last_month, " +
            "  COUNT(c.id) AS total " +
            "FROM review_scanners s " +
            "LEFT JOIN review_scans c ON c.scanner_id = s.id " +
            "     AND s.assigned_at IS NOT NULL AND c.scanned_at >= s.assigned_at " +
            "GROUP BY s.id " +
            "ORDER BY s.id";
        List<ReviewScanner> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ReviewScanner s = mapRow(rs);
                s.setScansThisMonth(rs.getInt("this_month"));
                s.setScansLastMonth(rs.getInt("last_month"));
                s.setScansTotal(rs.getInt("total"));
                list.add(s);
            }
        }
        return list;
    }

    public ReviewScanner findByCode(String code) throws SQLException {
        return findOne(SELECT_SCANNER + "FROM review_scanners s WHERE s.code = ?", ps -> ps.setString(1, code));
    }

    public ReviewScanner findById(long id) throws SQLException {
        return findOne(SELECT_SCANNER + "FROM review_scanners s WHERE s.id = ?", ps -> ps.setLong(1, id));
    }

    /** Stickers an owner sees in their dashboard (assigned ones only). */
    public List<ReviewScanner> findByOwner(long ownerId) throws SQLException {
        String sql = SELECT_SCANNER + "FROM review_scanners s " +
                     "WHERE s.owner_id = ? AND s.business_name IS NOT NULL ORDER BY s.id";
        List<ReviewScanner> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ── Write ─────────────────────────────────────────────────────────────────

    /** Creates {@code count} blank scanners with unique random codes. Returns their ids. */
    public List<Long> createBatch(int count) throws SQLException {
        String sql = "INSERT INTO review_scanners (code) VALUES (?) ON CONFLICT (code) DO NOTHING";
        List<Long> ids = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, new String[]{"id"})) {
            int attempts = 0;
            while (ids.size() < count && attempts++ < count * 5) {
                ps.setString(1, randomCode());
                if (ps.executeUpdate() == 1) {               // 0 = code collision, just retry
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) ids.add(keys.getLong(1));
                    }
                }
            }
        }
        return ids;
    }

    /**
     * Maps a scanner to a business. assigned_at is reset only when the business changes
     * (or on first assignment), so editing links/phone keeps the report history.
     */
    public void assign(long id, String businessName, String ownerPhone, Map<ReviewPlatform, String> links,
                       boolean joinForm, String linkOrder, String wifiName, String wifiPassword) throws SQLException {
        String sql =
            "UPDATE review_scanners SET " +
            "  assigned_at = CASE WHEN assigned_at IS NULL OR business_name IS DISTINCT FROM ? " +
            "                     THEN " + NOW_IST + " ELSE assigned_at END, " +
            "  business_name = ?, owner_phone = ?, " +
            "  google_review_url = ?, instagram_url = ?, facebook_url = ?, youtube_url = ?, whatsapp_url = ?, " +
            "  join_form = ?, link_order = ?, wifi_name = ?, wifi_password = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, businessName);
            ps.setString(2, businessName);
            ps.setString(3, ownerPhone);
            bindLinks(ps, 4, links);
            ps.setBoolean(9, joinForm);
            ps.setString(10, linkOrder);
            ps.setString(11, wifiName);
            ps.setString(12, wifiPassword);
            ps.setLong(13, id);
            ps.executeUpdate();
        }
    }

    /**
     * The owner editing their own links from the dashboard. The owner_id check means an
     * owner can never change someone else's sticker. Returns false if nothing was updated.
     */
    public boolean updateLinksForOwner(long id, long ownerId, Map<ReviewPlatform, String> links) throws SQLException {
        String sql = "UPDATE review_scanners SET google_review_url = ?, instagram_url = ?, facebook_url = ?, " +
                     "youtube_url = ?, whatsapp_url = ? WHERE id = ? AND owner_id = ? AND business_name IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            bindLinks(ps, 1, links);
            ps.setLong(6, id);
            ps.setLong(7, ownerId);
            return ps.executeUpdate() == 1;
        }
    }

    /** The owner changing the button order on their own sticker's scan page. */
    public boolean updateLinkOrderForOwner(long id, long ownerId, String linkOrder) throws SQLException {
        String sql = "UPDATE review_scanners SET link_order = ? WHERE id = ? AND owner_id = ? AND business_name IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, linkOrder);
            ps.setLong(2, id);
            ps.setLong(3, ownerId);
            return ps.executeUpdate() == 1;
        }
    }

    /** The owner changing the guest WiFi on their own sticker. Returns false if nothing was updated. */
    public boolean updateWifiForOwner(long id, long ownerId, String wifiName, String wifiPassword) throws SQLException {
        String sql = "UPDATE review_scanners SET wifi_name = ?, wifi_password = ? " +
                     "WHERE id = ? AND owner_id = ? AND business_name IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, wifiName);
            ps.setString(2, wifiPassword);
            ps.setLong(3, id);
            ps.setLong(4, ownerId);
            return ps.executeUpdate() == 1;
        }
    }

    /** Links a scanner to an owner login (null = no login). */
    public void setOwner(long id, Long ownerId) throws SQLException {
        String sql = "UPDATE review_scanners SET owner_id = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (ownerId == null) ps.setNull(1, Types.BIGINT); else ps.setLong(1, ownerId);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    /** Frees a scanner so the sticker can be given to another business. */
    /** Super admin: which reward features this sticker's owner may use, and the shop location for the near-the-shop check. */
    public void updateFeatures(long id, boolean stamp, boolean scratch, boolean geo, Double lat, Double lng) throws SQLException {
        String sql = "UPDATE review_scanners SET stamp_allowed = ?, scratch_allowed = ?, geo_check = ?, shop_lat = ?, shop_lng = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, stamp);
            ps.setBoolean(2, scratch);
            ps.setBoolean(3, geo);
            if (lat == null) ps.setNull(4, Types.DOUBLE); else ps.setDouble(4, lat);
            if (lng == null) ps.setNull(5, Types.DOUBLE); else ps.setDouble(5, lng);
            ps.setLong(6, id);
            ps.executeUpdate();
        }
    }

    public void unassign(long id) throws SQLException {
        String sql = "UPDATE review_scanners SET business_name = NULL, owner_phone = NULL, " +
                     "google_review_url = NULL, instagram_url = NULL, facebook_url = NULL, youtube_url = NULL, whatsapp_url = NULL, " +
                     "owner_id = NULL, assigned_at = NULL, is_active = 1, join_form = TRUE, " +
                     "stamp_allowed = FALSE, scratch_allowed = FALSE, geo_check = FALSE, shop_lat = NULL, shop_lng = NULL, " +
                     "link_order = NULL, wifi_name = NULL, wifi_password = NULL WHERE id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 PreparedStatement p2 = conn.prepareStatement("DELETE FROM review_stamp_programs WHERE scanner_id = ?");
                 PreparedStatement p3 = conn.prepareStatement(
                     "UPDATE review_scratch_campaigns SET active = FALSE, ended_at = " + NOW_IST + " WHERE scanner_id = ? AND active")) {
                ps.setLong(1, id);
                ps.executeUpdate();
                // Reward settings belong to the old business; its stamps and scratches stay in the
                // tables but every query only reads rows created after assigned_at.
                p2.setLong(1, id);
                p2.executeUpdate();
                p3.setLong(1, id);
                p3.executeUpdate();
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void updateActive(long id, boolean active) throws SQLException {
        String sql = "UPDATE review_scanners SET is_active = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, active ? 1 : 0);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    // ── Scan tracking ─────────────────────────────────────────────────────────

    /** Records a scan unless the same visitor scanned this sticker in the last 30 minutes. */
    public void recordScan(long scannerId, String visitorHash) {
        String sql =
            "INSERT INTO review_scans (scanner_id, visitor_hash) " +
            "SELECT ?, ? WHERE NOT EXISTS (" +
            "  SELECT 1 FROM review_scans WHERE scanner_id = ? AND visitor_hash = ? " +
            "  AND scanned_at > " + NOW_IST + " - INTERVAL '" + DEDUPE_MINUTES + " minutes')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setString(2, visitorHash);
            ps.setLong(3, scannerId);
            ps.setString(4, visitorHash);
            ps.executeUpdate();
        } catch (SQLException e) {
            // Non-critical — never block the redirect over analytics
        }
    }

    /** Records a trip to one app. Every tap counts — clicks are not de-duplicated (scans still are). */
    /** A tap on the scan page's WiFi button (shown as "WiFi" in the owner's analytics). */
    public void recordWifiTap(long scannerId, String visitorHash) {
        String sql = "INSERT INTO review_clicks (scanner_id, platform, visitor_hash) VALUES (?, 'WIFI', ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setString(2, visitorHash);
            ps.executeUpdate();
        } catch (SQLException e) {
            // Non-critical, same as recordClick
        }
    }

    public void recordClick(long scannerId, ReviewPlatform platform, String visitorHash) {
        String sql = "INSERT INTO review_clicks (scanner_id, platform, visitor_hash) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setString(2, platform.name());
            ps.setString(3, visitorHash);
            ps.executeUpdate();
        } catch (SQLException e) {
            // Non-critical — never block the redirect over analytics
        }
    }

    // ── Reports ───────────────────────────────────────────────────────────────

    /** Per-scanner report for one month: total scans, busiest weekday/2-hour block, trips per app. */
    public Map<Long, ReviewMonthlyReport> monthlyReports(YearMonth month) throws SQLException {
        String base =
            "FROM review_scans c JOIN review_scanners s ON s.id = c.scanner_id " +
            "WHERE s.assigned_at IS NOT NULL AND c.scanned_at >= s.assigned_at " +
            "  AND c.scanned_at >= ? AND c.scanned_at < ? ";
        // LocalDateTime binds as a plain wall-clock value, independent of the JVM time zone
        LocalDateTime from = month.atDay(1).atStartOfDay();
        LocalDateTime to   = month.plusMonths(1).atDay(1).atStartOfDay();

        Map<Long, ReviewMonthlyReport> reports = new HashMap<>();
        Map<Long, int[]> dowCounts  = new HashMap<>();   // index 1..7
        Map<Long, int[]> hourCounts = new HashMap<>();   // index 0..11 (2-hour blocks)

        String sql =
            "SELECT c.scanner_id, EXTRACT(ISODOW FROM c.scanned_at)::int AS dow, " +
            "       (EXTRACT(HOUR FROM c.scanned_at)::int / 2) AS block, COUNT(*) AS cnt " +
            base + "GROUP BY c.scanner_id, dow, block";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, from);
            ps.setObject(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    long id  = rs.getLong("scanner_id");
                    int  cnt = rs.getInt("cnt");
                    dowCounts.computeIfAbsent(id, k -> new int[8])[rs.getInt("dow")] += cnt;
                    hourCounts.computeIfAbsent(id, k -> new int[12])[rs.getInt("block")] += cnt;
                }
            }
        }

        for (Map.Entry<Long, int[]> e : dowCounts.entrySet()) {
            int[] dows   = e.getValue();
            int[] blocks = hourCounts.get(e.getKey());
            ReviewMonthlyReport r = new ReviewMonthlyReport();
            r.setTotalScans(Arrays.stream(dows).sum());
            r.setBusiestIsoDow(argMax(dows));
            r.setBusiestHourBlock(argMax(blocks) * 2);
            reports.put(e.getKey(), r);
        }

        String clickSql =
            "SELECT k.scanner_id, k.platform, COUNT(*) AS cnt " +
            "FROM review_clicks k JOIN review_scanners s ON s.id = k.scanner_id " +
            "WHERE s.assigned_at IS NOT NULL AND k.clicked_at >= s.assigned_at " +
            "  AND k.clicked_at >= ? AND k.clicked_at < ? GROUP BY k.scanner_id, k.platform";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(clickSql)) {
            ps.setObject(1, from);
            ps.setObject(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReviewMonthlyReport r = reports.get(rs.getLong("scanner_id"));
                    ReviewPlatform p = platformOrNull(rs.getString("platform"));
                    if (r != null && p != null) r.getClicks().put(p, rs.getInt("cnt"));
                }
            }
        }
        return reports;
    }

    /** Everything the owner's Analytics tab shows for one scanner and month. */
    public ReviewAnalytics analytics(ReviewScanner scanner, YearMonth month) throws SQLException {
        LocalDateTime from     = month.atDay(1).atStartOfDay();
        LocalDateTime to       = month.plusMonths(1).atDay(1).atStartOfDay();
        LocalDateTime prevFrom = month.minusMonths(1).atDay(1).atStartOfDay();
        // Scans from before this business got the sticker never count
        LocalDateTime since    = scanner.getAssignedAt() == null
                ? to : scanner.getAssignedAt().toLocalDateTime();

        int[] daily  = new int[month.lengthOfMonth()];
        int[] dow    = new int[7];
        int[] blocks = new int[12];
        int total = 0, previous = 0, wifiTaps = 0;
        Map<ReviewPlatform, Integer> clicks = new EnumMap<>(ReviewPlatform.class);

        String scanSql =
            "SELECT EXTRACT(DAY FROM scanned_at)::int AS d, EXTRACT(ISODOW FROM scanned_at)::int AS dow, " +
            "       EXTRACT(HOUR FROM scanned_at)::int / 2 AS block, COUNT(*) AS cnt " +
            "FROM review_scans WHERE scanner_id = ? AND scanned_at >= ? AND scanned_at >= ? AND scanned_at < ? " +
            "GROUP BY d, dow, block";
        String prevSql =
            "SELECT COUNT(*) FROM review_scans WHERE scanner_id = ? AND scanned_at >= ? " +
            "AND scanned_at >= ? AND scanned_at < ?";
        String clickSql =
            "SELECT platform, COUNT(*) AS cnt FROM review_clicks WHERE scanner_id = ? " +
            "AND clicked_at >= ? AND clicked_at >= ? AND clicked_at < ? GROUP BY platform";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(scanSql)) {
                bindRange(ps, scanner.getId(), since, from, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int cnt = rs.getInt("cnt");
                        daily[rs.getInt("d") - 1]  += cnt;
                        dow[rs.getInt("dow") - 1]  += cnt;
                        blocks[rs.getInt("block")] += cnt;
                        total += cnt;
                    }
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(prevSql)) {
                bindRange(ps, scanner.getId(), since, prevFrom, from);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) previous = rs.getInt(1);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(clickSql)) {
                bindRange(ps, scanner.getId(), since, from, to);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        if ("WIFI".equals(rs.getString("platform"))) { wifiTaps = rs.getInt("cnt"); continue; }
                        ReviewPlatform p = platformOrNull(rs.getString("platform"));
                        if (p != null) clicks.put(p, rs.getInt("cnt"));
                    }
                }
            }
        }

        String monthShort = month.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
        ReviewAnalytics a = new ReviewAnalytics(total, previous, daily, dow, blocks, clicks, scanner, monthShort);
        a.setWifiTaps(wifiTaps);
        return a;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private interface Binder { void bind(PreparedStatement ps) throws SQLException; }

    private ReviewScanner findOne(String sql, Binder binder) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            binder.bind(ps);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    private static void bindLinks(PreparedStatement ps, int start, Map<ReviewPlatform, String> links)
            throws SQLException {
        ps.setString(start,     links.get(ReviewPlatform.GOOGLE));
        ps.setString(start + 1, links.get(ReviewPlatform.INSTAGRAM));
        ps.setString(start + 2, links.get(ReviewPlatform.FACEBOOK));
        ps.setString(start + 3, links.get(ReviewPlatform.YOUTUBE));
        ps.setString(start + 4, links.get(ReviewPlatform.WHATSAPP));
    }

    /** scanner id, then "since assignment", then the [from, to) window. */
    private static void bindRange(PreparedStatement ps, long scannerId, LocalDateTime since,
                                  LocalDateTime from, LocalDateTime to) throws SQLException {
        ps.setLong(1, scannerId);
        ps.setObject(2, since);
        ps.setObject(3, from);
        ps.setObject(4, to);
    }

    private static ReviewPlatform platformOrNull(String name) {
        try {
            return ReviewPlatform.valueOf(name);
        } catch (IllegalArgumentException | NullPointerException e) {
            return null;
        }
    }

    private static int argMax(int[] arr) {
        int best = 0;
        for (int i = 1; i < arr.length; i++) if (arr[i] > arr[best]) best = i;
        return best;
    }

    private static String randomCode() {
        StringBuilder sb = new StringBuilder(CODE_LEN);
        for (int i = 0; i < CODE_LEN; i++) sb.append(CODE_CHARS.charAt(RANDOM.nextInt(CODE_CHARS.length())));
        return sb.toString();
    }

    private ReviewScanner mapRow(ResultSet rs) throws SQLException {
        ReviewScanner s = new ReviewScanner();
        s.setId(rs.getLong("id"));
        s.setCode(rs.getString("code"));
        s.setBusinessName(rs.getString("business_name"));
        s.setOwnerPhone(rs.getString("owner_phone"));
        s.setGoogleReviewUrl(rs.getString("google_review_url"));
        s.setInstagramUrl(rs.getString("instagram_url"));
        s.setFacebookUrl(rs.getString("facebook_url"));
        s.setYoutubeUrl(rs.getString("youtube_url"));
        s.setWhatsappUrl(rs.getString("whatsapp_url"));
        s.setLinkOrder(rs.getString("link_order"));
        s.setWifiName(rs.getString("wifi_name"));
        s.setWifiPassword(rs.getString("wifi_password"));
        long ownerId = rs.getLong("owner_id");
        s.setOwnerId(rs.wasNull() ? null : ownerId);
        s.setLoginPhone(rs.getString("login_phone"));
        s.setOwnerName(rs.getString("owner_name"));
        s.setActive(rs.getInt("is_active") == 1);
        s.setJoinForm(rs.getBoolean("join_form"));
        s.setStampAllowed(rs.getBoolean("stamp_allowed"));
        s.setScratchAllowed(rs.getBoolean("scratch_allowed"));
        s.setGeoCheck(rs.getBoolean("geo_check"));
        double lat = rs.getDouble("shop_lat");
        s.setShopLat(rs.wasNull() ? null : lat);
        double lng = rs.getDouble("shop_lng");
        s.setShopLng(rs.wasNull() ? null : lng);
        s.setAssignedAt(rs.getTimestamp("assigned_at"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        return s;
    }
}
