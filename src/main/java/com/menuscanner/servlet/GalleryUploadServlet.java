package com.menuscanner.servlet;

import com.google.gson.Gson;
import com.menuscanner.dao.GalleryDAO;
import com.menuscanner.model.GalleryImage;
import com.menuscanner.util.ImageProcessor;
import com.menuscanner.util.PlanConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.*;
import java.sql.SQLException;
import java.util.Properties;
import java.util.UUID;

/**
 * Handles gallery image uploads for restaurant ambience photos.
 *
 * Security checks (same as ImageUploadServlet):
 *   1. File size ≤ 5 MB
 *   2. Extension whitelist (.jpg, .jpeg, .png)
 *   3. Magic bytes validation
 *
 * Saves to: {uploadBasePath}/{restaurantId}/gallery/{uuid}.jpg
 * Served via existing ImageServlet at: /images/{restaurantId}/gallery/{uuid}.jpg
 */
@WebServlet("/upload-gallery-image")
@MultipartConfig(maxFileSize = 5L * 1024 * 1024, maxRequestSize = 6L * 1024 * 1024)
public class GalleryUploadServlet extends HttpServlet {

    private static final long   MAX_FILE_SIZE = 5L * 1024 * 1024;
    private static final byte[] JPEG_MAGIC    = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF};
    private static final byte[] PNG_MAGIC     = {(byte) 0x89, 0x50, 0x4E, 0x47};

    private String uploadBasePath;
    private final GalleryDAO galleryDAO = new GalleryDAO();
    private final Gson gson = new Gson();

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
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        long restaurantId = (long) req.getSession().getAttribute("restaurantId");
        String planType   = (String) req.getSession().getAttribute("planType");

        try {
            int current   = galleryDAO.countByRestaurantId(restaurantId);
            int maxImages = PlanConfig.getMaxGalleryImages(planType);
            if (maxImages != Integer.MAX_VALUE && current >= maxImages) {
                sendError(resp, "Gallery limit reached (" + maxImages + " photos). Upgrade to PRO for more.");
                return;
            }
        } catch (SQLException e) {
            sendError(resp, "Database error. Please try again.");
            return;
        }

        Part filePart = req.getPart("galleryImage");
        if (filePart == null || filePart.getSize() == 0) {
            sendError(resp, "No file uploaded.");
            return;
        }
        if (filePart.getSize() > MAX_FILE_SIZE) {
            sendError(resp, "File exceeds 5 MB limit.");
            return;
        }
        if (!isAllowedExtension(filePart.getSubmittedFileName())) {
            sendError(resp, "Only .jpg, .jpeg, .png files are allowed.");
            return;
        }

        byte[] imageBytes;
        try (InputStream raw = filePart.getInputStream()) {
            imageBytes = raw.readAllBytes();
        }
        if (!isValidImageHeader(imageBytes)) {
            sendError(resp, "File content does not match a valid JPEG or PNG.");
            return;
        }

        String caption = req.getParameter("caption");
        if (caption != null) caption = caption.trim();
        if (caption != null && caption.length() > 200) caption = caption.substring(0, 200);
        if (caption != null && caption.isBlank()) caption = null;

        String relativePath = restaurantId + "/gallery/" + UUID.randomUUID() + ".jpg";
        File   targetFile   = new File(uploadBasePath, relativePath);

        try (InputStream in = new ByteArrayInputStream(imageBytes)) {
            ImageProcessor.saveResized(in, targetFile);
        }

        try {
            GalleryImage img = new GalleryImage();
            img.setRestaurantId(restaurantId);
            img.setImagePath(relativePath);
            img.setCaption(caption);
            img.setDisplayOrder(0);
            long id = galleryDAO.save(img);

            UploadResponse result = new UploadResponse();
            result.id      = id;
            result.path    = relativePath;
            result.caption = caption;
            resp.getWriter().write(gson.toJson(result));

        } catch (SQLException e) {
            getServletContext().log("Gallery DB save error", e);
            targetFile.delete();
            sendError(resp, "Failed to save image. Please try again.");
        }
    }

    private static class UploadResponse {
        long id;
        String path;
        String caption;
    }

    private boolean isAllowedExtension(String filename) {
        if (filename == null) return false;
        String lower = filename.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png");
    }

    private boolean isValidImageHeader(byte[] data) {
        if (data.length >= 3
                && data[0] == JPEG_MAGIC[0] && data[1] == JPEG_MAGIC[1] && data[2] == JPEG_MAGIC[2]) return true;
        return data.length >= 4
                && data[0] == PNG_MAGIC[0] && data[1] == PNG_MAGIC[1]
                && data[2] == PNG_MAGIC[2] && data[3] == PNG_MAGIC[3];
    }

    private void sendError(HttpServletResponse resp, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        resp.getWriter().write(gson.toJson(new ErrorResponse(message)));
    }

    private static class ErrorResponse {
        String error;
        ErrorResponse(String error) { this.error = error; }
    }
}
