package com.menuscanner.review.model;

import java.sql.Timestamp;

/** A business owner's login for the Product 2 dashboard. The phone number is the username. */
public class ReviewOwner {

    private long      id;
    private String    phone;
    private String    name;            // optional, for the "Hi Iqbal" greeting
    private String    passwordHash;
    private Timestamp lastLoginAt;

    public long getId()                      { return id; }
    public void setId(long id)               { this.id = id; }

    public String getPhone()                 { return phone; }
    public void setPhone(String phone)       { this.phone = phone; }

    public String getName()                  { return name; }
    public void setName(String name)         { this.name = name; }

    /** First word of the name, e.g. "Iqbal" for "Iqbal Hingora"; null if no name. */
    public String getFirstName() {
        if (name == null || name.isBlank()) return null;
        return name.trim().split("\\s+")[0];
    }

    public String getPasswordHash()          { return passwordHash; }
    public void setPasswordHash(String h)    { this.passwordHash = h; }

    public Timestamp getLastLoginAt()        { return lastLoginAt; }
    public void setLastLoginAt(Timestamp t)  { this.lastLoginAt = t; }

    /**
     * Normalises what people type as a phone number to the 10-digit form we store:
     * drops spaces/dashes and a leading +91 / 91 / 0. Returns null if it isn't 10 digits.
     */
    public static String normalizePhone(String raw) {
        if (raw == null) return null;
        String d = raw.replaceAll("\\D", "");
        if (d.length() == 12 && d.startsWith("91")) d = d.substring(2);
        if (d.length() == 11 && d.startsWith("0"))  d = d.substring(1);
        return d.matches("\\d{10}") ? d : null;
    }
}
