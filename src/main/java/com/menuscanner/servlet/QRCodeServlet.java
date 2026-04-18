package com.menuscanner.servlet;

import com.google.zxing.WriterException;
import com.menuscanner.dao.RestaurantDAO;
import com.menuscanner.model.Restaurant;
import com.menuscanner.util.QRGenerator;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Generates and streams a QR code PNG for the restaurant's public menu URL.
 * GET /qr  → downloads qr-{slug}.png
 */
@WebServlet("/qr")
public class QRCodeServlet extends HttpServlet {

    private final RestaurantDAO restaurantDAO = new RestaurantDAO();
    private String baseUrl;

    @Override
    public void init() throws ServletException {
        try (InputStream is = getClass().getClassLoader()
                .getResourceAsStream("application.properties")) {
            Properties props = new Properties();
            props.load(is);
            baseUrl = props.getProperty("app.base.url", "http://localhost:8080/menu-scanner");
        } catch (IOException e) {
            throw new ServletException("Cannot load app.base.url", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long restaurantId = (long) req.getSession().getAttribute("restaurantId");
        try {
            Restaurant restaurant = restaurantDAO.findById(restaurantId);
            if (restaurant == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            String menuUrl  = baseUrl + "/menu?slug=" + restaurant.getSlug();
            byte[] qrBytes  = QRGenerator.generatePng(menuUrl, 300);

            resp.setContentType("image/png");
            resp.setContentLength(qrBytes.length);
            resp.setHeader("Content-Disposition",
                    "attachment; filename=\"qr-" + restaurant.getSlug() + ".png\"");
            resp.getOutputStream().write(qrBytes);

        } catch (SQLException | WriterException e) {
            getServletContext().log("QR generation error", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
