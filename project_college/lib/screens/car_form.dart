// screens/car_form.dart
import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/admin_service.dart';

class CarForm extends StatefulWidget {
  final Car? car;
  final VoidCallback onSave;

  const CarForm({super.key, this.car, required this.onSave});

  @override
  State<CarForm> createState() => _CarFormState();
}

class _CarFormState extends State<CarForm> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();

  String? _fuelType;
  String? _transmission;

  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> _transmissions = ['Automatic', 'Manual'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _brandController.text = widget.car!.brand;
      _modelController.text = widget.car!.name;
      _yearController.text = widget.car!.year.toString();
      _priceController.text = widget.car!.price.toStringAsFixed(0);
      _imageUrlController.text = widget.car!.imageUrl;
      _descriptionController.text = widget.car!.description;
      _colorController.text = widget.car!.color ?? '';
      _mileageController.text = widget.car!.mileage?.toString() ?? '';
      _fuelType = widget.car!.fuelType;
      _transmission = widget.car!.transmission;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final car = Car(
      id: widget.car?.id ?? 0,
      brand: _brandController.text.trim(),
      name: _modelController.text.trim(),
      year: int.tryParse(_yearController.text) ?? 0,
      price: double.tryParse(_priceController.text) ?? 0,
      imageUrl: _imageUrlController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      mileage: int.tryParse(_mileageController.text),
      fuelType: _fuelType,
      transmission: _transmission,
    );

    final success = widget.car == null
        ? await _adminService.createCar(car) != null
        : await _adminService.updateCar(car) != null;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Car ${widget.car == null ? 'created' : 'updated'} successfully'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSave();
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save car'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car == null ? 'Add New Car' : 'Edit Car'),
        backgroundColor: Colors.purple,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand *'),
                validator: (value) => value?.isEmpty == true ? 'Brand is required' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model *'),
                validator: (value) => value?.isEmpty == true ? 'Model is required' : null,
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Year is required';
                  final year = int.tryParse(value!);
                  if (year == null || year < 1900 || year > 2030) {
                    return 'Enter valid year (1900-2030)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Price is required';
                  final price = double.tryParse(value!);
                  if (price == null || price <= 0) return 'Enter valid price';
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Mileage (km)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: const InputDecoration(labelText: 'Fuel Type'),
                items: _fuelTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _fuelType = value),
              ),
              DropdownButtonFormField<String>(
                value: _transmission,
                decoration: const InputDecoration(labelText: 'Transmission'),
                items: _transmissions.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _transmission = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.car == null ? 'Create Car' : 'Update Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}