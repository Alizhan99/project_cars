// screens/admin_panel.dart
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/api_service.dart';
import '../models/car.dart';
import 'car_form.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final ApiService _apiService = ApiService();
  final AdminService _adminService = AdminService();
  late Future<List<Car>> _cars;
  List<Car> _filteredCars = [];

  @override
  void initState() {
    super.initState();
    _cars = _apiService.fetchCars();
    _loadCars();
  }

  Future<void> _loadCars() async {
    final cars = await _cars;
    setState(() {
      _filteredCars = cars;
    });
  }

  void _refreshCars() {
    setState(() {
      _cars = _apiService.fetchCars();
    });
    _loadCars();
  }

  Future<void> _deleteCar(Car car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Car'),
        content: Text('Are you sure you want to delete ${car.brand} ${car.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _adminService.deleteCar(car.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${car.brand} ${car.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshCars();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete car'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editCar(Car car) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarForm(car: car, onSave: _refreshCars),
      ),
    );
  }

  void _addNewCar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarForm(onSave: _refreshCars),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCars,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCar,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Car>>(
        future: _cars,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshCars,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || _filteredCars.isEmpty) {
            return const Center(
              child: Text('No cars available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _filteredCars.length,
            itemBuilder: (context, index) {
              final car = _filteredCars[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Изображение машины
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          car.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.directions_car, size: 30),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Информация о машине
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car.brand} ${car.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Year: ${car.year} • \$${car.price.toStringAsFixed(0)}'),
                            if (car.fuelType != null) Text('Fuel: ${car.fuelType}'),
                          ],
                        ),
                      ),

                      // Кнопки действий
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editCar(car),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCar(car),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}