package com.menuscanner.model;

import java.sql.Timestamp;

/**
 * Campaign model — Phase 2.
 * Schema exists; execution is gated by PlanConfig.WHATSAPP_ENABLED / SMS_ENABLED.
 */
public class Campaign {
    private long id;
    private long restaurantId;
    private String name;
    private String message;
    private String channel;        // "WHATSAPP" | "SMS"
    private String targetSegment;
    private int sentCount;
    private String status;         // "DRAFT" | "SCHEDULED" | "SENT" | "FAILED"
    private Timestamp createdAt;
    private Timestamp scheduledAt;
    private Timestamp sentAt;

    public Campaign() {}

    public long getId()                          { return id; }
    public void setId(long id)                   { this.id = id; }

    public long getRestaurantId()                { return restaurantId; }
    public void setRestaurantId(long rid)        { this.restaurantId = rid; }

    public String getName()                      { return name; }
    public void setName(String name)             { this.name = name; }

    public String getMessage()                   { return message; }
    public void setMessage(String message)       { this.message = message; }

    public String getChannel()                   { return channel; }
    public void setChannel(String channel)       { this.channel = channel; }

    public String getTargetSegment()             { return targetSegment; }
    public void setTargetSegment(String ts)      { this.targetSegment = ts; }

    public int getSentCount()                    { return sentCount; }
    public void setSentCount(int sentCount)      { this.sentCount = sentCount; }

    public String getStatus()                    { return status; }
    public void setStatus(String status)         { this.status = status; }

    public Timestamp getCreatedAt()              { return createdAt; }
    public void setCreatedAt(Timestamp t)        { this.createdAt = t; }

    public Timestamp getScheduledAt()            { return scheduledAt; }
    public void setScheduledAt(Timestamp t)      { this.scheduledAt = t; }

    public Timestamp getSentAt()                 { return sentAt; }
    public void setSentAt(Timestamp t)           { this.sentAt = t; }
}
