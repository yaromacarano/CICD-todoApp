# Deployment Guide

## 🚀 TodoList Java Spring Boot Application Deployment

### 📋 Quick Start Commands

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/TodoListApp-Java-SpringBoot.git
cd TodoListApp-Java-SpringBoot

# Build the application
mvn clean package -DskipTests

# Run the application
java -jar target/todolist-app-1.0.0.jar

# Access the application
open http://localhost:8080/todos
```

### 🛠️ Requirements

- **Java 17+** (tested with Java 21)
- **Maven 3.6+**
- **Modern web browser**

### 🔧 Configuration Options

#### Application Properties
```properties
# Server Configuration
server.port=8080

# Database Configuration (SQLite)
spring.datasource.url=jdbc:sqlite:todolist.db

# JPA Configuration
spring.jpa.hibernate.ddl-auto=update
```

#### Environment Variables
```bash
# Optional: Change server port
export SERVER_PORT=8081

# Optional: Change database location
export DB_PATH=/path/to/custom/todolist.db
```

### 🐳 Docker Deployment (Optional)

Create `Dockerfile`:
```dockerfile
FROM openjdk:21-jre-slim
COPY target/todolist-app-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

Build and run:
```bash
docker build -t todolist-app .
docker run -p 8080:8080 todolist-app
```

### ☁️ Cloud Deployment Options

#### Heroku
```bash
# Add Procfile
echo "web: java -jar target/todolist-app-1.0.0.jar" > Procfile

# Deploy
heroku create your-app-name
git push heroku main
```

#### AWS Elastic Beanstalk
```bash
# Package for deployment
mvn clean package -DskipTests
eb init
eb create
eb deploy
```

### 🔍 Health Check

The application provides these endpoints:
- **Main App:** `http://localhost:8080/todos`
- **Health Check:** `http://localhost:8080/actuator/health` (if enabled)

### 🐛 Troubleshooting

#### Port Already in Use
```bash
# Find process using port 8080
lsof -i :8080
kill -9 <PID>

# Or use different port
java -jar target/todolist-app-1.0.0.jar --server.port=8081
```

#### Database Issues
```bash
# Reset database
rm todolist.db

# Check permissions
ls -la todolist.db
```

#### Build Issues
```bash
# Clean rebuild
mvn clean compile
mvn clean package -DskipTests

# Check Java version
java -version
mvn -version
```

---

**Ready for deployment! 🎉**
