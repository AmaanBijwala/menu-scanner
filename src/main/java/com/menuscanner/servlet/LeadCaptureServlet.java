package com.menuscanner.servlet;

import com.menuscanner.dao.CustomerDAO;
import com.menuscanner.dao.RestaurantDAO;
import com.menuscanner.model.Customer;
import com.menuscanner.model.Restaurant;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Public endpoint — no authentication required.
 *
 * Called from the "Get Offers" modal on the public menu page.
 * Step 2 of the lead-capture flow (Step 1 is viewing the menu).
 *
 * POST /lead-capture
 * Params: slug, name, phone, age (optional), gender (optional), consentWhatsapp
 * Response: JSON  {"success": true}  or  {"error": "..."}
 */
@WebServlet("/lead-capture")
public class LeadCaptureServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private final CustomerDAO   customerDAO   = new CustomerDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        String slug    = req.getParameter("slug");
        String name    = req.getParameter("name");
        String phone   = req.getParameter("phone");
        String ageStr  = req.getParameter("age");
        String gender  = req.getParameter("gender");
        String consent = req.getParameter("consentWhatsapp");

        if (isBlank(slug) || isBlank(name) || isBlank(phone)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"slug, name, and phone are required.\"}");
            return;
        }

        try {
            Restaurant restaurant = restaurantDAO.findBySlug(slug.trim().toLowerCase());
            if (restaurant == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"error\":\"Restaurant not found.\"}");
                return;
            }

            Customer customer = new Customer();
            customer.setRestaurantId(restaurant.getId());
            customer.setName(name.trim());
            customer.setPhone(phone.trim());
            customer.setAge(ageStr != null && !ageStr.isBlank() ? Integer.parseInt(ageStr) : 0);
            customer.setGender(gender);
            customer.setConsentWhatsapp("true".equals(consent) || "on".equals(consent));

            customerDAO.save(customer);
            resp.getWriter().write("{\"success\":true}");

        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Invalid age value.\"}");
        } catch (SQLException e) {
            getServletContext().log("Lead capture error", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"System error. Please try again.\"}");
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
