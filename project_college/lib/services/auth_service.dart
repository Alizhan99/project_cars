import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8080/api/auth';

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('id', data['id']); // Важно сохранить ID
        await prefs.setString('username', data['username']);
        await prefs.setString('email', data['email']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Метод для смены пароля
  Future<Map<String, dynamic>> changePassword(int userId, String oldPwd, String newPwd) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$userId/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'oldPassword': oldPwd, 'newPassword': newPwd}),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Ошибка сети'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> register(String u, String e, String p) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': u, 'email': e, 'password': p}),
    );
    return response.statusCode == 200;
  }
}