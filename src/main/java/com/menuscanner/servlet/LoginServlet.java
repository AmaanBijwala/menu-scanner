package com.menuscanner.servlet;

import com.menuscanner.dao.RestaurantDAO;
import com.menuscanner.model.Restaurant;
import com.menuscanner.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Already logged in → skip login page
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("restaurantId") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/public/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        if (isBlank(email) || isBlank(password)) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/public/login.jsp").forward(req, resp);
            return;
        }

        try {
            Restaurant restaurant = restaurantDAO.findByEmail(email.trim().toLowerCase());

            if (restaurant != null && PasswordUtil.verify(password, restaurant.getPasswordHash())) {
                // Invalidate any previous session before creating a new one (session fixation protection)
                HttpSession old = req.getSession(false);
                if (old != null) old.invalidate();

                HttpSession session = req.getSession(true);
                session.setAttribute("restaurantId",   restaurant.getId());
                session.setAttribute("restaurantName", restaurant.getName());
                session.setAttribute("planType",       restaurant.getPlanType());
                session.setAttribute("slug",           restaurant.getSlug());
                session.setMaxInactiveInterval(1_800); // 30 min

                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/public/login.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            getServletContext().log("Login error", e);
            req.setAttribute("error", "A system error occurred. Please try again.");
            req.getRequestDispatcher("/public/login.jsp").forward(req, resp);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
