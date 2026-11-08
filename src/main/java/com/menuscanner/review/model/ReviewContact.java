package com.menuscanner.review.model;

import java.sql.Timestamp;

/** A customer who filled the "join" form on a review sticker's scan page. */
public class ReviewContact {

    private long      id;
    private long      scannerId;
    private String    name;
    private Integer   age;              // null = not given
    private String    gender;           // Male / Female / Other, or null
    private String    phone;            // 10 digits
    private boolean   consentWhatsapp;
    private Timestamp createdAt;

    public long getId()                          { return id; }
    public void setId(long id)                   { this.id = id; }

    public long getScannerId()                   { return scannerId; }
    public void setScannerId(long scannerId)     { this.scannerId = scannerId; }

    public String getName()                      { return name; }
    public void setName(String name)             { this.name = name; }

    public Integer getAge()                      { return age; }
    public void setAge(Integer age)              { this.age = age; }

    public String getGender()                    { return gender; }
    public void setGender(String gender)         { this.gender = gender; }

    public String getPhone()                     { return phone; }
    public void setPhone(String phone)           { this.phone = phone; }

    public boolean isConsentWhatsapp()           { return consentWhatsapp; }
    public void setConsentWhatsapp(boolean c)    { this.consentWhatsapp = c; }

    public Timestamp getCreatedAt()              { return createdAt; }
    public void setCreatedAt(Timestamp t)        { this.createdAt = t; }
}
