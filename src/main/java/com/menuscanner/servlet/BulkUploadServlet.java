package com.menuscanner.servlet;

import com.google.gson.Gson;
import com.menuscanner.dao.CategoryDAO;
import com.menuscanner.dao.MenuItemDAO;
import com.menuscanner.model.Category;
import com.menuscanner.model.MenuItem;
import com.menuscanner.util.PlanConfig;
import com.menuscanner.util.RedisCache;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVRecord;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.*;

@WebServlet("/bulk-upload")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
public class BulkUploadServlet extends HttpServlet {

    private final MenuItemDAO menuItemDAO = new MenuItemDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final Gson gson = new Gson();

    // ── DTOs for JSON response ──────────────────────────────────────────────

    static class RowError {
        int row; String col; String msg;
        RowError(int row, String col, String msg) { this.row = row; this.col = col; this.msg = msg; }
    }

    static class BulkResult {
        int inserted = 0;
        List<RowError> errors = new ArrayList<>();
        String error;
    }

    // ── Entry point ─────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        Long restaurantId = (Long) req.getSession().getAttribute("restaurantId");
        if (restaurantId == null) {
            BulkResult r = new BulkResult(); r.error = "Not logged in";
            resp.getWriter().write(gson.toJson(r)); return;
        }

        Part filePart = req.getPart("bulkFile");
        if (filePart == null || filePart.getSize() == 0) {
            BulkResult r = new BulkResult(); r.error = "No file received";
            resp.getWriter().write(gson.toJson(r)); return;
        }

        String fileName = filePart.getSubmittedFileName().toLowerCase(Locale.ROOT);

