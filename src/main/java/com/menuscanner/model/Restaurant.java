package com.menuscanner.model;

import java.sql.Timestamp;

public class Restaurant {
    private long id;
    private String name;
    private String slug;
    private String email;
    private String passwordHash;
    private String phone;
    private String planType;          // "BASIC" or "PRO"
    private String socialWhatsapp;
    private String socialInstagram;
    private String socialFacebook;
    private String socialYoutube;
    private String socialTwitter;
    private Timestamp createdAt;
    private boolean active;

    public Restaurant() {}

    public long getId()                          { return id; }
    public void setId(long id)                   { this.id = id; }

    public String getName()                      { return name; }
    public void setName(String name)             { this.name = name; }

    public String getSlug()                      { return slug; }
    public void setSlug(String slug)             { this.slug = slug; }

    public String getEmail()                     { return email; }
    public void setEmail(String email)           { this.email = email; }

    public String getPasswordHash()              { return passwordHash; }
    public void setPasswordHash(String h)        { this.passwordHash = h; }

    public String getPhone()                     { return phone; }
    public void setPhone(String phone)           { this.phone = phone; }

    public String getPlanType()                  { return planType; }
    public void setPlanType(String planType)     { this.planType = planType; }

    public String getSocialWhatsapp()            { return socialWhatsapp; }
    public void setSocialWhatsapp(String v)      { this.socialWhatsapp = v; }

    public String getSocialInstagram()           { return socialInstagram; }
    public void setSocialInstagram(String v)     { this.socialInstagram = v; }

    public String getSocialFacebook()            { return socialFacebook; }
    public void setSocialFacebook(String v)      { this.socialFacebook = v; }

    public String getSocialYoutube()             { return socialYoutube; }
    public void setSocialYoutube(String v)       { this.socialYoutube = v; }

    public String getSocialTwitter()             { return socialTwitter; }
    public void setSocialTwitter(String v)       { this.socialTwitter = v; }

    public Timestamp getCreatedAt()              { return createdAt; }
    public void setCreatedAt(Timestamp t)        { this.createdAt = t; }

    public boolean isActive()                    { return active; }
    public void setActive(boolean active)        { this.active = active; }
}
