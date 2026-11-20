package com.menuscanner.review.dao;

import com.menuscanner.dao.DBConnection;
import com.menuscanner.review.model.ReviewScanner;
import com.menuscanner.review.model.ReviewScratchCampaign;
import com.menuscanner.review.model.ReviewScratchCampaign.Play;
import com.menuscanner.review.model.ReviewScratchCampaign.Slab;
import com.menuscanner.review.model.ReviewStampProgram;

import java.security.SecureRandom;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Rewards on the scan page: WhatsApp number verification, the digital stamp card and the
 * scratch card. "Today" is the IST calendar day; stamps and scratches made before the sticker's
 * current assigned_at belong to a previous business and are never read.
 */
public class ReviewRewardsDAO {

    private static final String NOW_IST   = "(NOW() AT TIME ZONE 'Asia/Kolkata')";
    private static final String TODAY_IST = "(NOW() AT TIME ZONE 'Asia/Kolkata')::date";

    /** No 0/O, 1/I/L, so a code is easy to read out at the counter. */
    private static final String CODE_CHARS = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";
    private static final SecureRandom RANDOM = new SecureRandom();

    /** A "VERIFY <token>" message must arrive within this many minutes of opening the page. */
    public static final int VERIFY_MINUTES = 15;

    // ── WhatsApp verification ───────────────────────────────────────────────

