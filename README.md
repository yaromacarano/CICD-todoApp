# Todo List Application - Java Spring MVC

A simple Todo List application built with Spring Boot 3.x and Spring MVC 6.2, demonstrating modern Java web development practices with server-side rendering. This is a Java port of the original ASP.NET Core MVC application, maintaining **identical functionality, layout, and user experience**.

## 🎯 Project Overview

This Java Spring Boot application is a **complete conversion** of the original ASP.NET Core TodoListApp (from 2025-06-05), designed to provide:
- **Identical visual appearance** and layout structure
- **Exact same user experience** and behavior patterns  
- **Matching functionality** across all CRUD operations
- **Same responsive design** and mobile compatibility

## ✨ Features

- **Full CRUD Operations**: Create, read, update, and delete todo items
- **Interactive UI**: Mark todos as completed/incomplete with toggle buttons
- **Responsive Design**: Mobile-friendly UI using Bootstrap 5 with identical styling
- **Clean User Experience**: Silent operations without intrusive success messages
- **Data Validation**: Server-side validation with error messages displayed in forms
- **Error Handling**: Comprehensive error handling and logging
- **Data Persistence**: SQLite database with Spring Data JPA
- **Clean Architecture**: MVC pattern with separation of concerns

## 🛠️ Tech Stack

### Backend
- **Spring Boot 3.3.1**: Application framework with auto-configuration
- **Spring MVC 6.2**: Web framework with Model-View-Controller pattern
- **Java 17**: Programming language with modern language features
- **Spring Data JPA**: Object-Relational Mapping with Hibernate
- **SQLite**: Lightweight, file-based relational database
- **Bean Validation (JSR-303)**: For model validation
- **Spring Security**: For CSRF protection and security headers

### Frontend
- **Thymeleaf**: Server-side templating engine (equivalent to Razor views)
- **Bootstrap 5**: CSS framework for responsive design
- **Bootstrap Icons**: Icon library for UI elements
- **jQuery**: JavaScript library for DOM manipulation
- **jQuery Validation**: Client-side form validation

## 📋 Requirements

- **Java 17** or later
- **Maven 3.6+** for dependency management
- **Modern web browser** (Chrome, Firefox, Edge, Safari)
- **Operating System**: Windows, macOS, or Linux

## 🚀 Getting Started

### Quick Start

1. **Navigate to the project directory**:
   ```bash
   cd TodoListApp_Java_2025-07-12
   ```

2. **Build the application**:
   ```bash
   mvn clean compile
   ```

3. **Run the application**:
   ```bash
   mvn spring-boot:run
   ```
   
   Or run the packaged JAR:
   ```bash
   mvn package -DskipTests
   java -jar target/todolist-app-1.0.0.jar
   ```

4. **Open your browser** and navigate to:
   - **Main Application**: `http://localhost:8080`
   - **Todo List**: `http://localhost:8080/todos`

### Development URLs

The application runs on the following URLs by default:
- **HTTP**: http://localhost:8080 (Spring Boot default port)
- **Todo List**: http://localhost:8080/todos
- **Create Todo**: http://localhost:8080/todos/create
- **Footer Test**: http://localhost:8080/test-footer (demonstrates sticky footer)

## 📁 Project Structure

