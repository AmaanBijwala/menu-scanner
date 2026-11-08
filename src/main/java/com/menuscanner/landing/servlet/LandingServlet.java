package com.menuscanner.landing.servlet;

import com.google.zxing.WriterException;
import com.menuscanner.landing.LandingProfile;
import com.menuscanner.landing.dao.FeedbackDAO;
import com.menuscanner.util.QRGenerator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Base64;
import java.util.List;

/**
 * Public landing page: services, about, live demo and contact.
 * nginx serves it at the site root (https://<domain>/) by proxying to /menu-scanner/home.
 */
@WebServlet("/home")
public class LandingServlet extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    private String demoMenuUrl;
    private String demoQrDataUri;

    @Override
    public void init() throws ServletException {
        demoMenuUrl = LandingProfile.APP_BASE_URL + "/menu?slug=" + LandingProfile.DEMO_MENU_SLUG;
        try {
            byte[] png = QRGenerator.generatePng(demoMenuUrl, 360);
            demoQrDataUri = "data:image/png;base64," + Base64.getEncoder().encodeToString(png);
        } catch (WriterException | IOException e) {
            throw new ServletException("Cannot build demo QR", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("demoMenuUrl",   demoMenuUrl);
        req.setAttribute("demoQrDataUri", demoQrDataUri);
        req.setAttribute("demoMenuName",  LandingProfile.DEMO_MENU_NAME);
        req.setAttribute("siteUrl",       LandingProfile.SITE_URL);
        req.setAttribute("name",          LandingProfile.NAME);
        req.setAttribute("title",         LandingProfile.TITLE);
        req.setAttribute("phoneE164",     LandingProfile.PHONE_E164);
        req.setAttribute("phoneDisplay",  LandingProfile.PHONE_DISPLAY);
        req.setAttribute("email",         LandingProfile.EMAIL);
        req.setAttribute("city",          LandingProfile.CITY);
        req.setAttribute("github",        LandingProfile.GITHUB);
        req.setAttribute("linkedin",      LandingProfile.LINKEDIN);
        req.setAttribute("brand",         LandingProfile.BRAND);
        req.setAttribute("instagram",     LandingProfile.INSTAGRAM);
        req.setAttribute("facebook",      LandingProfile.FACEBOOK);
        req.setAttribute("waChannel",     LandingProfile.WHATSAPP_CHANNEL);
        try {
            req.setAttribute("feedbacks", feedbackDAO.findVisible());
        } catch (SQLException e) {
            // Never break the landing page over feedback — the strip just stays hidden
            getServletContext().log("Feedback load failed", e);
            req.setAttribute("feedbacks", List.of());
        }
        // Revalidate every time so newly posted feedback shows up straight away
        resp.setHeader("Cache-Control", "no-cache");
        req.getRequestDispatcher("/WEB-INF/views/landing/home.jsp").forward(req, resp);
    }
}
