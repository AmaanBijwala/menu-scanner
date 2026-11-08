package com.menuscanner.review.servlet;

import com.menuscanner.review.LoginThrottle;
import com.menuscanner.review.dao.ReviewOwnerDAO;
import com.menuscanner.review.filter.ReviewOwnerAuthFilter;
import com.menuscanner.review.model.ReviewOwner;
import com.menuscanner.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

/** Owner login for the Product 2 dashboard: phone number + password (created by the admin). */
@WebServlet(urlPatterns = {"/review/login", "/review/logout"})
public class ReviewOwnerLoginServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/review/owner-login.jsp";

    private final ReviewOwnerDAO ownerDAO = new ReviewOwnerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/review/logout".equals(req.getServletPath())) {
            resp.sendRedirect(req.getContextPath() + "/review/login");
            return;
        }
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute(ReviewOwnerAuthFilter.SESSION_OWNER_ID) != null) {
            resp.sendRedirect(req.getContextPath() + "/review/dashboard");
            return;
        }
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if ("/review/logout".equals(req.getServletPath())) {
            HttpSession session = req.getSession(false);
            if (session != null) {
                session.removeAttribute(ReviewOwnerAuthFilter.SESSION_OWNER_ID);
                session.removeAttribute("reviewOwnerPhone");
            }
            resp.sendRedirect(req.getContextPath() + "/review/login?loggedOut=1");
            return;
        }

        String ip       = req.getRemoteAddr();
        String rawPhone = req.getParameter("phone");
        String password = req.getParameter("password");
        req.setAttribute("phone", rawPhone);

        if (LoginThrottle.isBlocked(ip)) {
            fail(req, resp, "Too many wrong attempts. Please wait 15 minutes and try again.");
            return;
        }
        String phone = ReviewOwner.normalizePhone(rawPhone);
        if (phone == null || password == null || password.isEmpty()) {
            fail(req, resp, "Enter your 10-digit mobile number and password.");
            return;
        }

        try {
            ReviewOwner owner = ownerDAO.findByPhone(phone);
            if (owner == null || !PasswordUtil.verify(password, owner.getPasswordHash())) {
                LoginThrottle.recordFailure(ip);
                fail(req, resp, "Wrong mobile number or password.");
                return;
            }
            LoginThrottle.recordSuccess(ip);
            ownerDAO.touchLogin(owner.getId());

            HttpSession session = req.getSession(true);
            req.changeSessionId();   // session-fixation protection without logging out other areas
            session.setAttribute(ReviewOwnerAuthFilter.SESSION_OWNER_ID, owner.getId());
            session.setAttribute("reviewOwnerPhone", owner.getPhone());
            session.setMaxInactiveInterval(60 * 60 * 8);   // owners check on their phone; keep it easy
            resp.sendRedirect(req.getContextPath() + "/review/dashboard");
        } catch (SQLException e) {
            getServletContext().log("Review owner login error", e);
            fail(req, resp, "Something went wrong. Please try again.");
        }
    }

    private void fail(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
