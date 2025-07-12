package com.todoapp.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Simplified Security configuration to prevent hanging issues
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Allow all requests without authentication
            .authorizeHttpRequests(authz -> authz
                .anyRequest().permitAll()
            )
            // Disable CSRF for simplicity
            .csrf(csrf -> csrf.disable())
            // Disable form login and basic auth
            .formLogin(form -> form.disable())
            .httpBasic(basic -> basic.disable());

        return http.build();
    }
}
