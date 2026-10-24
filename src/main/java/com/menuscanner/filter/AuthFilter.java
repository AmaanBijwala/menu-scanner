package com.menuscanner.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;

/**
 * Guards all protected routes. Whitelists public paths so the filter
 * doesn't block customers scanning QR codes or viewing the public menu.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    /** Exact paths that never require login. */
    private static final Set<String> PUBLIC_EXACT = Set.of(
            "/login",
            "/menu",
            "/lead-capture",
            "/track-items"
    );

    /** Path prefixes that never require login. */
    private static final Set<String> PUBLIC_PREFIXES = Set.of(
            "/public/",
            "/images/",   // served by ImageServlet from external directory
            "/css/",
            "/js/",
            "/admin/"     // admin routes are guarded by AdminAuthFilter
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();
        String pi   = req.getPathInfo();
        if (pi != null) path = path + pi;   // wildcard servlets (e.g. /images/*) need pathInfo appended

        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("restaurantId") != null) {
            chain.doFilter(request, response);
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }

    private boolean isPublic(String path) {
        if (PUBLIC_EXACT.contains(path)) return true;
        for (String prefix : PUBLIC_PREFIXES) {
            if (path.startsWith(prefix)) return true;
        }
        return false;
    }
}
