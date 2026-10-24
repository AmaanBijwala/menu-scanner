package com.menuscanner.model;

import java.sql.Timestamp;

public class GalleryImage {
    private long id;
    private long restaurantId;
    private String imagePath;
    private String caption;
    private int displayOrder;
    private Timestamp createdAt;

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public long getRestaurantId() { return restaurantId; }
    public void setRestaurantId(long restaurantId) { this.restaurantId = restaurantId; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getCaption() { return caption; }
    public void setCaption(String caption) { this.caption = caption; }

    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
