package com.menuscanner.review.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Guards the Product 2 owner area (/review/*). Only /review/login is open. */
@WebFilter("/review/*")
public class ReviewOwnerAuthFilter implements Filter {

    public static final String SESSION_OWNER_ID = "reviewOwnerId";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath() + (req.getPathInfo() == null ? "" : req.getPathInfo());
        if ("/review/login".equals(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute(SESSION_OWNER_ID) != null) {
            resp.setHeader("Cache-Control", "no-store");   // dashboard pages hold private numbers
            chain.doFilter(request, response);
        } else {
            resp.sendRedirect(req.getContextPath() + "/review/login");
        }
    }
}
