package com.menuscanner.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class MenuItem {
    private long id;
    private long restaurantId;
    private String name;
    private String description;
    private BigDecimal price;
    private BigDecimal discountAmount = BigDecimal.ZERO;
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

    public BigDecimal getDiscountAmount()              { return discountAmount != null ? discountAmount : BigDecimal.ZERO; }
    public void setDiscountAmount(BigDecimal d)        { this.discountAmount = (d != null ? d : BigDecimal.ZERO); }

    public BigDecimal getFinalPrice() {
        BigDecimal d = getDiscountAmount();
        if (d.compareTo(BigDecimal.ZERO) <= 0) return price;
        return price.subtract(d).max(BigDecimal.ZERO);
    }

    public boolean hasDiscount() {
        return getDiscountAmount().compareTo(BigDecimal.ZERO) > 0;
    }

    public String getDiscountPercent() {
        if (!hasDiscount() || price == null || price.compareTo(BigDecimal.ZERO) == 0) return "0";
        return String.valueOf(getDiscountAmount().multiply(new java.math.BigDecimal("100"))
                .divide(price, 0, java.math.RoundingMode.HALF_UP));
    }

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
