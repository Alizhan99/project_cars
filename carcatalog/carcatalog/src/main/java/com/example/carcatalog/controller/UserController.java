package com.example.carcatalog.controller;

import com.example.carcatalog.model.User;
import com.example.carcatalog.repository.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {
    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public String register(@RequestBody User user) {
        return userService.registerUser(user);
    }

    @PostMapping("/login")
    public Object login(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");

        Optional<User> userOpt = userService.loginUser(username, password);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            return Map.of(
                    "message", "Login successful",
                    "username", user.getUsername(),
                    "isAdmin", user.isAdmin()
            );
        } else {
            return Map.of("message", "Invalid username or password");
        }
    }
}
