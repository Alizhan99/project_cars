package com.example.carcatalog.controller;

import com.example.carcatalog.model.Car;
import com.example.carcatalog.model.Favorite;
import com.example.carcatalog.model.User;
import com.example.carcatalog.repository.CarRepository;
import com.example.carcatalog.repository.FavoriteRepository;
import com.example.carcatalog.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/favorites")
@CrossOrigin(origins = "*")
public class FavoriteController {

    @Autowired
    private FavoriteRepository favoriteRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CarRepository carRepository;

    //  Получить избранное пользователя
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Car>> getUserFavorites(@PathVariable Long userId) {
        List<Favorite> favorites = favoriteRepository.findByUserId(userId);
        List<Car> cars = favorites.stream()
                                  .map(Favorite::getCar)
                                  .collect(Collectors.toList());
        return ResponseEntity.ok(cars);
    }

    // Добавить в избранное
    @PostMapping
    public ResponseEntity<Map<String, Object>> addToFavorites(@RequestBody Map<String, Long> body) {
        Long userId = body.get("userId");
        Long carId = body.get("carId");

        if (userId == null || carId == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "userId and carId are required"));
        }

        if (favoriteRepository.existsByUserIdAndCarId(userId, carId)) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Already in favorites", "success", false));
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        Car car = carRepository.findById(carId)
                .orElseThrow(() -> new RuntimeException("Car not found"));

        Favorite favorite = new Favorite(user, car);
        favoriteRepository.save(favorite);

        return ResponseEntity.ok(Map.of(
            "message", "Added to favorites", 
            "success", true
        ));
    }

    //  Удалить из избранного
    @DeleteMapping
    @Transactional
    public ResponseEntity<Map<String, Object>> removeFromFavorites(
            @RequestParam Long userId,
            @RequestParam Long carId
    ) {
        if (!favoriteRepository.existsByUserIdAndCarId(userId, carId)) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Not in favorites", "success", false));
        }

        favoriteRepository.deleteByUserIdAndCarId(userId, carId);
        return ResponseEntity.ok(Map.of(
            "message", "Removed from favorites", 
            "success", true
        ));
    }

    // Проверить, в избранном ли машина
    @GetMapping("/check")
    public ResponseEntity<Map<String, Boolean>> checkFavorite(
            @RequestParam Long userId,
            @RequestParam Long carId
    ) {
        boolean isFavorite = favoriteRepository.existsByUserIdAndCarId(userId, carId);
        return ResponseEntity.ok(Map.of("isFavorite", isFavorite));
    }
}