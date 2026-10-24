package com.menuscanner.servlet;

import com.menuscanner.dao.GalleryDAO;
import com.menuscanner.util.PlanConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.Properties;

@WebServlet("/gallery")
public class GalleryServlet extends HttpServlet {

    private final GalleryDAO galleryDAO = new GalleryDAO();
    private String uploadBasePath;

    @Override
    public void init() throws ServletException {
        try (InputStream is = getClass().getClassLoader()
                .getResourceAsStream("application.properties")) {
            Properties props = new Properties();
            props.load(is);
            uploadBasePath = props.getProperty("file.upload.images.path", "/opt/menuscanner-data/images");
        } catch (IOException e) {
            throw new ServletException("Cannot load upload path", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");
        String planType   = (String) req.getSession().getAttribute("planType");

        // Set plan limits before the DB call so they are always available in the JSP,
        // even if the query fails (e.g. migration not yet run).
        int maxImages = PlanConfig.getMaxGalleryImages(planType);
        req.setAttribute("maxGalleryImages", maxImages);
        req.setAttribute("canUpload", true); // default; overridden after successful DB query

        try {
            var images = galleryDAO.findByRestaurantId(restaurantId);
            req.setAttribute("galleryImages", images);
            req.setAttribute("galleryCount",  images.size());
            req.setAttribute("canUpload",
                maxImages == Integer.MAX_VALUE || images.size() < maxImages);
        } catch (SQLException e) {
            getServletContext().log("Gallery load error", e);
        }
        req.getRequestDispatcher("/WEB-INF/views/gallery.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");

        String action  = req.getParameter("action");
        String idParam = req.getParameter("id");

        if ("updateCaption".equals(action)) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            if (idParam == null || idParam.isBlank()) {
                out.print("{\"error\":\"Missing id\"}"); return;
            }
            try {
                long id      = Long.parseLong(idParam);
                String caption = req.getParameter("caption");
                galleryDAO.updateCaption(id, restaurantId, caption);
                String safe = (caption == null || caption.isBlank()) ? "" : caption.trim()
                        .replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
                out.print("{\"ok\":true,\"caption\":\"" + safe + "\"}");
            } catch (NumberFormatException | SQLException e) {
                getServletContext().log("Gallery update caption error", e);
                out.print("{\"error\":\"Update failed\"}");
            }
            return;
        }

        if ("delete".equals(action)) {
            if (idParam != null && !idParam.isBlank()) {
                try {
                    long id = Long.parseLong(idParam);
                    String imagePath = galleryDAO.getImagePath(id, restaurantId);
                    galleryDAO.delete(id, restaurantId);
                    if (imagePath != null) {
                        new File(uploadBasePath, imagePath).delete();
                    }
                } catch (NumberFormatException | SQLException e) {
                    getServletContext().log("Gallery delete error", e);
                }
            }
        }
        resp.sendRedirect(req.getContextPath() + "/gallery?success=deleted");
    }
}
