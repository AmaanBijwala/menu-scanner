package com.menuscanner.review.servlet;

import com.google.zxing.WriterException;
import com.menuscanner.review.ReviewConfig;
import com.menuscanner.review.dao.ReviewScannerDAO;
import com.menuscanner.review.model.ReviewScanner;
import com.menuscanner.util.QRGenerator;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

/** Admin-only QR PNG for a review sticker. ?id=1[&download=1][&size=600] */
@WebServlet("/admin/review-scanners/qr")
public class ReviewQRServlet extends HttpServlet {

    private final ReviewScannerDAO scannerDAO = new ReviewScannerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            long id  = Long.parseLong(req.getParameter("id"));
            int size = parseSize(req.getParameter("size"));
            ReviewScanner s = scannerDAO.findById(id);
            if (s == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            byte[] png = QRGenerator.generatePng(ReviewConfig.scanUrl(s.getCode()), size);
            resp.setContentType("image/png");
            resp.setContentLength(png.length);
            if ("1".equals(req.getParameter("download"))) {
                resp.setHeader("Content-Disposition",
                        "attachment; filename=\"review-qr-" + String.format("%03d", id) + ".png\"");
            }
            resp.getOutputStream().write(png);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException | WriterException e) {
            getServletContext().log("Review QR generation error", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private int parseSize(String s) {
        try {
            int n = Integer.parseInt(s);
            return Math.max(150, Math.min(n, 1200));
        } catch (Exception e) {
            return 600;
        }
    }
}
