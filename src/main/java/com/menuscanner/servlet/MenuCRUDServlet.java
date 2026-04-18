package com.menuscanner.servlet;

import com.menuscanner.dao.MenuItemDAO;
import com.menuscanner.model.MenuItem;
import com.menuscanner.util.PlanConfig;
import com.menuscanner.util.RedisCache;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

/**
 * Handles all menu item CRUD for the logged-in restaurant.
 *
 * GET  /menu-items          → list items → menu-manager.jsp
 * POST /menu-items?action=add    → create item (plan limit checked)
 * POST /menu-items?action=update → update item
 * POST /menu-items?action=delete → delete item
 *
 * Redis cache is invalidated after every write.
 */
@WebServlet("/menu-items")
public class MenuCRUDServlet extends HttpServlet {

    private final MenuItemDAO menuItemDAO = new MenuItemDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");
        String planType   = (String) req.getSession().getAttribute("planType");
        try {
            List<MenuItem> items = menuItemDAO.findByRestaurantId(restaurantId);
            req.setAttribute("menuItems",  items);
            req.setAttribute("itemCount",  items.size());
            req.setAttribute("maxItems",   PlanConfig.getMaxMenuItems(planType));
            req.setAttribute("planType",   planType);
        } catch (SQLException e) {
            getServletContext().log("MenuCRUD GET error", e);
            req.setAttribute("error", "Failed to load menu items.");
        }
        req.getRequestDispatcher("/WEB-INF/views/menu-manager.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long   restaurantId = (long)   req.getSession().getAttribute("restaurantId");
        String planType     = (String) req.getSession().getAttribute("planType");
        String action       = req.getParameter("action");

        try {
            switch (action != null ? action : "") {
                case "add"    -> handleAdd(req, resp, restaurantId, planType);
                case "update" -> handleUpdate(req, resp, restaurantId);
                case "delete" -> handleDelete(req, resp, restaurantId);
                default       -> resp.sendRedirect(req.getContextPath() + "/menu-items");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/menu-items?error=invalid_input");
        } catch (SQLException e) {
            getServletContext().log("MenuCRUD POST error", e);
            resp.sendRedirect(req.getContextPath() + "/menu-items?error=system_error");
        }
    }

    // ── Action handlers ───────────────────────────────────────────────────

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp,
                           long restaurantId, String planType)
            throws SQLException, IOException {
        int currentCount = menuItemDAO.countByRestaurantId(restaurantId);
        if (currentCount >= PlanConfig.getMaxMenuItems(planType)) {
            resp.sendRedirect(req.getContextPath() + "/menu-items?error=plan_limit_reached");
            return;
        }
        MenuItem item = buildFromRequest(req, restaurantId);
        menuItemDAO.save(item);
        RedisCache.invalidateMenu(restaurantId);
        resp.sendRedirect(req.getContextPath() + "/menu-items?success=added");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp,
                              long restaurantId)
            throws SQLException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/menu-items?error=missing_id");
            return;
        }
        MenuItem item = buildFromRequest(req, restaurantId);
        item.setId(Long.parseLong(idParam));
        menuItemDAO.update(item);
        RedisCache.invalidateMenu(restaurantId);
        resp.sendRedirect(req.getContextPath() + "/menu-items?success=updated");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp,
                              long restaurantId)
            throws SQLException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendRedirect(req.getContextPath() + "/menu-items?error=missing_id");
            return;
        }
        menuItemDAO.delete(Long.parseLong(idParam), restaurantId);
        RedisCache.invalidateMenu(restaurantId);
        resp.sendRedirect(req.getContextPath() + "/menu-items?success=deleted");
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    private MenuItem buildFromRequest(HttpServletRequest req, long restaurantId) {
        MenuItem item = new MenuItem();
        item.setRestaurantId(restaurantId);
        item.setName(req.getParameter("name"));
        item.setDescription(req.getParameter("description"));
        String priceStr = req.getParameter("price");
        item.setPrice(priceStr != null && !priceStr.isBlank()
                ? new BigDecimal(priceStr) : BigDecimal.ZERO);
        item.setCategory(req.getParameter("category"));
        item.setImagePath(req.getParameter("imagePath")); // set after upload, may be null on add
        item.setVeg(isTruthy(req.getParameter("isVeg")));
        item.setAvailable(isTruthy(req.getParameter("isAvailable")));
        String orderStr = req.getParameter("displayOrder");
        item.setDisplayOrder(orderStr != null && !orderStr.isBlank()
                ? Integer.parseInt(orderStr) : 0);
        return item;
    }

    private boolean isTruthy(String val) {
        return "on".equals(val) || "true".equals(val) || "1".equals(val);
    }
}
