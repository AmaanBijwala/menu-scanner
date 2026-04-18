package com.menuscanner.servlet;

import com.menuscanner.dao.MenuItemDAO;
import com.menuscanner.util.ImageProcessor;
import com.menuscanner.util.RedisCache;
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
 * Handles image uploads for menu items.
 *
 * Security checks (in order):
 *   1. File size ≤ 5 MB
 *   2. Extension whitelist (.jpg, .jpeg, .png)
 *   3. Magic bytes validation (JPEG: FF D8 FF  |  PNG: 89 50 4E 47)
 *
 * Image flow:
 *   POST /upload-image  (multipart, field "image", param "itemId")
 *   → Resize & save to {uploadBasePath}/{restaurantId}/{uuid}.jpg
 *   → Update menu_items.image_path in DB
 *   → Invalidate Redis cache for the restaurant
 *   → Return JSON {"path": "{restaurantId}/{uuid}.jpg"}
 *
 * Filename is server-generated (UUID) — user input is never used in the path.
 */
@WebServlet("/upload-image")
@MultipartConfig(maxFileSize = 5L * 1024 * 1024, maxRequestSize = 6L * 1024 * 1024)
public class ImageUploadServlet extends HttpServlet {

    private static final long  MAX_FILE_SIZE = 5L * 1024 * 1024;
    private static final byte[] JPEG_MAGIC   = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF};
    private static final byte[] PNG_MAGIC    = {(byte) 0x89, 0x50, 0x4E, 0x47};

    private String uploadBasePath;
    private final MenuItemDAO menuItemDAO = new MenuItemDAO();

    @Override
    public void init() throws ServletException {
        try (InputStream is = getClass().getClassLoader()
                .getResourceAsStream("application.properties")) {
            Properties props = new Properties();
            props.load(is);
            uploadBasePath = props.getProperty("file.upload.images.path", "/opt/menuscanner-data/images");
        } catch (IOException e) {
            throw new ServletException("Cannot load upload path from application.properties", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        long restaurantId = (long) req.getSession().getAttribute("restaurantId");

        String itemIdParam = req.getParameter("itemId");
        if (itemIdParam == null || itemIdParam.isBlank()) {
            sendError(resp, "Missing itemId parameter.");
            return;
        }
        long itemId;
        try {
            itemId = Long.parseLong(itemIdParam);
        } catch (NumberFormatException e) {
            sendError(resp, "Invalid itemId.");
            return;
        }

        Part filePart = req.getPart("image");
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

        // Read first 4 bytes for magic-byte check without consuming the full stream
        byte[] header = filePart.getInputStream().readNBytes(4);
        if (!isValidImageHeader(header)) {
            sendError(resp, "File content does not match a valid JPEG or PNG.");
            return;
        }

        // Server-generated filename — never trust user input for paths
        String relativePath = restaurantId + "/" + UUID.randomUUID() + ".jpg";
        File   targetFile   = new File(uploadBasePath, relativePath);

        try (InputStream in = filePart.getInputStream()) {
            ImageProcessor.saveResized(in, targetFile);
        }

        // Persist path and invalidate cache
        try {
            menuItemDAO.updateImagePath(itemId, restaurantId, relativePath);
            RedisCache.invalidateMenu(restaurantId);
        } catch (SQLException e) {
            getServletContext().log("Image path DB update error", e);
            // File saved successfully; DB update failure is non-fatal for the response
        }

        resp.getWriter().write("{\"path\":\"" + relativePath + "\"}");
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    private boolean isAllowedExtension(String filename) {
        if (filename == null) return false;
        String lower = filename.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png");
    }

    private boolean isValidImageHeader(byte[] h) {
        if (h.length >= 3
                && h[0] == JPEG_MAGIC[0] && h[1] == JPEG_MAGIC[1] && h[2] == JPEG_MAGIC[2]) {
            return true; // JPEG
        }
        return h.length >= 4
                && h[0] == PNG_MAGIC[0] && h[1] == PNG_MAGIC[1]
                && h[2] == PNG_MAGIC[2] && h[3] == PNG_MAGIC[3]; // PNG
    }

    private void sendError(HttpServletResponse resp, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        resp.getWriter().write("{\"error\":\"" + message + "\"}");
    }
}
