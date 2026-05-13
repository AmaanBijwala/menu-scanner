package com.menuscanner.servlet;

import com.menuscanner.dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/customers")
public class CustomerServlet extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");
        try {
            req.setAttribute(   "customers", customerDAO.findByRestaurantId(restaurantId));
            req.setAttribute("customerCount", customerDAO.countByRestaurantId(restaurantId));
        } catch (SQLException e) {
            getServletContext().log("Customer list error", e);
            req.setAttribute("error", "Failed to load customers.");
        }
        req.getRequestDispatcher("/WEB-INF/views/customer-list.jsp").forward(req, resp);
    }
}
