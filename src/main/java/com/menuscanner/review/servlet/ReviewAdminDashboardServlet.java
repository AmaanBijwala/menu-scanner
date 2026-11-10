package com.menuscanner.review.servlet;

import com.menuscanner.review.dao.ReviewScannerDAO;
import com.menuscanner.review.model.ReviewScanner;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * GET /admin/review-view?scanner={id}&tab=… — the super admin's read-only copy of any client's
 * owner dashboard (analytics, VIP Club list + CSV, offers sent, links). Guarded by AdminAuthFilter.
 *
 * It renders the same page as /review/dashboard with "adminView" set, which hides every form
 * (add VIP, send offers, save links, change password). POST is refused, so nothing a client
 * owns can be changed from here.
 */
@WebServlet("/admin/review-view")
public class ReviewAdminDashboardServlet extends ReviewOwnerDashboardServlet {

    private final ReviewScannerDAO allScanners = new ReviewScannerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<ReviewScanner> scanners = List.of();
        try {
            scanners = allScanners.findAll().stream().filter(ReviewScanner::isAssigned).toList();
        } catch (SQLException e) {
            getServletContext().log("Admin client view error", e);
            req.setAttribute("loadError", "Could not load the clients. Please refresh in a minute.");
        }
        req.setAttribute("adminView", true);
        resp.setHeader("Cache-Control", "no-store");
        render(req, resp, scanners, null);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "The admin view is read-only.");
    }
}