```
TodoListApp_Java_2025-07-12/
├── pom.xml                                    # Maven project configuration
├── README.md                                  # This documentation
│
├── src/main/java/com/todoapp/
│   ├── TodoListApplication.java               # Main Spring Boot application class
│   ├── controller/                            # MVC Controllers (equivalent to ASP.NET Controllers)
│   │   ├── HomeController.java                # Home page controller
│   │   └── TodosController.java               # Todo CRUD operations controller
│   ├── model/                                 # Data models (equivalent to ASP.NET Models)
│   │   ├── Todo.java                          # Todo entity model with validation
│   │   └── ErrorViewModel.java               # Error handling model
│   ├── repository/                            # Data access layer (equivalent to ASP.NET DbContext)
│   │   └── TodoRepository.java               # Spring Data JPA repository
│   └── config/                                # Configuration classes
│       └── SecurityConfig.java               # Security configuration
│
├── src/main/resources/
│   ├── application.properties                 # Application configuration (equivalent to appsettings.json)
│   ├── templates/                             # Thymeleaf view templates (equivalent to Razor Views)
│   │   ├── todos/                             # Todo controller views
│   │   │   ├── index.html                     # Todo list page (matches original ASP.NET layout)
│   │   │   ├── create.html                    # Create todo page (matches original ASP.NET layout)
│   │   │   └── edit.html                      # Edit todo page (matches original ASP.NET layout)
│   │   └── shared/                            # Shared view components
│   │       └── error.html                     # Error page template
│   └── static/                                # Static web assets (equivalent to wwwroot)
│       ├── css/
│       │   └── site.css                       # Main stylesheet (matches original ASP.NET CSS)
│       ├── js/
│       │   └── site.js                        # Main JavaScript file (matches original)
│       └── lib/                               # Third-party libraries (Bootstrap, jQuery)
│           ├── bootstrap/                     # Bootstrap 5 framework
│           └── jquery/                        # jQuery library
│
└── src/test/java/com/todoapp/                 # Test classes
```

## 🗄️ Database Schema

The application uses SQLite with the following schema:

### Todos Table
| Column | Type | Constraints |
|--------|------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO INCREMENT |
| description | TEXT | NOT NULL, MAX 100 characters |
| is_completed | BOOLEAN | NOT NULL, DEFAULT FALSE |

## 🔧 Key Features Explained

### Layout and UI Design
The application **exactly matches** the original ASP.NET Core layout:
- **Card-based design** with `col-md-8 offset-md-2` responsive layout
- **Bootstrap 5 styling** with identical color scheme and spacing
- **Error messages inside card body** - validation errors appear within forms
- **Silent CRUD operations** - no success messages, clean user experience
- **Sticky footer** - footer stays at bottom of browser window on all pages
- **Proper form controls** - checkboxes render correctly with Bootstrap styling

### Form Controls & Validation
- **Checkbox inputs** properly typed with `type="checkbox"` for correct rendering
- **Bootstrap form styling** with `form-check` classes for consistent appearance
- **Server-side validation** using Bean Validation annotations
- **Client-side validation** with jQuery validation (when enabled)
- **Error display** within form cards matching original ASP.NET behavior

### Footer Positioning
The application uses modern CSS flexbox for consistent footer positioning:
```css
body {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}
.container { flex: 1; }
.footer { margin-top: auto; }
```
This ensures the footer stays at the bottom of the browser window regardless of content length.

### Model Validation
The Todo model includes comprehensive validation using Bean Validation:
```java
@NotBlank(message = "Description is required")
@Size(max = 100, message = "Description cannot be longer than 100 characters")
private String description;
```

### Error Handling
Error handling matches the original ASP.NET Core behavior:
- **Validation errors** displayed inside form cards using `BindingResult`
- **No flash messages** for successful operations
- **Clean redirects** after successful CRUD operations
- **Comprehensive logging** for debugging and monitoring

### Database Auto-Creation
The application automatically creates the database on startup using JPA:
```properties
spring.jpa.hibernate.ddl-auto=update
spring.datasource.url=jdbc:sqlite:todolist.db
```

## 🚀 Recent Improvements & Fixes

### UI/UX Enhancements (Latest)
- ✅ **Fixed Checkbox Rendering**: Resolved weird icon box issue in create/edit forms
  - Added proper `type="checkbox"` attribute to form inputs
  - Ensures correct Bootstrap 5 form-check styling
  - Professional checkbox appearance matching design standards

- ✅ **Sticky Footer Implementation**: Footer now stays at bottom of browser window
  - Implemented modern CSS flexbox layout for consistent positioning
  - Works across all pages regardless of content length
  - Responsive design maintained across all screen sizes
  - Added test page (`/test-footer`) to demonstrate functionality

