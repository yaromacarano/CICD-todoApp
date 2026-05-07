package com.todoapp.controller;
import com.todoapp.model.ErrorViewModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import jakarta.servlet.http.HttpServletRequest;
@RequestMapping("/")
public class HomeController {
  private static final Logger =
      LoggerFactory.getLogger(HomeController.class);
  @GetMapping("/")
  public String index() {
    return "redirect:/todos";
  }
  @GetMapping("/home")
  public String home() {
    return "home/index";
  }
  @GetMapping("/privacy")
  public String privacy() {
    return "home/privacy";
  }
  @GetMapping("/test-footer")
  public String testFooter() {
    return "test-footer";
  }
  @GetMapping("/error")
  public String error(HttpServletRequest request, Model model) {
    String requestId =
        (String) request.getAttribute("jakarta.servlet.error.request_uri");
    if (requestId == null) {
      requestId = request.getRequestId();
    }
    ErrorViewModel errorViewModel = new ErrorViewModel(requestId);
    model.addAttribute("errorViewModel", errorViewModel);
    return "shared/error";
  }
}
