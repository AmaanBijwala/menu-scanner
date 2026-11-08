package com.menuscanner.landing.servlet;

import com.menuscanner.landing.dao.EnquiryDAO;
import com.menuscanner.landing.model.Enquiry;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/** Super-admin list of landing page enquiries. Guarded by AdminAuthFilter (/admin/*). */
@WebServlet("/admin/enquiries")
public class AdminEnquiryServlet extends HttpServlet {

    private final EnquiryDAO enquiryDAO = new EnquiryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Enquiry> enquiries = enquiryDAO.findAll();
            req.setAttribute("enquiries", enquiries);
            req.setAttribute("newCount", enquiries.stream().filter(e -> "NEW".equals(e.getStatus())).count());
        } catch (SQLException e) {
            getServletContext().log("Enquiries load error", e);
            req.setAttribute("loadError", "Could not load enquiries: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/landing/admin-enquiries.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String redirect = req.getContextPath() + "/admin/enquiries";
        try {
            long id       = Long.parseLong(req.getParameter("id"));
            String status = "CONTACTED".equals(req.getParameter("status")) ? "CONTACTED" : "NEW";
            enquiryDAO.updateStatus(id, status);
            resp.sendRedirect(redirect);
        } catch (NumberFormatException e) {
            resp.sendRedirect(redirect + "?error=Invalid+ID");
        } catch (SQLException e) {
            getServletContext().log("Enquiry status update error", e);
            resp.sendRedirect(redirect + "?error=Could+not+update");
        }
    }
}
