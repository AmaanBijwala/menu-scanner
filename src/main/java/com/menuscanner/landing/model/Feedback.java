package com.menuscanner.landing.model;

import java.sql.Timestamp;

/** A client's feedback, shown in the landing page's rotating strip. */
public class Feedback {

    private long      id;
    private String    personName;
    private String    shopName;
    private String    location;
    private String    product;
    private String    comment;
    private boolean   visible;
    private Timestamp createdAt;

    public String getProductLabel() {
        if (product == null) return "";
        return switch (product) {
            case "MENU_QR"   -> "Digital Menu QR";
            case "REVIEW_QR" -> "Google Review QR";
            case "CUSTOM"    -> "Custom Software";
            default          -> product;
        };
    }

    /** First letter of the person's name, for the avatar bubble. */
    public String getInitial() {
        return personName == null || personName.isBlank() ? "?" : personName.trim().substring(0, 1).toUpperCase();
    }

    public long getId()                         { return id; }
    public void setId(long id)                  { this.id = id; }

    public String getPersonName()               { return personName; }
    public void setPersonName(String n)         { this.personName = n; }

    public String getShopName()                 { return shopName; }
    public void setShopName(String s)           { this.shopName = s; }

    public String getLocation()                 { return location; }
    public void setLocation(String l)           { this.location = l; }

    public String getProduct()                  { return product; }
    public void setProduct(String p)            { this.product = p; }

    public String getComment()                  { return comment; }
    public void setComment(String c)            { this.comment = c; }

    public boolean isVisible()                  { return visible; }
    public void setVisible(boolean v)           { this.visible = v; }

    public Timestamp getCreatedAt()             { return createdAt; }
    public void setCreatedAt(Timestamp t)       { this.createdAt = t; }
}
