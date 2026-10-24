package com.menuscanner.servlet;

import com.menuscanner.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    private String adminEmail;
    private String adminPassword;

    @Override
    public void init() throws ServletException {
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("application.properties")) {
            Properties props = new Properties();
            props.load(is);
            adminEmail    = props.getProperty("admin.email",    "admin@menuscanner.com");
            adminPassword = props.getProperty("admin.password", "SuperAdmin1234");
        } catch (IOException e) {
            throw new ServletException("Cannot load admin config", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            resp.sendRedirect(req.getContextPath() + "/admin/");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/admin-login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || password == null || email.isBlank() || password.isBlank()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/admin-login.jsp").forward(req, resp);
            return;
        }

        boolean validEmail = adminEmail.equalsIgnoreCase(email.trim());
        boolean validPass  = adminPassword.startsWith("$2a$")
                ? PasswordUtil.verify(password, adminPassword)
                : adminPassword.equals(password);

        if (validEmail && validPass) {
            HttpSession old = req.getSession(false);
            if (old != null) old.invalidate();
            HttpSession session = req.getSession(true);
            session.setAttribute("isAdmin",    Boolean.TRUE);
            session.setAttribute("adminEmail", adminEmail);
            session.setMaxInactiveInterval(3_600); // 1 hour
            resp.sendRedirect(req.getContextPath() + "/admin/");
        } else {
            req.setAttribute("error", "Invalid admin credentials.");
            req.getRequestDispatcher("/WEB-INF/views/admin-login.jsp").forward(req, resp);
        }
    }
}
