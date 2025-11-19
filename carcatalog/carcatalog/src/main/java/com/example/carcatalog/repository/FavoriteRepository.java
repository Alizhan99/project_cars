package com.example.carcatalog.repository;

import com.example.carcatalog.model.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    // Получить все избранные машины пользователя
    List<Favorite> findByUserId(Long userId);
    
    // Найти конкретную запись избранного
    Optional<Favorite> findByUserIdAndCarId(Long userId, Long carId);
    
    // Проверить, есть ли машина в избранном
    boolean existsByUserIdAndCarId(Long userId, Long carId);
    
    // Удалить из избранного
    void deleteByUserIdAndCarId(Long userId, Long carId);
}