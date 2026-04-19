package com.menuscanner.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;

@WebServlet("/bulk-template")
public class BulkTemplateServlet extends HttpServlet {

    private static final String[] HEADERS = {
        "Dish Identity", "Category", "Actual Price", "Discount (optional)",
        "Final Price", "Display Order", "Description", "Veg (Y/N)", "Available (Y/N)"
    };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (req.getSession().getAttribute("restaurantId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=\"menu_bulk_template.xlsx\"");

        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Menu Items");

            CellStyle headerStyle = wb.createCellStyle();
            Font bold = wb.createFont();
            bold.setBold(true);
            bold.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(bold);
            headerStyle.setFillForegroundColor(IndexedColors.ORANGE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < HEADERS.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(HEADERS[i]);
                cell.setCellStyle(headerStyle);
                sheet.setColumnWidth(i, 22 * 256);
            }

            // Sample row
            Row s = sheet.createRow(1);
            s.createCell(0).setCellValue("Dal Makhani");
            s.createCell(1).setCellValue("Main Course");
            s.createCell(2).setCellValue(250);
            s.createCell(3).setCellValue(0);
            s.createCell(4).setCellValue(250);
            s.createCell(5).setCellValue(0);
            s.createCell(6).setCellValue("Creamy slow-cooked lentils");
            s.createCell(7).setCellValue("Y");
            s.createCell(8).setCellValue("Y");

            wb.write(resp.getOutputStream());
        }
    }
}
