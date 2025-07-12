package com.todoapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Spring Boot application class for TodoListApp
 * Equivalent to Program.cs in the original ASP.NET Core application
 */
@SpringBootApplication
public class TodoListApplication {

    public static void main(String[] args) {
        SpringApplication.run(TodoListApplication.class, args);
    }
}
