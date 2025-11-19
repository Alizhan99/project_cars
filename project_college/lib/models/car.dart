// models/car.dart
class Car {
  final int id;
  final String name; // Будет использовать model из бэкенда
  final String brand;
  final int year;
  final double price;
  final String imageUrl;
  final String description;
  final String? color;
  final int? mileage;
  final String? fuelType;
  final String? transmission;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.year,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.color,
    this.mileage,
    this.fuelType,
    this.transmission,
  });

// models/car.dart
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] ?? 0,
      name: json['model'] ?? 'Unknown',
      brand: json['brand'] ?? 'Unknown',
      year: json['year'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      color: json['color'],
      mileage: json['mileage'],
      fuelType: json['fuelType'],
      transmission: json['transmission'],
    );
  }
}