### Technical Improvements
- ✅ **Form Control Standards**: All form inputs properly typed and styled
- ✅ **CSS Architecture**: Modern flexbox layout for better responsive behavior
- ✅ **Cross-browser Compatibility**: Consistent appearance across modern browsers
- ✅ **Accessibility**: Proper form labels and input associations

## 🔄 ASP.NET Core to Java Spring Boot Conversion

This application is a **complete technology stack conversion** from the original ASP.NET Core TodoListApp. Here's how the technologies map:

### Technology Mapping
| **ASP.NET Core** | **Java Spring Boot** | **Purpose** |
|------------------|----------------------|-------------|
| ASP.NET Core MVC | Spring MVC 6.2 | Web framework |
| C# | Java 17 | Programming language |
| Razor Views | Thymeleaf Templates | Server-side templating |
| Entity Framework Core | Spring Data JPA | ORM/Data access |
| appsettings.json | application.properties | Configuration |
| ModelState | BindingResult | Form validation |
| TempData | *(Removed)* | Flash messages |
| wwwroot/ | static/ | Static assets |

### Layout Conversion
- **HTML Structure**: Identical card-based layout with Bootstrap 5
- **CSS Styling**: Exact copy of original site.css
- **JavaScript**: Minimal, matching original behavior
- **Responsive Design**: Same `col-md-8 offset-md-2` layout
- **Error Handling**: Validation errors inside forms, no success messages

### Behavioral Equivalence
- ✅ **Silent CRUD Operations**: No success messages after create/update/delete
- ✅ **Form Validation**: Errors displayed within card bodies
- ✅ **Navigation**: Identical user flow and redirects
- ✅ **Visual Design**: Matching colors, spacing, and typography
- ✅ **Mobile Responsiveness**: Same responsive behavior

## 📄 Available Pages

1. **Home Page** (`/`) - Redirects to todo list
2. **Todo List** (`/todos`) - View all todos with completion toggle
3. **Create Todo** (`/todos/create`) - Add new todo items  
4. **Edit Todo** (`/todos/edit/{id}`) - Modify existing todos
5. **Footer Test** (`/test-footer`) - Demonstrates sticky footer positioning

## 🛠️ Development Commands

```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Run the application (development)
mvn spring-boot:run

# Package the application
mvn clean package -DskipTests

# Run the packaged JAR
java -jar target/todolist-app-1.0.0.jar

# Run in background (Linux/macOS)
nohup java -jar target/todolist-app-1.0.0.jar > app.log 2>&1 &
```

## ⚙️ Configuration

### Application Settings
Key configuration in `application.properties`:
```properties
# Server Configuration
server.port=8080

# Database Configuration  
spring.datasource.url=jdbc:sqlite:todolist.db
spring.datasource.driver-class-name=org.sqlite.JDBC

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false

# Security Configuration
spring.security.csrf.enabled=true
```

### Environment Profiles
- **Default Profile**: Production-ready settings with minimal logging
- **Development Profile** (`dev`): Enhanced logging and debugging features

## 🔍 Troubleshooting

### Common Issues

1. **Port Already in Use (8080)**
   ```bash
   # Find process using port 8080
   lsof -i :8080
   
   # Kill the process
   kill -9 <PID>
   
   # Or change port in application.properties
   server.port=8081
   ```

2. **Database Issues**
   ```bash
   # Reset database (will lose data)
   rm todolist.db
   
   # Check database file permissions
   ls -la todolist.db
   ```

3. **Maven Build Issues**
   ```bash
   # Clean and rebuild
   mvn clean compile
   
   # Check Java version (should be 17+)
   java -version
   
   # Verify Maven version
   mvn -version
   ```

4. **Application Won't Start**
   ```bash
   # Check if another instance is running
   ps aux | grep todolist-app
   
   # Check application logs
   tail -f app.log
   ```

