package com.menuscanner.servlet;

import com.menuscanner.dao.RestaurantDAO;
import com.menuscanner.model.Restaurant;
import com.menuscanner.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet({"/admin/", "/admin/dashboard"})
public class AdminServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Restaurant> restaurants = restaurantDAO.findAll();
            long total    = restaurants.size();
            long proCount = restaurants.stream().filter(r -> "PRO".equals(r.getPlanType())).count();
            long active   = restaurants.stream().filter(Restaurant::isActive).count();
            req.setAttribute("restaurants", restaurants);
            req.setAttribute("totalCount",  total);
            req.setAttribute("proCount",    proCount);
            req.setAttribute("basicCount",  total - proCount);
            req.setAttribute("activeCount", active);
            req.setAttribute("inactiveCount", total - active);
        } catch (SQLException e) {
            getServletContext().log("Admin load error", e);
            req.setAttribute("loadError", "Could not load restaurants: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        String redirect = req.getContextPath() + "/admin/";

        try {
            switch (action == null ? "" : action) {

                case "add" -> {
                    String name     = req.getParameter("name");
                    String email    = req.getParameter("email");
                    String password = req.getParameter("password");
                    String phone    = req.getParameter("phone");
                    String plan     = req.getParameter("planType");

                    if (isBlank(name) || isBlank(email) || isBlank(password)) {
                        resp.sendRedirect(redirect + "?error=Name%2C+email+and+password+are+required");
                        return;
                    }
                    String slug = uniqueSlug(toSlug(name));
                    Restaurant r = new Restaurant();
                    r.setName(name.trim());
                    r.setSlug(slug);
                    r.setEmail(email.trim().toLowerCase());
                    r.setPasswordHash(PasswordUtil.hash(password));
                    r.setPhone(isBlank(phone) ? null : phone.trim());
                    r.setPlanType("PRO".equals(plan) ? "PRO" : "BASIC");
                    restaurantDAO.save(r);
                    resp.sendRedirect(redirect + "?success=Restaurant+added");
                }

                case "changePlan" -> {
                    long id      = Long.parseLong(req.getParameter("id"));
                    String plan  = req.getParameter("planType");
                    if (!"BASIC".equals(plan) && !"PRO".equals(plan)) {
                        resp.sendRedirect(redirect + "?error=Invalid+plan");
                        return;
                    }
                    restaurantDAO.updatePlan(id, plan);
                    resp.sendRedirect(redirect + "?success=Plan+updated");
                }

                case "toggleActive" -> {
                    long id      = Long.parseLong(req.getParameter("id"));
                    boolean active = "true".equals(req.getParameter("active"));
                    restaurantDAO.updateActive(id, active);
                    resp.sendRedirect(redirect + "?success=Status+updated");
                }

                case "editContact" -> {
                    long id    = Long.parseLong(req.getParameter("id"));
                    String name  = req.getParameter("name");
                    String email = req.getParameter("email");
                    String phone = req.getParameter("phone");
                    if (isBlank(name) || isBlank(email)) {
                        resp.sendRedirect(redirect + "?error=Name+and+email+are+required");
                        return;
                    }
                    restaurantDAO.updateContact(id, name.trim(), email.trim(), phone);
                    resp.sendRedirect(redirect + "?success=Restaurant+updated");
                }

                case "logout" -> {
                    var session = req.getSession(false);
                    if (session != null) session.invalidate();
                    resp.sendRedirect(req.getContextPath() + "/admin/login");
                }

                default -> resp.sendRedirect(redirect);
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(redirect + "?error=Invalid+ID");
        } catch (SQLException e) {
            getServletContext().log("Admin action error", e);
            resp.sendRedirect(redirect + "?error=" + encode(e.getMessage()));
        }
    }

    private String toSlug(String name) {
        return name.toLowerCase()
                   .replaceAll("[^a-z0-9\\s-]", "")
                   .trim()
                   .replaceAll("[\\s-]+", "-");
    }

    private String uniqueSlug(String base) throws SQLException {
        if (!restaurantDAO.slugExists(base)) return base;
        int i = 2;
        while (restaurantDAO.slugExists(base + "-" + i)) i++;
        return base + "-" + i;
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    private String encode(String s) {
        try {
            return java.net.URLEncoder.encode(s, "UTF-8");
        } catch (Exception e) {
            return "error";
        }
    }
}
