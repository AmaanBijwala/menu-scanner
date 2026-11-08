package com.menuscanner.landing.servlet;

import com.menuscanner.landing.LandingRequests;
import com.menuscanner.landing.dao.FeedbackDAO;
import com.menuscanner.landing.model.Feedback;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Set;

/**
 * Client feedback from the landing page's "Share feedback" dialog.
 * Feedback is published exactly as submitted; the admin can only hide or delete it (spam/abuse).
 */
@WebServlet("/feedback")
public class FeedbackServlet extends HttpServlet {

    private static final Set<String> PRODUCTS = Set.of("MENU_QR", "REVIEW_QR", "CUSTOM");
    private static final int MAX_PER_HOUR = 3;

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");

        // Honeypot: hidden from people, filled by bots
        if (req.getParameter("website") != null && !req.getParameter("website").isBlank()) {
            reply(req, resp, HttpServletResponse.SC_OK, "Thank you for your feedback!");
            return;
        }

        String person   = LandingRequests.clip(req.getParameter("personName"), 100);
        String shop     = LandingRequests.clip(req.getParameter("shopName"), 200);
        String location = LandingRequests.clip(req.getParameter("location"), 120);
        String product  = req.getParameter("product");
        String comment  = LandingRequests.clip(req.getParameter("comment"), 600);

        if (person == null || shop == null || comment == null || !PRODUCTS.contains(product)) {
            reply(req, resp, HttpServletResponse.SC_BAD_REQUEST,
                    "Please fill in your name, shop name, product and comments.");
            return;
        }
        if (comment.length() < 5) {
            reply(req, resp, HttpServletResponse.SC_BAD_REQUEST, "Please write a little more in your comments.");
            return;
        }

        String visitor = LandingRequests.visitorHash(req);
        try {
            if (feedbackDAO.countRecentByVisitor(visitor) >= MAX_PER_HOUR) {
                reply(req, resp, 429, "You've already shared feedback recently. Thank you!");
                return;
            }
            Feedback f = new Feedback();
            f.setPersonName(person);
            f.setShopName(shop);
            f.setLocation(location);
            f.setProduct(product);
            f.setComment(comment);
            feedbackDAO.save(f, visitor);
        } catch (SQLException e) {
            getServletContext().log("Feedback save failed", e);
            reply(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Something went wrong. Please try again.");
            return;
        }
        reply(req, resp, HttpServletResponse.SC_OK, "Thank you, " + person + "! Your feedback is now live.");
    }

    private void reply(HttpServletRequest req, HttpServletResponse resp, int status, String text) throws IOException {
        if (LandingRequests.isFetch(req)) {
            resp.setStatus(status);
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().write(text);
        } else {
            resp.sendRedirect(req.getContextPath() + "/home" + (status == 200 ? "#feedback" : "#contact"));
        }
    }
}
