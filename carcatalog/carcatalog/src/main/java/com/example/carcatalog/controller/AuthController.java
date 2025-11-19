package com.example.carcatalog.controller;

import com.example.carcatalog.model.User;
import com.example.carcatalog.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserService userService;

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String email = body.get("email");
        String password = body.get("password");

        if (username == null || email == null || password == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Missing username, email or password"));
        }

        User user = new User(username, email, password, false);
        String result = userService.registerUser(user);

        if (!result.equals("User registered successfully")) {
            return ResponseEntity.badRequest().body(Map.of("error", result));
        }

        Map<String, Object> resp = new HashMap<>();
        resp.put("token", UUID.randomUUID().toString());
        resp.put("id", user.getId());
        resp.put("username", user.getUsername());
        resp.put("email", user.getEmail());
        resp.put("isAdmin", user.isAdmin());

        return ResponseEntity.ok(resp);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        
        String email = body.get("email");
        String password = body.get("password");

        if (email == null || password == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Missing email or password"));
        }

        
        Optional<User> userOpt = userService.loginUserByEmail(email, password);

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid email or password"));
        }

        User user = userOpt.get();
        Map<String, Object> resp = new HashMap<>();
        
        resp.put("token", UUID.randomUUID().toString());
        resp.put("id", user.getId());
        resp.put("username", user.getUsername());
        resp.put("email", user.getEmail());
        resp.put("isAdmin", user.isAdmin());

        return ResponseEntity.ok(resp);
    }
}