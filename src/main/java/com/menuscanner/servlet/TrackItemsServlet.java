package com.menuscanner.servlet;

import com.menuscanner.dao.AnalyticsDAO;
import com.menuscanner.dao.RestaurantDAO;
import com.menuscanner.model.Restaurant;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Public (no-auth) endpoint called fire-and-forget from the public menu page.
 * Records which item IDs were shown so we can build "most viewed" analytics.
 */
@WebServlet("/track-items")
public class TrackItemsServlet extends HttpServlet {

    private final AnalyticsDAO  analyticsDAO  = new AnalyticsDAO();
    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String slug     = req.getParameter("slug");
        String idsParam = req.getParameter("ids");

        if (slug == null || slug.isBlank() || idsParam == null || idsParam.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Restaurant restaurant = restaurantDAO.findBySlug(slug.trim().toLowerCase());
            if (restaurant == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            List<Long> itemIds = new ArrayList<>();
            for (String part : idsParam.split(",")) {
                try { itemIds.add(Long.parseLong(part.trim())); } catch (NumberFormatException ignored) {}
            }

            analyticsDAO.recordItemViews(restaurant.getId(), itemIds);
            resp.setStatus(HttpServletResponse.SC_NO_CONTENT);

        } catch (SQLException e) {
            getServletContext().log("Track items error", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
