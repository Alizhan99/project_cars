// services/admin_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car.dart';

class AdminService {
  final String baseUrl = 'http://10.239.33.149:8080/api/cars';

  // Создать новую машину
  Future<Car?> createCar(Car car) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'brand': car.brand,
          'model': car.name,
          'year': car.year,
          'price': car.price,
          'imageUrl': car.imageUrl,
          'description': car.description,
          'color': car.color,
          'mileage': car.mileage,
          'fuelType': car.fuelType,
          'transmission': car.transmission,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Create car response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Car.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error creating car: $e');
      return null;
    }
  }

  // Обновить машину
  Future<Car?> updateCar(Car car) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${car.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'brand': car.brand,
          'model': car.name,
          'year': car.year,
          'price': car.price,
          'imageUrl': car.imageUrl,
          'description': car.description,
          'color': car.color,
          'mileage': car.mileage,
          'fuelType': car.fuelType,
          'transmission': car.transmission,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Update car response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Car.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error updating car: $e');
      return null;
    }
  }

  // Удалить машину
  Future<bool> deleteCar(int carId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$carId'),
      ).timeout(const Duration(seconds: 10));

      print('Delete car response: ${response.statusCode}');


      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting car: $e');
      return false;
    }
  }
}