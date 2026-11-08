package com.menuscanner.landing.model;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;

/** A client enquiry submitted from the landing page contact form. */
public class Enquiry {

    private long      id;
    private String    name;
    private String    phone;
    private String    businessName;
    private String    interest;
    private String    message;
    private String    status;
    private Timestamp createdAt;

    /** Phone as wa.me expects it: digits only, 91 prefixed for 10-digit Indian numbers. */
    public String getWhatsappNumber() {
        String digits = phone == null ? "" : phone.replaceAll("\\D", "");
        return digits.length() == 10 ? "91" + digits : digits;
    }

    /** wa.me link that opens a chat with this person, greeting pre-filled. */
    public String getWhatsappReplyUrl() {
        String text = "Hi " + (name == null ? "" : name) + ", this is Amaan. Thanks for your enquiry!";
        return "https://wa.me/" + getWhatsappNumber() + "?text="
             + URLEncoder.encode(text, StandardCharsets.UTF_8).replace("+", "%20");
    }

    public String getInterestLabel() {
        if (interest == null) return "—";
        return switch (interest) {
            case "MENU_QR"   -> "Digital Menu QR";
            case "REVIEW_QR" -> "Google Review QR";
            case "CUSTOM"    -> "Custom software";
            default          -> "Other";
        };
    }

    public long getId()                       { return id; }
    public void setId(long id)                { this.id = id; }

    public String getName()                   { return name; }
    public void setName(String name)          { this.name = name; }

    public String getPhone()                  { return phone; }
    public void setPhone(String phone)        { this.phone = phone; }

    public String getBusinessName()           { return businessName; }
    public void setBusinessName(String b)     { this.businessName = b; }

    public String getInterest()               { return interest; }
    public void setInterest(String interest)  { this.interest = interest; }

    public String getMessage()                { return message; }
    public void setMessage(String message)    { this.message = message; }

    public String getStatus()                 { return status; }
    public void setStatus(String status)      { this.status = status; }

    public Timestamp getCreatedAt()           { return createdAt; }
    public void setCreatedAt(Timestamp t)     { this.createdAt = t; }
}
