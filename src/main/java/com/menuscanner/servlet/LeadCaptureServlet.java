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

        if (isBlank(slug)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Invalid request.\"}");
            return;
        }
        if (isBlank(name) || isBlank(phone)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Name and phone number are required.\"}");
            return;
        }
        name = name.trim();
        if (name.length() > 100) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Name is too long.\"}");
            return;
        }
        phone = normalizePhone(phone);
        if (phone == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Please enter a valid 10-digit mobile number.\"}");
            return;
        }
        int age = 0;
        if (!isBlank(ageStr)) {
            try { age = Integer.parseInt(ageStr.trim()); } catch (NumberFormatException e) { age = -1; }
            if (age < 1 || age > 120) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"error\":\"Please enter a valid age.\"}");
                return;
            }
        }
        if (!"Male".equals(gender) && !"Female".equals(gender) && !"Other".equals(gender)) gender = null;

        try {
            Restaurant restaurant = restaurantDAO.findBySlug(slug.trim().toLowerCase());
            if (restaurant == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"error\":\"Restaurant not found.\"}");
                return;
            }

            // Same number again (double tap, or a repeat visit): already on the list, don't add a duplicate lead
            if (customerDAO.existsByPhone(restaurant.getId(), phone)) {
                resp.getWriter().write("{\"success\":true,\"already\":true}");
                return;
            }

            Customer customer = new Customer();
            customer.setRestaurantId(restaurant.getId());
            customer.setName(name);
            customer.setPhone(phone);
            customer.setAge(age);
            customer.setGender(gender);
            customer.setConsentWhatsapp("true".equals(consent) || "on".equals(consent));

            customerDAO.save(customer);
            resp.getWriter().write("{\"success\":true}");

        } catch (SQLException e) {
            getServletContext().log("Lead capture error", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"System error. Please try again.\"}");
        }
    }

    /** Indian mobile number as 10 digits (drops spaces, dashes, +91 / 0 prefix), or null if invalid. */
    private static String normalizePhone(String raw) {
        String d = raw.replaceAll("\\D", "");
        if (d.length() == 12 && d.startsWith("91")) d = d.substring(2);
        else if (d.length() == 11 && d.startsWith("0")) d = d.substring(1);
        return d.matches("[6-9]\\d{9}") ? d : null;
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
