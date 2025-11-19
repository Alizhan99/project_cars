import 'package:flutter/material.dart';
import '../models/car.dart';

class CarDetails extends StatelessWidget {
  final Car car;
  const CarDetails({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${car.brand} ${car.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(car.imageUrl, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text('${car.brand} ${car.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Year: ${car.year}'),
            const SizedBox(height: 8),
            Text('Price: \$${car.price.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            Text(car.description, textAlign: TextAlign.justify),
          ],
        ),
      ),
    );
  }
}
