package com.menuscanner.review.servlet;

import com.menuscanner.review.dao.ReviewScannerDAO;
import com.menuscanner.review.filter.ReviewOwnerAuthFilter;
import com.menuscanner.review.model.ReviewScanner;
import com.menuscanner.util.ImageProcessor;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import javax.imageio.ImageIO;
import java.io.*;
import java.sql.SQLException;
import java.util.Properties;
import java.util.UUID;

/**
 * Photo for a WhatsApp offer, uploaded from the VIP Club tab before the offer is sent.
 *
 * POST /review/offer-image  (multipart, field "image", param "scanner")
 *   → checks the sticker belongs to the logged-in owner, size ≤ 5 MB, JPEG/PNG magic bytes
 *   → resizes to fit 1080x1080 and saves {images dir}/offers/{scannerId}/{uuid}.jpg
 *   → JSON {"path": "offers/12/<uuid>.jpg", "url": "/menu-scanner/images/offers/12/<uuid>.jpg"}
 *
 * The path is sent back with "startBroadcast"; the public /o/{code} page then shows it.
 */
@WebServlet("/review/offer-image")
@MultipartConfig(maxFileSize = 5L * 1024 * 1024, maxRequestSize = 6L * 1024 * 1024)
public class ReviewOfferImageServlet extends HttpServlet {

    private static final long   MAX_FILE_SIZE = 5L * 1024 * 1024;
    private static final int    MAX_SIDE      = 1080;   // big enough for a sharp WhatsApp preview, small enough to load fast
    private static final float  QUALITY       = 0.82f;
    private static final byte[] JPEG_MAGIC    = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF};
    private static final byte[] PNG_MAGIC     = {(byte) 0x89, 0x50, 0x4E, 0x47};

    private String uploadBasePath;
    private final ReviewScannerDAO scannerDAO = new ReviewScannerDAO();

    @Override
    public void init() throws ServletException {
        ImageIO.scanForPlugins();
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("application.properties")) {
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
        long ownerId = (Long) req.getSession().getAttribute(ReviewOwnerAuthFilter.SESSION_OWNER_ID);

        ReviewScanner scanner;
        try {
            scanner = scannerDAO.findById(Long.parseLong(req.getParameter("scanner")));
        } catch (NumberFormatException e) {
            sendError(resp, "Please pick a sticker.");
            return;
        } catch (SQLException e) {
            getServletContext().log("Offer image: scanner lookup failed", e);
            sendError(resp, "Could not upload. Please try again.");
            return;
        }
        if (scanner == null || scanner.getOwnerId() == null || scanner.getOwnerId() != ownerId) {
            sendError(resp, "That sticker isn't linked to your account.");
            return;
        }

        Part filePart = req.getPart("image");
        if (filePart == null || filePart.getSize() == 0) {
            sendError(resp, "No photo selected.");
            return;
        }
        if (filePart.getSize() > MAX_FILE_SIZE) {
            sendError(resp, "Photo is bigger than 5 MB.");
            return;
        }
        byte[] bytes;
        try (InputStream raw = filePart.getInputStream()) {
            bytes = raw.readAllBytes();
        }
        if (!startsWith(bytes, JPEG_MAGIC) && !startsWith(bytes, PNG_MAGIC)) {
            sendError(resp, "Please pick a JPG or PNG photo.");
            return;
        }

        // Server-generated filename: user input never goes into the path
        String relativePath = "offers/" + scanner.getId() + "/" + UUID.randomUUID() + ".jpg";
        try (InputStream in = new ByteArrayInputStream(bytes)) {
            ImageProcessor.saveResized(in, new File(uploadBasePath, relativePath), MAX_SIDE, MAX_SIDE, QUALITY);
        } catch (IOException e) {
            getServletContext().log("Offer image: resize failed", e);
            sendError(resp, "Could not read that photo. Try another one.");
            return;
        }
        resp.getWriter().write("{\"path\":\"" + relativePath + "\",\"url\":\""
                + req.getContextPath() + "/images/" + relativePath + "\"}");
    }

    /** True when the path is one this servlet would have produced for that sticker. */
    public static boolean isOfferImagePath(String path, long scannerId) {
        return path != null && path.matches("offers/" + scannerId + "/[0-9a-f\\-]{36}\\.jpg");
    }

    private static boolean startsWith(byte[] data, byte[] magic) {
        if (data.length < magic.length) return false;
        for (int i = 0; i < magic.length; i++) if (data[i] != magic[i]) return false;
        return true;
    }

    private static void sendError(HttpServletResponse resp, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        resp.getWriter().write("{\"error\":\"" + message + "\"}");
    }
}
