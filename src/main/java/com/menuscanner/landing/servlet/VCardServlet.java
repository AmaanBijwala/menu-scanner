package com.menuscanner.landing.servlet;

import com.menuscanner.landing.LandingProfile;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/** "Save contact" button: a vCard phones open straight into their contacts app. */
@WebServlet("/contact.vcf")
public class VCardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String[] parts = LandingProfile.FULL_NAME.split(" ");
        String last  = parts[parts.length - 1];
        String first = LandingProfile.FULL_NAME.substring(0, LandingProfile.FULL_NAME.length() - last.length()).trim();

        String vcard = String.join("\r\n",
                "BEGIN:VCARD",
                "VERSION:3.0",
                "N:" + last + ";" + first + ";;;",
                "FN:" + LandingProfile.FULL_NAME,
                "ORG:" + LandingProfile.BRAND,
                "TITLE:" + LandingProfile.TITLE + " – Digital Menu & Review QR",
                "TEL;TYPE=CELL:+" + LandingProfile.PHONE_E164,
                "EMAIL;TYPE=INTERNET:" + LandingProfile.EMAIL,
                "URL:" + LandingProfile.SITE_URL,
                // ADR = PO box;extended;street;city;region;postcode;country
                "ADR;TYPE=WORK:;;;" + LandingProfile.CITY.replace(", ", ";;;"),
                "END:VCARD", "");

        byte[] body = vcard.getBytes(StandardCharsets.UTF_8);
        resp.setContentType("text/vcard;charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"Amaan-Bijwala.vcf\"");
        resp.setContentLength(body.length);
        resp.getOutputStream().write(body);
    }
}
