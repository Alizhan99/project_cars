package com.example.carcatalog.controller;

import com.example.carcatalog.model.User;
import com.example.carcatalog.repository.UserService;
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
        User user = new User(body.get("username"), body.get("email"), body.get("password"), false);
        String result = userService.registerUser(user);
        if (!result.equals("User registered successfully")) {
            return ResponseEntity.badRequest().body(Map.of("error", result));
        }
        return ResponseEntity.ok(Map.of("message", "User registered successfully"));
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        Optional<User> userOpt = userService.loginUserByEmail(body.get("email"), body.get("password"));
        if (userOpt.isEmpty()) return ResponseEntity.status(401).body(Map.of("error", "Invalid credentials"));

        User user = userOpt.get();
        Map<String, Object> resp = new HashMap<>();
        resp.put("token", UUID.randomUUID().toString());
        resp.put("id", user.getId());
        resp.put("username", user.getUsername());
        resp.put("email", user.getEmail());
        resp.put("isAdmin", user.isAdmin());
        return ResponseEntity.ok(resp);
    }

    // Эндпоинт для смены пароля
    @PostMapping("/{id}/change-password")
    public ResponseEntity<?> changePassword(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String oldPwd = body.get("oldPassword");
        String newPwd = body.get("newPassword");
        
        if (userService.changePassword(id, oldPwd, newPwd)) {
            return ResponseEntity.ok(Map.of("message", "Пароль успешно изменен"));
        } else {
            return ResponseEntity.status(401).body(Map.of("message", "Старый пароль неверный"));
        }
    }
}