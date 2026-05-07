@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

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
        String requestId = (String) request.getAttribute("jakarta.servlet.error.request_uri");
        if (requestId == null) {
            requestId = request.getRequestId();
        }

        ErrorViewModel errorViewModel = new ErrorViewModel(requestId);
        model.addAttribute("errorViewModel", errorViewModel);

        return "shared/error";
    }
}
