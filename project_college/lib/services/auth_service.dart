import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.239.33.149:8080/api/auth';

  Future<bool> login(String email, String password) async {
    try {
      print('=== LOGIN DEBUG START ===');
      print('Email parameter: "$email"');
      print('Password length: ${password.length}');

      final Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      print('Request body map: $requestBody');

      final String jsonBody = jsonEncode(requestBody);
      print('JSON body: $jsonBody');
      print('Sending POST to: $baseUrl/login');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonBody,
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('=== LOGIN DEBUG END ===');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('token', data['token'] ?? 'no_token');
        await prefs.setString('username', data['username'] ?? '');
        await prefs.setString('email', data['email'] ?? email);
        await prefs.setInt('user_id', data['id']);
        await prefs.setBool('isAdmin', data['isAdmin'] ?? false);

        return true;
      } else {
        print('Login failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      print('=== REGISTER DEBUG START ===');
      print('Username: "$username"');
      print('Email: "$email"');
      print('Password length: ${password.length}');

      final Map<String, dynamic> requestBody = {
        'username': username,
        'email': email,
        'password': password,
      };

      print('Request body: $requestBody');

      final String jsonBody = jsonEncode(requestBody);
      print('JSON body: $jsonBody');
      print('Sending POST to: $baseUrl/register');

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonBody,
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('=== REGISTER DEBUG END ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdmin') ?? false;
  }
}