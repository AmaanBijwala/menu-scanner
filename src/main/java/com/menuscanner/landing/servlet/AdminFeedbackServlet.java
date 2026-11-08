package com.menuscanner.landing.servlet;

import com.menuscanner.landing.dao.FeedbackDAO;
import com.menuscanner.landing.model.Feedback;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Super-admin moderation of client feedback. Feedback text can't be edited here on purpose:
 * the admin can only hide (e.g. spam) or delete an entry, so what's public is what the client wrote.
 */
@WebServlet("/admin/feedback")
public class AdminFeedbackServlet extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Feedback> list = feedbackDAO.findAll();
            req.setAttribute("feedbacks", list);
            req.setAttribute("visibleCount", list.stream().filter(Feedback::isVisible).count());
        } catch (SQLException e) {
            getServletContext().log("Feedback load error", e);
            req.setAttribute("loadError", "Could not load feedback: " + e.getMessage());
        }
        req.getRequestDispatcher("/WEB-INF/views/landing/admin-feedback.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String redirect = req.getContextPath() + "/admin/feedback";
        try {
            long id = Long.parseLong(req.getParameter("id"));
            switch (req.getParameter("action") == null ? "" : req.getParameter("action")) {
                case "hide"   -> feedbackDAO.updateVisible(id, false);
                case "show"   -> feedbackDAO.updateVisible(id, true);
                case "delete" -> feedbackDAO.delete(id);
                default       -> { }
            }
            resp.sendRedirect(redirect);
        } catch (NumberFormatException e) {
            resp.sendRedirect(redirect + "?error=Invalid+ID");
        } catch (SQLException e) {
            getServletContext().log("Feedback action error", e);
            resp.sendRedirect(redirect + "?error=Could+not+update");
        }
    }
}
