import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  String username = '';
  String email = '';
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getString('token') != null;
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldController, decoration: const InputDecoration(labelText: 'Old Password'), obscureText: true),
            TextField(controller: newController, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getInt('id');
              if (userId != null) {
                final result = await _authService.changePassword(userId, oldController.text, newController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: const Text('Login'),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80, color: Colors.blue),
          Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _showChangePasswordDialog,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Change Password'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}