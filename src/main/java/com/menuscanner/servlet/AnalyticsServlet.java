package com.menuscanner.servlet;

import com.google.gson.Gson;
import com.menuscanner.dao.AnalyticsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {

    private final AnalyticsDAO analyticsDAO = new AnalyticsDAO();
    private final Gson         gson         = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long restaurantId = (long) req.getSession().getAttribute("restaurantId");

        try {
            req.setAttribute("totalScans",  analyticsDAO.getTotalScans(restaurantId));
            req.setAttribute("todayScans",  analyticsDAO.getTodayScans(restaurantId));
            req.setAttribute("weekScans",   analyticsDAO.getThisWeekScans(restaurantId));
            req.setAttribute("monthScans",  analyticsDAO.getThisMonthScans(restaurantId));

            List<Map<String, Object>> daily = analyticsDAO.getDailyScans(restaurantId, 30);
            req.setAttribute("dailyScansJson", gson.toJson(daily));

            List<Map<String, Object>> topItems = analyticsDAO.getTopItems(restaurantId, 10);
            req.setAttribute("topItems", topItems);

        } catch (SQLException e) {
            getServletContext().log("Analytics load error", e);
        }

        req.getRequestDispatcher("/WEB-INF/views/analytics.jsp").forward(req, resp);
    }
}
