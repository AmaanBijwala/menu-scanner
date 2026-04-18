package com.menuscanner.servlet;

import com.menuscanner.util.PlanConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Campaign management — Phase 2.
 *
 * GET  /campaigns → shows campaign-builder.jsp (view always accessible)
 * POST /campaigns → DISABLED until PlanConfig.WHATSAPP_ENABLED || SMS_ENABLED is true
 *
 * To activate:
 *   1. Implement WhatsApp / SMS sending service
 *   2. Set PlanConfig.WHATSAPP_ENABLED = true (or SMS_ENABLED)
 *   3. Replace the 503 response below with the real send logic
 */
@WebServlet("/campaigns")
public class CampaignServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String planType = (String) req.getSession().getAttribute("planType");
        req.setAttribute("campaignsEnabled", PlanConfig.isCampaignsEnabled(planType));
        req.setAttribute("whatsappEnabled",  PlanConfig.WHATSAPP_ENABLED);
        req.setAttribute("smsEnabled",       PlanConfig.SMS_ENABLED);
        req.getRequestDispatcher("/WEB-INF/views/campaign-builder.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // ── Phase 2 placeholder ──────────────────────────────────────────
        // Replace this block with actual campaign save + send logic
        resp.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(
                "{\"error\":\"Campaign sending is not yet available. " +
                "Enable WHATSAPP_ENABLED or SMS_ENABLED in PlanConfig.\"}");
    }
}
