package com.todoapp.repository;

import com.todoapp.model.Todo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Todo repository interface using Spring Data JPA
 * Equivalent to TodoContext.cs in the original ASP.NET Core application
 */
@Repository
public interface TodoRepository extends JpaRepository<Todo, Integer> {
    
    // Additional query methods can be added here if needed
    List<Todo> findByIsCompleted(boolean isCompleted);
    
    long countByIsCompleted(boolean isCompleted);
}
