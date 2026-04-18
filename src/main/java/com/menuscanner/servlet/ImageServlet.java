package com.menuscanner.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

/**
 * Serves menu item images from the external upload directory.
 * Mapped to /images/* so AuthFilter whitelists it for public access.
 *
 * Security: path-traversal check ensures requests cannot escape uploadBasePath.
 */
@WebServlet("/images/*")
public class ImageServlet extends HttpServlet {

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
        String pathInfo = req.getPathInfo(); // e.g., /1/abc-uuid.jpg
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Path traversal guard
        Path base      = Paths.get(uploadBasePath).normalize();
        Path requested = Paths.get(uploadBasePath, pathInfo).normalize();
        if (!requested.startsWith(base)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File file = requested.toFile();
        if (!file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = Files.probeContentType(requested);
        resp.setContentType(contentType != null ? contentType : "application/octet-stream");
        resp.setContentLengthLong(file.length());
        resp.setHeader("Cache-Control", "public, max-age=86400"); // 1-day browser cache

        try (InputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            in.transferTo(out);
        }
    }
}
