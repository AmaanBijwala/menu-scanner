package com.menuscanner.model;

public class Category {
    private long id;
    private long restaurantId;
    private String name;

    public Category() {}

    public long getId()                        { return id; }
    public void setId(long id)                 { this.id = id; }

    public long getRestaurantId()              { return restaurantId; }
    public void setRestaurantId(long v)        { this.restaurantId = v; }

    public String getName()                    { return name; }
    public void setName(String name)           { this.name = name; }
}
