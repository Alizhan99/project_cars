package com.example.carcatalog.model;

import jakarta.persistence.*;

@Entity
@Table(name = "cars")
public class Car {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String brand;
    private String model;
    private int year;
    private double price;
    
    // Новые поля для детализации
    @Column(length = 1000)
    private String imageUrl;
    
    @Column(length = 2000)
    private String description;
    
    private String color;
    private Integer mileage;          // пробег в км
    private String fuelType;          // бензин, дизель, электро, гибрид
    private String transmission;      // автомат, механика

    // Конструкторы
    public Car() {}

    public Car(String brand, String model, int year, double price) {
        this.brand = brand;
        this.model = model;
        this.year = year;
        this.price = price;
    }

    // Getters and Setters
    public Long getId() { 
        return id; 
    }
    
    public void setId(Long id) { 
        this.id = id; 
    }

    public String getBrand() { 
        return brand; 
    }
    
    public void setBrand(String brand) { 
        this.brand = brand; 
    }

    public String getModel() { 
        return model; 
    }
    
    public void setModel(String model) { 
        this.model = model; 
    }

    public int getYear() { 
        return year; 
    }
    
    public void setYear(int year) { 
        this.year = year; 
    }

    public double getPrice() { 
        return price; 
    }
    
    public void setPrice(double price) { 
        this.price = price; 
    }

    public String getImageUrl() { 
        return imageUrl; 
    }
    
    public void setImageUrl(String imageUrl) { 
        this.imageUrl = imageUrl; 
    }

    public String getDescription() { 
        return description; 
    }
    
    public void setDescription(String description) { 
        this.description = description; 
    }

    public String getColor() { 
        return color; 
    }
    
    public void setColor(String color) { 
        this.color = color; 
    }

    public Integer getMileage() { 
        return mileage; 
    }
    
    public void setMileage(Integer mileage) { 
        this.mileage = mileage; 
    }

    public String getFuelType() { 
        return fuelType; 
    }
    
    public void setFuelType(String fuelType) { 
        this.fuelType = fuelType; 
    }

    public String getTransmission() { 
        return transmission; 
    }
    
    public void setTransmission(String transmission) { 
        this.transmission = transmission; 
    }
}