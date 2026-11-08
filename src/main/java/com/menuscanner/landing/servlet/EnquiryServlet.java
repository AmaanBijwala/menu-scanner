package com.menuscanner.landing.servlet;

import com.menuscanner.landing.LandingRequests;
import com.menuscanner.landing.dao.EnquiryDAO;
import com.menuscanner.landing.model.Enquiry;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Set;

/**
 * Landing page contact form. The page submits with fetch() and reads a plain-text reply;
 * without JavaScript the browser gets redirected back to the page instead.
 */
@WebServlet("/enquiry")
public class EnquiryServlet extends HttpServlet {

    private static final Set<String> INTERESTS = Set.of("MENU_QR", "REVIEW_QR", "CUSTOM", "OTHER");
    private static final int MAX_PER_HOUR = 5;

    private final EnquiryDAO enquiryDAO = new EnquiryDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");

        // Honeypot: real people never see or fill this field; bots fill every field
        if (req.getParameter("website") != null && !req.getParameter("website").isBlank()) {
            reply(req, resp, HttpServletResponse.SC_OK, "Thanks! I'll get back to you soon.");
            return;
        }

        String name     = LandingRequests.clip(req.getParameter("name"), 100);
        String phone    = LandingRequests.clip(req.getParameter("phone"), 20);
        String business = LandingRequests.clip(req.getParameter("businessName"), 200);
        String interest = req.getParameter("interest");
        String message  = LandingRequests.clip(req.getParameter("message"), 1000);

        if (name == null || phone == null) {
            reply(req, resp, HttpServletResponse.SC_BAD_REQUEST, "Please enter your name and phone number.");
            return;
        }
        if (phone.replaceAll("\\D", "").length() < 10) {
            reply(req, resp, HttpServletResponse.SC_BAD_REQUEST, "Please enter a valid phone number.");
            return;
        }

        String visitor = LandingRequests.visitorHash(req);
        try {
            if (enquiryDAO.countRecentByVisitor(visitor) >= MAX_PER_HOUR) {
                reply(req, resp, 429, "You've already sent a few messages. Please WhatsApp me directly.");
                return;
            }
            Enquiry e = new Enquiry();
            e.setName(name);
            e.setPhone(phone);
            e.setBusinessName(business);
            e.setInterest(INTERESTS.contains(interest) ? interest : "OTHER");
            e.setMessage(message);
            enquiryDAO.save(e, visitor);
        } catch (SQLException ex) {
            getServletContext().log("Enquiry save failed", ex);
            reply(req, resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Something went wrong. Please WhatsApp me directly.");
            return;
        }
        reply(req, resp, HttpServletResponse.SC_OK, "Thanks, " + name + "! I'll call or WhatsApp you soon.");
    }

    private void reply(HttpServletRequest req, HttpServletResponse resp, int status, String text) throws IOException {
        if (LandingRequests.isFetch(req)) {
            resp.setStatus(status);
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().write(text);
        } else {
            resp.sendRedirect(req.getContextPath() + "/home" + (status == 200 ? "?sent=1" : "?error=1") + "#contact");
        }
    }
}
