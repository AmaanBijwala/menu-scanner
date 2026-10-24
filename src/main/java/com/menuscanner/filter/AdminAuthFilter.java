package com.menuscanner.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/admin/*")
public class AdminAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();
        String pi   = req.getPathInfo();
        if (pi != null) path = path + pi;

        if ("/admin/login".equals(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null && Boolean.TRUE.equals(session.getAttribute("isAdmin"))) {
            chain.doFilter(request, response);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/login");
        }
    }
}
