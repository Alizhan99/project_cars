// pages/favorites_page.dart
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../models/car.dart';
import '../widgets/car_card.dart';
import '../screens/car_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _favoriteService = FavoriteService();
  List<Car> _favoriteCars = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');

    if (_userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final favorites = await _favoriteService.getUserFavorites(_userId!);
      setState(() {
        _favoriteCars = favorites;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(Car car) async {
    if (_userId == null) return;

    final success = await _favoriteService.removeFromFavorites(_userId!, car.id);
    if (success) {
      setState(() {
        _favoriteCars.removeWhere((c) => c.id == car.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${car.brand} ${car.name} removed from favorites'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userId == null) {
      return const Center(
        child: Text(
          'Please login to view favorites',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    if (_favoriteCars.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No favorite cars yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add cars to favorites from the home page',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _favoriteCars.length,
        itemBuilder: (context, index) {
          final car = _favoriteCars[index];
          return CarCard(
            car: car,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CarDetails(car: car),
                ),
              );
            },
            onFavoriteTap: () => _removeFromFavorites(car),
            isFavorite: true, // ✅ Все машины в избранном с красным сердечком
          );
        },
      ),
    );
  }
}