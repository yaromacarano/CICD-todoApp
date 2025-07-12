package com.todoapp.controller;

import com.todoapp.model.Todo;
import com.todoapp.repository.TodoRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;

/**
 * Todos controller handling all CRUD operations
 * Equivalent to TodosController.cs in the original ASP.NET Core application
 */
@Controller
@RequestMapping("/todos")
public class TodosController {
    
    private static final Logger logger = LoggerFactory.getLogger(TodosController.class);
    
    @Autowired
    private TodoRepository todoRepository;
    
    // GET: /todos
    @GetMapping
    public String index(Model model) {
        try {
            List<Todo> todos = todoRepository.findAll();
            long completedCount = todoRepository.countByIsCompleted(true);
            long pendingCount = todoRepository.countByIsCompleted(false);
            
            model.addAttribute("todos", todos);
            model.addAttribute("completedCount", completedCount);
            model.addAttribute("pendingCount", pendingCount);
            return "todos/index";
        } catch (Exception ex) {
            logger.error("Error occurred while retrieving todos", ex);
            model.addAttribute("errorMessage", "An error occurred while retrieving the todo list.");
            model.addAttribute("todos", List.of());
            model.addAttribute("completedCount", 0);
            model.addAttribute("pendingCount", 0);
            return "todos/index";
        }
    }
    
    // GET: /todos/create
    @GetMapping("/create")
    public String create(Model model) {
        model.addAttribute("todo", new Todo());
        return "todos/create";
    }
    
    // POST: /todos/create
    @PostMapping("/create")
    public String create(@Valid @ModelAttribute("todo") Todo todo, 
                        BindingResult bindingResult, 
                        Model model) {
        try {
            if (bindingResult.hasErrors()) {
                return "todos/create";
            }
            
            todoRepository.save(todo);
            return "redirect:/todos";
            
        } catch (Exception ex) {
            logger.error("Error occurred while creating todo", ex);
            bindingResult.reject("error.general", "An error occurred while creating the todo item.");
            return "todos/create";
        }
    }
    
    // GET: /todos/edit/{id}
    @GetMapping("/edit/{id}")
    public String edit(@PathVariable("id") Integer id, Model model) {
        if (id == null) {
            return "redirect:/todos";
        }
        
        try {
            Optional<Todo> todoOptional = todoRepository.findById(id);
            if (todoOptional.isEmpty()) {
                return "redirect:/todos";
            }
            
            model.addAttribute("todo", todoOptional.get());
            return "todos/edit";
            
        } catch (Exception ex) {
            logger.error("Error occurred while retrieving todo for edit", ex);
            return "redirect:/todos";
        }
    }
    
    // POST: /todos/edit/{id}
    @PostMapping("/edit/{id}")
    public String edit(@PathVariable("id") Integer id, 
                      @Valid @ModelAttribute("todo") Todo todo, 
                      BindingResult bindingResult, 
                      Model model) {
        
        if (!id.equals(todo.getId())) {
            return "redirect:/todos";
        }
        
        try {
            if (bindingResult.hasErrors()) {
                return "todos/edit";
            }
            
            // Check if todo exists
            if (!todoRepository.existsById(id)) {
                return "redirect:/todos";
            }
            
            todoRepository.save(todo);
            return "redirect:/todos";
            
        } catch (DataAccessException ex) {
            logger.error("Data access error while updating todo", ex);
            model.addAttribute("errorMessage", "An error occurred while updating the todo item.");
            return "todos/edit";
        } catch (Exception ex) {
            logger.error("Error occurred while updating todo", ex);
            model.addAttribute("errorMessage", "An error occurred while updating the todo item.");
            return "todos/edit";
        }
    }
    
    // POST: /todos/delete/{id}
    @PostMapping("/delete/{id}")
    public String delete(@PathVariable("id") Integer id) {
        try {
            Optional<Todo> todoOptional = todoRepository.findById(id);
            if (todoOptional.isPresent()) {
                todoRepository.deleteById(id);
            }
            return "redirect:/todos";
            
        } catch (Exception ex) {
            logger.error("Error occurred while deleting todo", ex);
            return "redirect:/todos";
        }
    }
    
    // POST: /todos/toggle/{id}
    @PostMapping("/toggle/{id}")
    public String toggleStatus(@PathVariable("id") Integer id) {
        try {
            Optional<Todo> todoOptional = todoRepository.findById(id);
            if (todoOptional.isEmpty()) {
                return "redirect:/todos";
            }
            
            Todo todo = todoOptional.get();
            todo.setCompleted(!todo.isCompleted());
            todoRepository.save(todo);
            
            todoRepository.save(todo);
            return "redirect:/todos";
            
        } catch (Exception ex) {
            logger.error("Error occurred while toggling todo status", ex);
            return "redirect:/todos";
        }
    }
}
