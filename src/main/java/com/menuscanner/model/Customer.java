package com.menuscanner.model;

import java.sql.Timestamp;

public class Customer {
    private long id;
    private long restaurantId;
    private String name;
    private String phone;
    private int age;
    private String gender;
    private Timestamp capturedAt;
    private boolean consentWhatsapp;

    public Customer() {}

    public long getId()                              { return id; }
    public void setId(long id)                       { this.id = id; }

    public long getRestaurantId()                    { return restaurantId; }
    public void setRestaurantId(long rid)            { this.restaurantId = rid; }

    public String getName()                          { return name; }
    public void setName(String name)                 { this.name = name; }

    public String getPhone()                         { return phone; }
    public void setPhone(String phone)               { this.phone = phone; }

    public int getAge()                              { return age; }
    public void setAge(int age)                      { this.age = age; }

    public String getGender()                        { return gender; }
    public void setGender(String gender)             { this.gender = gender; }

    public Timestamp getCapturedAt()                 { return capturedAt; }
    public void setCapturedAt(Timestamp t)           { this.capturedAt = t; }

    public boolean isConsentWhatsapp()               { return consentWhatsapp; }
    public void setConsentWhatsapp(boolean consent)  { this.consentWhatsapp = consent; }
}
