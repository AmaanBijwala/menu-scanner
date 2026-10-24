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

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");
        try {
            Restaurant r = restaurantDAO.findById(restaurantId);
            req.setAttribute("restaurant", r);
            req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
        } catch (SQLException e) {
            getServletContext().log("Profile load error", e);
            resp.sendError(500);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");

        try {
            Restaurant r = restaurantDAO.findById(restaurantId);

            if ("social".equals(action)) {
                r.setName(trim(req.getParameter("name")));
                r.setPhone(trim(req.getParameter("phone")));
                r.setSocialWhatsapp(trim(req.getParameter("socialWhatsapp")));
                r.setSocialInstagram(trim(req.getParameter("socialInstagram")));
                r.setSocialFacebook(trim(req.getParameter("socialFacebook")));
                r.setSocialYoutube(trim(req.getParameter("socialYoutube")));
                restaurantDAO.update(r);

                // refresh session name in case it changed
                req.getSession().setAttribute("restaurantName", r.getName());
                req.setAttribute("success", "Profile updated successfully.");

            } else if ("password".equals(action)) {
                String current = req.getParameter("currentPassword");
                String newPwd  = req.getParameter("newPassword");
                String confirm = req.getParameter("confirmPassword");

                if (!PasswordUtil.verify(current, r.getPasswordHash())) {
                    req.setAttribute("pwdError", "Current password is incorrect.");
                } else if (newPwd == null || newPwd.length() < 8) {
                    req.setAttribute("pwdError", "New password must be at least 8 characters.");
                } else if (!newPwd.equals(confirm)) {
                    req.setAttribute("pwdError", "Passwords do not match.");
                } else {
                    restaurantDAO.updatePassword(restaurantId, PasswordUtil.hash(newPwd));
                    req.setAttribute("pwdSuccess", "Password changed successfully.");
                }
            }

            req.setAttribute("restaurant", restaurantDAO.findById(restaurantId));
            req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);

        } catch (SQLException e) {
            getServletContext().log("Profile update error", e);
            resp.sendError(500);
        }
    }

    private String trim(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}
