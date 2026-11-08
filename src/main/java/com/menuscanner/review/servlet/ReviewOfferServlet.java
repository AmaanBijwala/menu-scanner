package com.menuscanner.review.servlet;

import com.menuscanner.review.ReviewConfig;
import com.menuscanner.review.dao.ReviewBroadcastDAO;
import com.menuscanner.review.model.ReviewBroadcast;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

/**
 * GET /o/{code} — public page for a WhatsApp offer that has a photo (whitelisted in AuthFilter).
 *
 * WhatsApp click-to-chat links can only carry text, so the offer message ends with this page's
 * link; WhatsApp reads its og:image / og:title and shows the photo as a big preview card.
 * "{name}" in the saved message becomes "there", because the page is the same for everyone.
 */
@WebServlet("/o/*")
public class ReviewOfferServlet extends HttpServlet {

    private final ReviewBroadcastDAO broadcastDAO = new ReviewBroadcastDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pi = req.getPathInfo();
        String code = pi == null ? "" : pi.replaceAll("^/|/$", "").toUpperCase();
        if (!code.matches("[A-Z0-9]{4,12}")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        try {
            ReviewBroadcast offer = broadcastDAO.findByCode(code);
            if (offer == null || offer.getImagePath() == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            String text = offer.getMessage().replaceAll("(?i)\\{name\\}", "there");
            req.setAttribute("offer",        offer);
            req.setAttribute("offerText",    text);
            req.setAttribute("imageUrl",     ReviewConfig.imageUrl(offer.getImagePath()));
            req.setAttribute("pageUrl",      ReviewConfig.offerUrl(code));
            req.setAttribute("previewText",  text.length() > 180 ? text.substring(0, 177) + "..." : text);
            resp.setHeader("Cache-Control", "public, max-age=300");
            req.getRequestDispatcher("/WEB-INF/views/review/offer.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Offer page error for " + code, e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
