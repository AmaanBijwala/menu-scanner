package com.menuscanner.review.servlet;

import com.menuscanner.review.dao.ReviewScannerDAO;
import com.menuscanner.review.model.ReviewScanner;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Printable A4 sheet of review stickers.
 * ?ids=1,2,3  → those scanners
 * ?ids=unassigned (default) → every scanner not yet given to a business
 */
@WebServlet("/admin/review-scanners/print")
public class ReviewPrintServlet extends HttpServlet {

    private final ReviewScannerDAO scannerDAO = new ReviewScannerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String ids = req.getParameter("ids");
        try {
            List<ReviewScanner> all = scannerDAO.findAll();
            List<ReviewScanner> selected;
            if (ids == null || ids.isBlank() || "unassigned".equals(ids)) {
                selected = all.stream().filter(s -> !s.isAssigned()).collect(Collectors.toList());
            } else {
                Set<Long> wanted = new HashSet<>();
                for (String part : ids.split(",")) {
                    try { wanted.add(Long.parseLong(part.trim())); } catch (NumberFormatException ignored) { }
                }
                selected = all.stream().filter(s -> wanted.contains(s.getId())).collect(Collectors.toList());
            }
            req.setAttribute("scanners", selected);
        } catch (SQLException e) {
            getServletContext().log("Review print load error", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/review/print-stickers.jsp").forward(req, resp);
    }
}