### Debugging Tips
- **Console Output**: Check startup logs for configuration errors
- **Browser DevTools**: Use F12 for client-side debugging
- **Database**: Use SQLite browser to inspect data
- **Logging**: Enable debug logging in `application.properties`:
  ```properties
  logging.level.com.todoapp=DEBUG
  ```

### UI/Form Issues
5. **Checkbox Not Displaying Correctly**
   ```html
   <!-- Ensure checkbox inputs have proper type attribute -->
   <input type="checkbox" class="form-check-input" />
   ```

6. **Footer Not at Bottom of Page**
   ```css
   /* Verify CSS includes flexbox layout */
   body { display: flex; flex-direction: column; min-height: 100vh; }
   .container { flex: 1; }
   .footer { margin-top: auto; }
   ```

7. **Bootstrap Styling Issues**
   ```bash
   # Check if Bootstrap CSS is loading
   curl -I http://localhost:8080/lib/bootstrap/dist/css/bootstrap.min.css
   ```

## 🏗️ Architecture Patterns

This application demonstrates several key architectural patterns:

- **MVC Pattern**: Clear separation of Model, View, and Controller concerns
- **Repository Pattern**: Data access abstraction through Spring Data JPA
- **Dependency Injection**: Spring's IoC container for loose coupling
- **Configuration Pattern**: Externalized configuration with profiles
- **Template Pattern**: Thymeleaf templating for server-side rendering

## 🔒 Security Features

- **CSRF Protection**: Built-in CSRF tokens for all form submissions
- **Security Headers**: HSTS, Content-Type options, Frame options
- **Input Validation**: Server-side validation with Bean Validation
- **SQL Injection Prevention**: JPA/Hibernate parameterized queries
- **XSS Protection**: Thymeleaf automatic HTML escaping

## 🚀 Performance Considerations

- **Connection Pooling**: HikariCP for efficient database connections
- **Static Resource Caching**: Browser caching for CSS/JS assets
- **Minimal JavaScript**: Lightweight client-side code
- **Efficient Queries**: JPA query optimization
- **Small Footprint**: SQLite for minimal resource usage

## 📚 Learning Resources

### Spring Boot & Spring MVC
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Spring MVC Reference](https://docs.spring.io/spring-framework/docs/current/reference/html/web.html)
- [Spring Data JPA Guide](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/)

### Thymeleaf Templating
- [Thymeleaf Documentation](https://www.thymeleaf.org/documentation.html)
- [Thymeleaf + Spring Integration](https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html)

## 🤝 Contributing

This project serves as a **polished reference implementation** for ASP.NET Core to Java Spring Boot conversion. Recent improvements include:

### ✅ Recently Completed
- **UI/UX Polish**: Fixed checkbox rendering and implemented sticky footer
- **Form Controls**: Proper Bootstrap 5 form styling and validation
- **Responsive Design**: Consistent layout across all screen sizes
- **Cross-browser Compatibility**: Tested and working in modern browsers

### 🚀 Future Enhancement Opportunities
1. **Testing**: Add comprehensive unit and integration tests
2. **API Endpoints**: Add REST API alongside MVC controllers  
3. **Authentication**: Implement user authentication and authorization
4. **Caching**: Add Redis or in-memory caching
5. **Monitoring**: Integrate with Spring Boot Actuator
6. **Docker**: Add containerization support
7. **CI/CD**: Add GitHub Actions or similar pipeline

## 📄 License

This project is created for educational and demonstration purposes, showcasing the conversion from ASP.NET Core MVC to Java Spring Boot MVC while maintaining identical functionality and user experience.

---

**Built with ❤️ using Java 17, Spring Boot 3.3.1, and Spring MVC 6.2**

*Converted from the original ASP.NET Core TodoListApp (2025-06-05) with **identical layout, functionality, and polished user experience**. Recent improvements include proper form controls, sticky footer positioning, and enhanced UI/UX standards.*
