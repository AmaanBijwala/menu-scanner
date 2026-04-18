package com.menuscanner.servlet;

import com.google.gson.Gson;
import com.menuscanner.dao.MenuItemDAO;
import com.menuscanner.dao.RestaurantDAO;
import com.menuscanner.model.MenuItem;
import com.menuscanner.model.Restaurant;
import com.menuscanner.util.RedisCache;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

/**
 * Public endpoint — no authentication required.
 *
 * Flow:
 *   GET /menu?slug=sharma-dhaba
 *   1. Resolve slug → restaurant
 *   2. Check Redis cache for "menu:{id}"
 *   3. On cache miss: load from DB, store in Redis (TTL 1h)
 *   4. Forward to /public/menu.jsp
 */
@WebServlet("/menu")
public class PublicMenuServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private final MenuItemDAO   menuItemDAO   = new MenuItemDAO();
    private final Gson          gson          = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String slug = req.getParameter("slug");
        if (slug == null || slug.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing slug parameter.");
            return;
        }

        try {
            Restaurant restaurant = restaurantDAO.findBySlug(slug.trim().toLowerCase());
            if (restaurant == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Redis cache-aside
            List<MenuItem> items;
            String cachedJson = RedisCache.getMenu(restaurant.getId());
            if (cachedJson != null) {
                items = Arrays.asList(gson.fromJson(cachedJson, MenuItem[].class));
            } else {
                items = menuItemDAO.findByRestaurantId(restaurant.getId());
                RedisCache.setMenu(restaurant.getId(), gson.toJson(items));
            }

            req.setAttribute("restaurant", restaurant);
            req.setAttribute("menuItems",  items);
            req.getRequestDispatcher("/public/menu.jsp").forward(req, resp);

        } catch (SQLException e) {
            getServletContext().log("Public menu error", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
