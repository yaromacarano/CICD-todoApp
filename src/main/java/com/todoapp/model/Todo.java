package com.todoapp.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Todo entity model
 * Equivalent to Todo.cs in the original ASP.NET Core application
 */
@Entity
@Table(name = "Todos")
public class Todo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    
    @NotBlank(message = "Description is required")
    @Size(max = 100, message = "Description cannot be longer than 100 characters")
    @Column(nullable = false, length = 100)
    private String description = "";
    
    @Column(name = "is_completed", nullable = false)
    private boolean isCompleted = false;
    
    // Default constructor
    public Todo() {}
    
    // Constructor with description
    public Todo(String description) {
        this.description = description;
        this.isCompleted = false;
    }
    
    // Constructor with all fields
    public Todo(String description, boolean isCompleted) {
        this.description = description;
        this.isCompleted = isCompleted;
    }
    
    // Getters and Setters
    public Integer getId() {
        return id;
    }
    
    public void setId(Integer id) {
        this.id = id;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public boolean isCompleted() {
        return isCompleted;
    }
    
    public void setCompleted(boolean completed) {
        isCompleted = completed;
    }
    
    // Convenience method for Thymeleaf templates
    public boolean getIsCompleted() {
        return isCompleted;
    }
    
    public void setIsCompleted(boolean completed) {
        this.isCompleted = completed;
    }
    
    @Override
    public String toString() {
        return "Todo{" +
                "id=" + id +
                ", description='" + description + '\'' +
                ", isCompleted=" + isCompleted +
                '}';
    }
}
