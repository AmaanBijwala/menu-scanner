package com.menuscanner.servlet;

import com.menuscanner.dao.CustomerDAO;
import com.menuscanner.dao.MenuItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final MenuItemDAO menuItemDAO = new MenuItemDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");
        try {
            req.setAttribute("menuItemCount", menuItemDAO.countByRestaurantId(restaurantId));
            req.setAttribute("customerCount", customerDAO.countByRestaurantId(restaurantId));
        } catch (SQLException e) {
            getServletContext().log("Dashboard stats error", e);
        }
        String slug = (String) req.getSession().getAttribute("slug");
        String baseUrl = req.getScheme() + "://" + req.getServerName()
                + ":" + req.getServerPort() + req.getContextPath();
        req.setAttribute("publicMenuUrl", baseUrl + "/menu?slug=" + (slug != null ? slug : ""));
        req.getRequestDispatcher("/WEB-INF/views/admin-dashboard.jsp").forward(req, resp);
    }
}