        try {
            Set<String> validCategories = new LinkedHashSet<>();
            for (Category c : categoryDAO.findByRestaurantId(restaurantId))
                validCategories.add(c.getName());

            List<RowError> errors   = new ArrayList<>();
            List<MenuItem> items    = new ArrayList<>();

            if (fileName.endsWith(".xlsx") || fileName.endsWith(".xls")) {
                parseExcel(filePart, items, errors, validCategories, restaurantId);
            } else if (fileName.endsWith(".csv")) {
                parseCsv(filePart, items, errors, validCategories, restaurantId);
            } else {
                BulkResult r = new BulkResult(); r.error = "Only .xlsx and .csv files are supported";
                resp.getWriter().write(gson.toJson(r)); return;
            }

            if (!errors.isEmpty()) {
                BulkResult r = new BulkResult(); r.errors = errors;
                resp.getWriter().write(gson.toJson(r)); return;
            }

            if (items.isEmpty()) {
                BulkResult r = new BulkResult(); r.error = "No data rows found in file";
                resp.getWriter().write(gson.toJson(r)); return;
            }

            // Plan limit check
            String planType   = (String) req.getSession().getAttribute("planType");
            int currentCount  = menuItemDAO.countByRestaurantId(restaurantId);
            int maxItems      = PlanConfig.getMaxMenuItems(planType);
            if (maxItems != Integer.MAX_VALUE && currentCount + items.size() > maxItems) {
                BulkResult r = new BulkResult();
                r.error = "Plan limit would be exceeded. Current: " + currentCount
                        + ", adding: " + items.size() + ", max: " + maxItems;
                resp.getWriter().write(gson.toJson(r)); return;
            }

            for (MenuItem item : items) menuItemDAO.save(item);
            RedisCache.invalidateMenu(restaurantId);

            BulkResult r = new BulkResult(); r.inserted = items.size();
            resp.getWriter().write(gson.toJson(r));

        } catch (SQLException e) {
            getServletContext().log("BulkUpload DB error", e);
            BulkResult r = new BulkResult(); r.error = "Database error: " + e.getMessage();
            resp.getWriter().write(gson.toJson(r));
        }
    }

    // ── Parsers ─────────────────────────────────────────────────────────────

    private void parseExcel(Part part, List<MenuItem> items, List<RowError> errors,
                            Set<String> categories, long restaurantId) throws IOException {
        try (Workbook wb = new XSSFWorkbook(part.getInputStream())) {
            Sheet sheet = wb.getSheetAt(0);
            int rowNum = 0;
            for (Row row : sheet) {
                rowNum++;
                if (rowNum == 1) continue; // header
                if (isRowEmpty(row)) continue;
                parseRow(
                    cell(row, 0), cell(row, 1), cell(row, 2), cell(row, 3),
                    cell(row, 5), cell(row, 6), cell(row, 7), cell(row, 8),
                    rowNum, items, errors, categories, restaurantId
                );
            }
        }
    }

    private void parseCsv(Part part, List<MenuItem> items, List<RowError> errors,
                          Set<String> categories, long restaurantId) throws IOException {
        Iterable<CSVRecord> records = CSVFormat.DEFAULT.builder()
                .setHeader()
                .setSkipHeaderRecord(true)
                .setIgnoreEmptyLines(true)
                .setTrim(true)
                .build()
                .parse(new InputStreamReader(part.getInputStream(), "UTF-8"));

        int rowNum = 1;
        for (CSVRecord rec : records) {
            rowNum++;
            parseRow(
                get(rec, "Dish Identity"), get(rec, "Category"),
                get(rec, "Actual Price"), get(rec, "Discount (optional)"),
                get(rec, "Display Order"), get(rec, "Description"),
                get(rec, "Veg (Y/N)"), get(rec, "Available (Y/N)"),
                rowNum, items, errors, categories, restaurantId
            );
        }
    }

    // ── Row validation ───────────────────────────────────────────────────────

    private void parseRow(String name, String category, String priceStr, String discountStr,
                          String orderStr, String description, String vegStr, String availStr,
                          int rowNum, List<MenuItem> items, List<RowError> errors,
                          Set<String> validCategories, long restaurantId) {
        boolean ok = true;

        // Dish Identity
        if (name == null || name.isBlank()) {
            errors.add(new RowError(rowNum, "Dish Identity", "Required — cannot be empty"));
            ok = false;
        }

        // Category (case-sensitive match)
        if (category != null && !category.isBlank() && !validCategories.isEmpty()
                && !validCategories.contains(category)) {
            errors.add(new RowError(rowNum, "Category",
                "\"" + category + "\" not found. Available: " + String.join(", ", validCategories)));
            ok = false;
        }

        // Actual Price
        BigDecimal price = null;
        try {
            price = new BigDecimal(numStr(priceStr));
            if (price.compareTo(BigDecimal.ZERO) < 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            errors.add(new RowError(rowNum, "Actual Price", "Must be a valid positive number"));
            ok = false;
        }

        // Discount (optional)
        BigDecimal discount = BigDecimal.ZERO;
        if (discountStr != null && !discountStr.isBlank() && !discountStr.equals("0")
                && !discountStr.equals("0.0")) {
            try {
                discount = new BigDecimal(numStr(discountStr));
                if (discount.compareTo(BigDecimal.ZERO) < 0) throw new NumberFormatException();
                if (price != null && discount.compareTo(price) >= 0) {
                    errors.add(new RowError(rowNum, "Discount (optional)",
                        "Discount (" + discount + ") must be less than Actual Price (" + price + ")"));
                    ok = false;
                }
            } catch (NumberFormatException e) {
                errors.add(new RowError(rowNum, "Discount (optional)", "Must be a valid number if provided"));
                ok = false;
            }
        }

        // Display Order
        int displayOrder = 0;
        if (orderStr != null && !orderStr.isBlank()) {
            try {
                double d = Double.parseDouble(numStr(orderStr));
                displayOrder = (int) d;
                if (displayOrder < 0) throw new NumberFormatException();
            } catch (NumberFormatException e) {
                errors.add(new RowError(rowNum, "Display Order", "Must be a non-negative integer"));
                ok = false;
            }
        }

        // Veg
        boolean veg = false;
        String vegClean = vegStr == null ? "" : vegStr.trim().toUpperCase();
        if (!vegClean.equals("Y") && !vegClean.equals("N")) {
            errors.add(new RowError(rowNum, "Veg (Y/N)", "Must be Y or N"));
            ok = false;
        } else {
            veg = vegClean.equals("Y");
        }

        // Available
        boolean available = true;
        String availClean = availStr == null ? "" : availStr.trim().toUpperCase();
        if (!availClean.equals("Y") && !availClean.equals("N")) {
            errors.add(new RowError(rowNum, "Available (Y/N)", "Must be Y or N"));
            ok = false;
        } else {
            available = availClean.equals("Y");
        }

        if (ok) {
            MenuItem item = new MenuItem();
            item.setRestaurantId(restaurantId);
            item.setName(name.trim());
            item.setCategory(category != null && !category.isBlank() ? category.trim() : null);
            item.setPrice(price);
            item.setDiscountAmount(discount);
            item.setDescription(description != null && !description.isBlank() ? description.trim() : null);
            item.setDisplayOrder(displayOrder);
            item.setVeg(veg);
            item.setAvailable(available);
            items.add(item);
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private boolean isRowEmpty(Row row) {
        for (Cell c : row)
            if (c != null && c.getCellType() != CellType.BLANK) return false;
        return true;
    }

    private String cell(Row row, int col) {
        Cell c = row.getCell(col, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (c == null) return "";
        return switch (c.getCellType()) {
            case NUMERIC -> String.valueOf(c.getNumericCellValue());
            case BOOLEAN -> c.getBooleanCellValue() ? "Y" : "N";
            case FORMULA  -> c.getCellFormula();
            default       -> c.getStringCellValue().trim();
        };
    }

    private String get(CSVRecord rec, String header) {
        try { return rec.get(header); } catch (Exception e) { return ""; }
    }

    /** Strip trailing .0 from Excel numeric strings for cleaner BigDecimal parsing. */
    private String numStr(String s) {
        if (s == null) return "";
        s = s.trim();
        if (s.endsWith(".0")) s = s.substring(0, s.length() - 2);
        return s;
    }
}
