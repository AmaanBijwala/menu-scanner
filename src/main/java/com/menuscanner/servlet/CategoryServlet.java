package com.menuscanner.servlet;

import com.menuscanner.dao.CategoryDAO;
import com.menuscanner.model.Category;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/categories")
public class CategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");
        String action = req.getParameter("action");

        try {
            if ("add".equals(action)) {
                String name = req.getParameter("name");
                if (name != null && !name.isBlank()) {
                    Category cat = new Category();
                    cat.setRestaurantId(restaurantId);
                    cat.setName(name.trim());
                    categoryDAO.save(cat);
                }
            } else if ("delete".equals(action)) {
                String idParam = req.getParameter("id");
                if (idParam != null && !idParam.isBlank()) {
                    categoryDAO.delete(Long.parseLong(idParam), restaurantId);
                }
            }
        } catch (SQLException e) {
            getServletContext().log("CategoryServlet error", e);
        }

        resp.sendRedirect(req.getContextPath() + "/menu-items");
    }
}
