package com.example.carcatalog.controller;

import com.example.carcatalog.model.Car;
import com.example.carcatalog.repository.CarRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/cars")
@CrossOrigin(origins = "*")
public class CarController {

    @Autowired
    private CarRepository carRepository;

    //  Получить все машины
    @GetMapping
    public List<Car> getAllCars() {
        return carRepository.findAll();
    }

    //  Получить машину по ID
    @GetMapping("/{id}")
    public ResponseEntity<Car> getCarById(@PathVariable Long id) {
        Optional<Car> car = carRepository.findById(id);
        return car.map(ResponseEntity::ok)
                  .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Добавить машину (для админки)
    @PostMapping
    public ResponseEntity<Car> addCar(@RequestBody Car car) {
        Car savedCar = carRepository.save(car);
        return ResponseEntity.ok(savedCar);
    }

    //  Обновить машину (для админки)
    @PutMapping("/{id}")
    public ResponseEntity<Car> updateCar(@PathVariable Long id, @RequestBody Car carDetails) {
        Optional<Car> carOpt = carRepository.findById(id);
        
        if (carOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Car car = carOpt.get();
        car.setBrand(carDetails.getBrand());
        car.setModel(carDetails.getModel());
        car.setYear(carDetails.getYear());
        car.setPrice(carDetails.getPrice());
        car.setImageUrl(carDetails.getImageUrl());
        car.setDescription(carDetails.getDescription());
        car.setColor(carDetails.getColor());
        car.setMileage(carDetails.getMileage());
        car.setFuelType(carDetails.getFuelType());
        car.setTransmission(carDetails.getTransmission());
        
        Car updatedCar = carRepository.save(car);
        return ResponseEntity.ok(updatedCar);
    }

    // Удалить машину (для админки)
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCar(@PathVariable Long id) {
        if (!carRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        
        carRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    //  УЛУЧШЕННЫЙ ПОИСК С ФИЛЬТРАЦИЕЙ И СОРТИРОВКОЙ
    @GetMapping("/search")
    public List<Car> searchCars(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String brand,
            @RequestParam(required = false) String fuelType,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice,
            @RequestParam(required = false) Integer minYear,
            @RequestParam(required = false) Integer maxYear,
            @RequestParam(required = false) String sortBy,
            @RequestParam(required = false) String sortOrder
    ) {
        List<Car> allCars = carRepository.findAll();
        
        System.out.println("Search request received:");
        System.out.println(" - search: " + search);
        System.out.println(" - brand: " + brand);
        System.out.println(" - fuelType: " + fuelType);
        System.out.println(" - minPrice: " + minPrice);
        System.out.println(" - maxPrice: " + maxPrice);
        System.out.println(" - minYear: " + minYear);
        System.out.println(" - maxYear: " + maxYear);
        System.out.println(" - sortBy: " + sortBy);
        System.out.println(" - sortOrder: " + sortOrder);
        
        // Фильтрация
        List<Car> filteredCars = allCars.stream()
                .filter(car -> search == null || search.isEmpty() || 
                        car.getBrand().toLowerCase().contains(search.toLowerCase()) ||
                        car.getModel().toLowerCase().contains(search.toLowerCase()))
                .filter(car -> brand == null || brand.isEmpty() || 
                        car.getBrand().equalsIgnoreCase(brand))
                .filter(car -> fuelType == null || fuelType.isEmpty() || 
                        (car.getFuelType() != null && car.getFuelType().equalsIgnoreCase(fuelType)))
                .filter(car -> minPrice == null || car.getPrice() >= minPrice)
                .filter(car -> maxPrice == null || car.getPrice() <= maxPrice)
                .filter(car -> minYear == null || car.getYear() >= minYear)
                .filter(car -> maxYear == null || car.getYear() <= maxYear)
                .collect(Collectors.toList());
        
        // Сортировка
        if (sortBy != null && !sortBy.isEmpty()) {
            filteredCars = sortCars(filteredCars, sortBy, sortOrder);
        }
        
        System.out.println("Filtered cars count: " + filteredCars.size());
        return filteredCars;
    }

    //  ПОЛУЧИТЬ УНИКАЛЬНЫЕ БРЕНДЫ
    @GetMapping("/brands")
    public List<String> getBrands() {
        List<String> brands = carRepository.findAll().stream()
                .map(Car::getBrand)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
        
        System.out.println("Returning brands: " + brands);
        return brands;
    }

    //  ВСПОМОГАТЕЛЬНЫЙ МЕТОД ДЛЯ СОРТИРОВКИ
    private List<Car> sortCars(List<Car> cars, String sortBy, String sortOrder) {
        boolean ascending = !"desc".equalsIgnoreCase(sortOrder);
        
        Comparator<Car> comparator;
        switch (sortBy.toLowerCase()) {
            case "price":
                comparator = Comparator.comparing(Car::getPrice);
                break;
            case "year":
                comparator = Comparator.comparing(Car::getYear);
                break;
            case "brand":
                comparator = Comparator.comparing(Car::getBrand);
                break;
            default:
                comparator = Comparator.comparing(Car::getId);
        }
        
        if (!ascending) {
            comparator = comparator.reversed();
        }
        
        return cars.stream()
                .sorted(comparator)
                .collect(Collectors.toList());
    }
}