    /** Starts a verification for this browser; returns the token the customer sends on WhatsApp. */
    public String createVerification(long scannerId, String browserKey) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement del = conn.prepareStatement(
                    "DELETE FROM review_verifications WHERE created_at < " + NOW_IST + " - INTERVAL '2 days'")) {
                del.executeUpdate();   // housekeeping: old tokens are useless
            }
            String sql = "INSERT INTO review_verifications (token, scanner_id, browser_key) VALUES (?, ?, ?) ON CONFLICT DO NOTHING";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (int i = 0; i < 10; i++) {
                    String token = randomCode(6);
                    ps.setString(1, token);
                    ps.setLong(2, scannerId);
                    ps.setString(3, browserKey);
                    if (ps.executeUpdate() == 1) return token;
                }
            }
        }
        throw new SQLException("Could not create a verification token");
    }

    /** Called by the WhatsApp webhook. True if the token was waiting and is now verified for that phone. */
    public boolean markVerified(String token, String phone) throws SQLException {
        String sql = "UPDATE review_verifications SET phone = ?, verified_at = " + NOW_IST + " " +
                     "WHERE token = ? AND verified_at IS NULL AND created_at > " + NOW_IST + " - INTERVAL '" + VERIFY_MINUTES + " minutes'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setString(2, token);
            return ps.executeUpdate() == 1;
        }
    }

    /** The verified phone for this browser's token, or null while the customer hasn't sent it yet. */
    public String verifiedPhone(String token, long scannerId, String browserKey) throws SQLException {
        String sql = "SELECT phone FROM review_verifications WHERE token = ? AND scanner_id = ? AND browser_key = ? AND verified_at IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.setLong(2, scannerId);
            ps.setString(3, browserKey);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    /** The customer's name if they are already in this sticker's VIP Club (then the form is skipped). */
    public String contactName(ReviewScanner scanner, String phone) throws SQLException {
        String sql = "SELECT name FROM review_contacts WHERE scanner_id = ? AND phone = ? AND created_at >= ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scanner.getId());
            ps.setString(2, phone);
            ps.setObject(3, scanner.getAssignedAt().toLocalDateTime());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString(1) : null;
            }
        }
    }

    // ── Stamp card ──────────────────────────────────────────────────────────

    public ReviewStampProgram findProgram(long scannerId) throws SQLException {
        String sql = "SELECT * FROM review_stamp_programs WHERE scanner_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ReviewStampProgram p = new ReviewStampProgram();
                p.setScannerId(scannerId);
                p.setStampsNeeded(rs.getInt("stamps_needed"));
                p.setReward(rs.getString("reward"));
                p.setActive(rs.getBoolean("active"));
                return p;
            }
        }
    }

    public void saveProgram(long scannerId, int stampsNeeded, String reward, boolean active) throws SQLException {
        String sql = "INSERT INTO review_stamp_programs (scanner_id, stamps_needed, reward, active) VALUES (?, ?, ?, ?) " +
                     "ON CONFLICT (scanner_id) DO UPDATE SET stamps_needed = EXCLUDED.stamps_needed, reward = EXCLUDED.reward, " +
                     "  active = EXCLUDED.active, updated_at = " + NOW_IST;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setInt(2, stampsNeeded);
            ps.setString(3, reward);
            ps.setBoolean(4, active);
            ps.executeUpdate();
        }
    }

    /**
     * Gives today's stamp. Nothing is added when the customer already has one today, or when
     * the card is already full (they should claim the reward first).
     */
    public ReviewStampProgram.Result collectStamp(ReviewScanner scanner, ReviewStampProgram program, String phone)
            throws SQLException {
        ReviewStampProgram.Result r = new ReviewStampProgram.Result();
        r.setNeeded(program.getStampsNeeded());
        r.setReward(program.getReward());
        try (Connection conn = DBConnection.getConnection()) {
            int count = openStampCount(conn, scanner, phone);
            boolean today = hasStampToday(conn, scanner.getId(), phone);
            if (today) {
                r.setAlready(true);
            } else if (count < program.getStampsNeeded()) {
                String sql = "INSERT INTO review_stamps (scanner_id, phone, stamped_on) VALUES (?, ?, " + TODAY_IST + ") " +
                             "ON CONFLICT (scanner_id, phone, stamped_on) DO NOTHING";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, scanner.getId());
                    ps.setString(2, phone);
                    if (ps.executeUpdate() == 1) {
                        r.setAdded(true);
                        count++;
                    } else {
                        r.setAlready(true);          // a second tap in the same moment
                    }
                }
            }
            r.setCount(count);
        }
        return r;
    }

    private int openStampCount(Connection conn, ReviewScanner scanner, String phone) throws SQLException {
        String sql = "SELECT COUNT(*) FROM review_stamps WHERE scanner_id = ? AND phone = ? AND redeemed_at IS NULL AND created_at >= ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scanner.getId());
            ps.setString(2, phone);
            ps.setObject(3, scanner.getAssignedAt().toLocalDateTime());
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    /** True even for a stamp that was redeemed today: one stamp a day, full stop. */
    private boolean hasStampToday(Connection conn, long scannerId, String phone) throws SQLException {
        String sql = "SELECT 1 FROM review_stamps WHERE scanner_id = ? AND phone = ? AND stamped_on = " + TODAY_IST;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setString(2, phone);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** Every customer with stamps on their current card, full cards first. */
    public List<ReviewStampProgram.Card> openCards(ReviewScanner scanner, int needed) throws SQLException {
        String sql =
            "SELECT st.phone, c.name, st.stamped_on FROM review_stamps st " +
            "LEFT JOIN review_contacts c ON c.scanner_id = st.scanner_id AND c.phone = st.phone " +
            "WHERE st.scanner_id = ? AND st.redeemed_at IS NULL AND st.created_at >= ? " +
            "ORDER BY st.phone, st.stamped_on";
        Map<String, ReviewStampProgram.Card> byPhone = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scanner.getId());
            ps.setObject(2, scanner.getAssignedAt().toLocalDateTime());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String phone = rs.getString("phone");
                    ReviewStampProgram.Card card = byPhone.get(phone);
                    if (card == null) {
                        card = new ReviewStampProgram.Card();
                        card.setPhone(phone);
                        card.setName(rs.getString("name"));
                        card.setNeeded(needed);
                        byPhone.put(phone, card);
                    }
                    card.getDates().add(rs.getDate("stamped_on"));
                }
            }
        }
        List<ReviewStampProgram.Card> cards = new ArrayList<>(byPhone.values());
        cards.sort((a, b) -> b.getCount() != a.getCount()
                ? Integer.compare(b.getCount(), a.getCount())
                : b.getDates().get(b.getCount() - 1).compareTo(a.getDates().get(a.getCount() - 1)));
        return cards;
    }

    /** Owner gave the reward: the card starts again from 0. Returns false if the card wasn't full. */
    public boolean redeemStamps(ReviewScanner scanner, String phone, int needed) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            if (openStampCount(conn, scanner, phone) < needed) return false;
            String sql = "UPDATE review_stamps SET redeemed_at = " + NOW_IST + " " +
                         "WHERE scanner_id = ? AND phone = ? AND redeemed_at IS NULL AND created_at >= ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, scanner.getId());
                ps.setString(2, phone);
                ps.setObject(3, scanner.getAssignedAt().toLocalDateTime());
                return ps.executeUpdate() > 0;
            }
        }
    }

    /** Stamps given today and rewards handed out in total, for the owner's tab. */
    public int[] stampStats(ReviewScanner scanner) throws SQLException {
        String sql = "SELECT COUNT(*) FILTER (WHERE stamped_on = " + TODAY_IST + "), " +
                     "       COUNT(DISTINCT (phone, redeemed_at)) FILTER (WHERE redeemed_at IS NOT NULL) " +
                     "FROM review_stamps WHERE scanner_id = ? AND created_at >= ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scanner.getId());
            ps.setObject(2, scanner.getAssignedAt().toLocalDateTime());
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return new int[] {rs.getInt(1), rs.getInt(2)};
            }
        }
    }

    // ── Scratch card ────────────────────────────────────────────────────────

    public ReviewScratchCampaign activeCampaign(long scannerId) throws SQLException {
        String sql = "SELECT * FROM review_scratch_campaigns WHERE scanner_id = ? AND active";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                ReviewScratchCampaign c = new ReviewScratchCampaign();
                c.setId(rs.getLong("id"));
                c.setScannerId(scannerId);
                c.setMode(rs.getString("mode"));
                c.setWinPercent(rs.getInt("win_percent"));
                c.setActive(true);
                c.setCreatedAt(rs.getTimestamp("created_at"));
                loadDetails(conn, c);
                return c;
            }
        }
    }

    private void loadDetails(Connection conn, ReviewScratchCampaign c) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM review_scratch_slabs WHERE campaign_id = ? ORDER BY amount, id")) {
            ps.setLong(1, c.getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Slab s = new Slab();
                    s.setId(rs.getLong("id"));
                    s.setAmount(rs.getInt("amount"));
                    s.setMinBill(rs.getInt("min_bill"));
                    s.setTotalCount(rs.getInt("total_count"));
                    s.setRemaining(rs.getInt("remaining"));
                    c.getSlabs().add(s);
                }
            }
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT text FROM review_scratch_offers WHERE campaign_id = ? ORDER BY id")) {
            ps.setLong(1, c.getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) c.getOffers().add(rs.getString(1));
            }
        }
    }

    /** Ends the current campaign (if any) and starts this one. */
    public void startCampaign(long scannerId, String mode, int winPercent, List<Slab> slabs, List<String> offers)
            throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                endActive(conn, scannerId);
                long id;
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO review_scratch_campaigns (scanner_id, mode, win_percent) VALUES (?, ?, ?) RETURNING id")) {
                    ps.setLong(1, scannerId);
                    ps.setString(2, mode);
                    ps.setInt(3, winPercent);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        id = rs.getLong(1);
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO review_scratch_slabs (campaign_id, amount, min_bill, total_count, remaining) VALUES (?, ?, ?, ?, ?)")) {
                    for (Slab s : slabs) {
                        ps.setLong(1, id);
                        ps.setInt(2, s.getAmount());
                        ps.setInt(3, s.getMinBill());
                        ps.setInt(4, s.getTotalCount());
                        ps.setInt(5, s.getTotalCount());
                        ps.addBatch();
                    }
                    if (!slabs.isEmpty()) ps.executeBatch();
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO review_scratch_offers (campaign_id, text) VALUES (?, ?)")) {
                    for (String o : offers) {
                        ps.setLong(1, id);
                        ps.setString(2, o);
                        ps.addBatch();
                    }
                    if (!offers.isEmpty()) ps.executeBatch();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public void stopCampaign(long scannerId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            endActive(conn, scannerId);
        }
    }

    private void endActive(Connection conn, long scannerId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE review_scratch_campaigns SET active = FALSE, ended_at = " + NOW_IST + " WHERE scanner_id = ? AND active")) {
            ps.setLong(1, scannerId);
            ps.executeUpdate();
        }
    }

    /** Today's scratch for this phone, if any (shown again instead of a new one). */
    public Play todaysPlay(long scannerId, String phone) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            return todaysPlay(conn, scannerId, phone);
        }
    }

    private Play todaysPlay(Connection conn, long scannerId, String phone) throws SQLException {
        String sql = "SELECT * FROM review_scratch_plays WHERE scanner_id = ? AND phone = ? AND played_on = " + TODAY_IST;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setString(2, phone);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Play p = mapPlay(rs);
                p.setAlready(true);
                return p;
            }
        }
    }

    /**
     * Draws today's scratch. AMOUNT: a win needs the win chance to come up AND a slab with
     * prizes left whose minimum bill the customer's bill reaches; the slab is picked weighted by
     * how many prizes it has left (so small prizes come up more often and the budget lasts).
     * The slab count goes down in the same transaction, so the budget can never be overspent.
     * OFFER: always shows one of the offers, picked at random.
     */
    public Play play(long scannerId, long campaignId, String phone, Integer bill) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                ReviewScratchCampaign c;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT * FROM review_scratch_campaigns WHERE id = ? AND scanner_id = ? AND active FOR UPDATE")) {
                    ps.setLong(1, campaignId);
                    ps.setLong(2, scannerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) { conn.rollback(); return null; }
                        c = new ReviewScratchCampaign();
                        c.setId(campaignId);
                        c.setMode(rs.getString("mode"));
                        c.setWinPercent(rs.getInt("win_percent"));
                    }
                }
                Play existing = todaysPlay(conn, scannerId, phone);
                if (existing != null) { conn.rollback(); return existing; }
                loadDetails(conn, c);

                Play p = new Play();
                p.setPhone(phone);
                p.setBillAmount(bill);
                Slab prize = null;
                if (c.isAmountMode()) {
                    List<Slab> eligible = new ArrayList<>();
                    int pool = 0;
                    for (Slab s : c.getSlabs()) {
                        if (s.getRemaining() > 0 && bill != null && bill >= s.getMinBill()) {
                            eligible.add(s);
                            pool += s.getRemaining();
                        }
                    }
                    if (pool > 0 && RANDOM.nextInt(100) < c.getWinPercent()) {
                        int pick = RANDOM.nextInt(pool);
                        for (Slab s : eligible) {
                            pick -= s.getRemaining();
                            if (pick < 0) { prize = s; break; }
                        }
                    }
                    if (prize != null) {
                        try (PreparedStatement ps = conn.prepareStatement(
                                "UPDATE review_scratch_slabs SET remaining = remaining - 1 WHERE id = ? AND remaining > 0")) {
                            ps.setLong(1, prize.getId());
                            if (ps.executeUpdate() != 1) prize = null;
                        }
                    }
                    if (prize != null) {
                        p.setWon(true);
                        p.setAmount(prize.getAmount());
                    }
                } else if (!c.getOffers().isEmpty()) {
                    p.setWon(true);
                    p.setOfferText(c.getOffers().get(RANDOM.nextInt(c.getOffers().size())));
                }
                if (p.isWon()) p.setCode(uniquePlayCode(conn));

                String sql = "INSERT INTO review_scratch_plays (scanner_id, campaign_id, phone, played_on, bill_amount, won, slab_id, amount, offer_text, code) " +
                             "VALUES (?, ?, ?, " + TODAY_IST + ", ?, ?, ?, ?, ?, ?) RETURNING id, created_at";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, scannerId);
                    ps.setLong(2, campaignId);
                    ps.setString(3, phone);
                    if (bill == null) ps.setNull(4, Types.INTEGER); else ps.setInt(4, bill);
                    ps.setBoolean(5, p.isWon());
                    if (prize == null) ps.setNull(6, Types.BIGINT); else ps.setLong(6, prize.getId());
                    if (p.getAmount() == null) ps.setNull(7, Types.INTEGER); else ps.setInt(7, p.getAmount());
                    ps.setString(8, p.getOfferText());
                    ps.setString(9, p.getCode());
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        p.setId(rs.getLong(1));
                        p.setCreatedAt(rs.getTimestamp(2));
                    }
                }
                conn.commit();
                return p;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private String uniquePlayCode(Connection conn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM review_scratch_plays WHERE code = ?")) {
            for (int i = 0; i < 10; i++) {
                String code = randomCode(6);
                ps.setString(1, code);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return code;
                }
            }
        }
        throw new SQLException("Could not create a scratch code");
    }

    /** Latest scratches of the current campaign, with the customer's name. */
    public List<Play> recentPlays(long scannerId, long campaignId, int limit) throws SQLException {
        String sql =
            "SELECT p.*, c.name FROM review_scratch_plays p " +
            "LEFT JOIN review_contacts c ON c.scanner_id = p.scanner_id AND c.phone = p.phone " +
            "WHERE p.scanner_id = ? AND p.campaign_id = ? ORDER BY p.created_at DESC LIMIT ?";
        List<Play> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setLong(2, campaignId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Play p = mapPlay(rs);
                    p.setName(rs.getString("name"));
                    list.add(p);
                }
            }
        }
        return list;
    }

    /** Scratches today / wins today, for the owner's tab. */
    public int[] scratchStatsToday(long scannerId, long campaignId) throws SQLException {
        String sql = "SELECT COUNT(*), COUNT(*) FILTER (WHERE won) FROM review_scratch_plays " +
                     "WHERE scanner_id = ? AND campaign_id = ? AND played_on = " + TODAY_IST;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setLong(2, campaignId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return new int[] {rs.getInt(1), rs.getInt(2)};
            }
        }
    }

    /** The winning scratch with this code on this sticker, or null. */
    public Play findPlayByCode(long scannerId, String code) throws SQLException {
        String sql = "SELECT p.*, c.name FROM review_scratch_plays p " +
                     "LEFT JOIN review_contacts c ON c.scanner_id = p.scanner_id AND c.phone = p.phone " +
                     "WHERE p.scanner_id = ? AND p.code = ? AND p.won";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setString(2, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Play p = mapPlay(rs);
                p.setName(rs.getString("name"));
                return p;
            }
        }
    }

    /** Marks a winning code as given at the counter. False if it was already used. */
    public boolean redeemPlay(long scannerId, String code) throws SQLException {
        String sql = "UPDATE review_scratch_plays SET redeemed_at = " + NOW_IST + " " +
                     "WHERE scanner_id = ? AND code = ? AND won AND redeemed_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, scannerId);
            ps.setString(2, code);
            return ps.executeUpdate() == 1;
        }
    }

    private static Play mapPlay(ResultSet rs) throws SQLException {
        Play p = new Play();
        p.setId(rs.getLong("id"));
        p.setPhone(rs.getString("phone"));
        int bill = rs.getInt("bill_amount");
        p.setBillAmount(rs.wasNull() ? null : bill);
        p.setWon(rs.getBoolean("won"));
        int amount = rs.getInt("amount");
        p.setAmount(rs.wasNull() ? null : amount);
        p.setOfferText(rs.getString("offer_text"));
        p.setCode(rs.getString("code"));
        p.setRedeemedAt(rs.getTimestamp("redeemed_at"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        return p;
    }

    private static String randomCode(int len) {
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) sb.append(CODE_CHARS.charAt(RANDOM.nextInt(CODE_CHARS.length())));
        return sb.toString();
    }
}
