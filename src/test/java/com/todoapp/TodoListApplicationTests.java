package com.todoapp;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

/**
 * Basic integration test to verify the application context loads correctly
 */
@SpringBootTest
@ActiveProfiles("test")
class TodoListApplicationTests {

    @Test
    void contextLoads() {
        // This test will pass if the application context loads successfully
        // It verifies that all beans can be created and autowired correctly
    }
}
