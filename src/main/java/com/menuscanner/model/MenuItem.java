package com.menuscanner.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class MenuItem {
    private long id;
    private long restaurantId;
    private String name;
    private String description;
    private BigDecimal price;
    private String category;
    private String imagePath;         // relative path: "{restaurantId}/{uuid}.jpg"
    private boolean veg;
    private boolean available;
    private int displayOrder;
    private Timestamp createdAt;

    public MenuItem() {}

    public long getId()                          { return id; }
    public void setId(long id)                   { this.id = id; }

    public long getRestaurantId()                { return restaurantId; }
    public void setRestaurantId(long rid)        { this.restaurantId = rid; }

    public String getName()                      { return name; }
    public void setName(String name)             { this.name = name; }

    public String getDescription()               { return description; }
    public void setDescription(String d)         { this.description = d; }

    public BigDecimal getPrice()                 { return price; }
    public void setPrice(BigDecimal price)       { this.price = price; }

    public String getCategory()                  { return category; }
    public void setCategory(String category)     { this.category = category; }

    public String getImagePath()                 { return imagePath; }
    public void setImagePath(String imagePath)   { this.imagePath = imagePath; }

    public boolean isVeg()                       { return veg; }
    public void setVeg(boolean veg)              { this.veg = veg; }

    public boolean isAvailable()                 { return available; }
    public void setAvailable(boolean available)  { this.available = available; }

    public int getDisplayOrder()                 { return displayOrder; }
    public void setDisplayOrder(int order)       { this.displayOrder = order; }

    public Timestamp getCreatedAt()              { return createdAt; }
    public void setCreatedAt(Timestamp t)        { this.createdAt = t; }
}
