import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car.dart';

class FavoriteService {
  final String baseUrl = 'http://10.239.33.149:8080/api/favorites';

  // Получить избранные машины пользователя
  Future<List<Car>> getUserFavorites(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Car.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      throw Exception('Failed to load favorites: $e');
    }
  }

  // Добавить в избранное
  Future<bool> addToFavorites(int userId, int carId) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'carId': carId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Удалить из избранного
  Future<bool> removeFromFavorites(int userId, int carId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl?userId=$userId&carId=$carId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Проверить, в избранном ли машина
  Future<bool> checkFavorite(int userId, int carId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check?userId=$userId&carId=$carId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isFavorite'] == true;
      }
      return false;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }
}