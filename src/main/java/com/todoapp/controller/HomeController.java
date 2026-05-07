package com.todoapp.controller;

import com.todoapp.model.ErrorViewModel;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Handles home, privacy, test footer, and error pages.
 */
@Controller
@RequestMapping("/")
public class HomeController {

  /** Logger for HomeController. */
  private static final Logger LOGGER =
      LoggerFactory.getLogger(HomeController.class);

  @GetMapping("/")
  public String index() {
    LOGGER.debug("Redirecting from root path to todos page");
    return "redirect:/todos";
  }

  @GetMapping("/home")
  public String home() {
    LOGGER.debug("Rendering home page");
    return "home/index";
  }

  @GetMapping("/privacy")
  public String privacy() {
    LOGGER.debug("Rendering privacy page");
    return "home/privacy";
  }

  @GetMapping("/test-footer")
  public String testFooter() {
    LOGGER.debug("Rendering test footer page");
    return "test-footer";
  }

  @GetMapping("/error")
  public String error(HttpServletRequest request, Model model) {
    String requestId =
        (String) request.getAttribute("jakarta.servlet.error.request_uri");

    if (requestId == null) {
      requestId = request.getRequestId();
    }

    LOGGER.warn("Rendering error page for request id: {}", requestId);

    ErrorViewModel errorViewModel = new ErrorViewModel(requestId);
    model.addAttribute("errorViewModel", errorViewModel);

    return "shared/error";
  }
}
