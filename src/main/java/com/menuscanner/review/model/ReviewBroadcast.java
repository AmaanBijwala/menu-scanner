package com.menuscanner.review.model;

import com.menuscanner.review.ReviewConfig;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/** An offer the owner sent to VIP Club customers on WhatsApp, with who it was for. */
public class ReviewBroadcast {

    /** One customer on the offer. sentAt is null until the owner taps "Send". */
    public static class Recipient {
        private final String    name;
        private final String    phone;
        private final Timestamp sentAt;

        public Recipient(String name, String phone, Timestamp sentAt) {
            this.name = name;
            this.phone = phone;
            this.sentAt = sentAt;
        }

        public String getName()       { return name; }
        public String getPhone()      { return phone; }
        public Timestamp getSentAt()  { return sentAt; }
        public boolean isSent()       { return sentAt != null; }
    }

    private long      id;
    private String    message;
    private String    imagePath;       // null = text only
    private String    code;            // public /o/{code} page, only when there is a photo
    private String    businessName;    // filled for the public offer page
    private Timestamp createdAt;
    private final List<Recipient> recipients = new ArrayList<>();

    public long getId()                         { return id; }
    public void setId(long id)                  { this.id = id; }

    public String getMessage()                  { return message; }
    public void setMessage(String message)      { this.message = message; }

    public String getImagePath()                { return imagePath; }
    public void setImagePath(String imagePath)  { this.imagePath = imagePath; }

    public String getCode()                     { return code; }
    public void setCode(String code)            { this.code = code; }

    public String getBusinessName()             { return businessName; }
    public void setBusinessName(String n)       { this.businessName = n; }

    /** Full link to the public offer page, or null for a text-only offer. */
    public String getOfferUrl()                 { return code == null ? null : ReviewConfig.offerUrl(code); }

    public Timestamp getCreatedAt()             { return createdAt; }
    public void setCreatedAt(Timestamp t)       { this.createdAt = t; }

    public List<Recipient> getRecipients()      { return recipients; }

    public int getTotal()                       { return recipients.size(); }

    public int getSentCount() {
        int n = 0;
        for (Recipient r : recipients) if (r.isSent()) n++;
        return n;
    }
}
