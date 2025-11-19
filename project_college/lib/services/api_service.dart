import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car.dart';

class ApiService {
  final String baseUrl = 'http://10.239.33.149:8080/api';

  Future<List<Car>> fetchCars() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cars'),
      ).timeout(const Duration(seconds: 10));

      print('Fetching cars from: $baseUrl/cars');
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Car.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load cars: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cars: $e');
      throw Exception('Failed to load cars: $e');
    }
  }



  // Поиск и фильтрация машин
  Future<List<Car>> searchCars({
    String? search,
    String? brand,
    String? fuelType,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final params = <String, String>{};

      // Добавляем параметры только если они не null и не пустые
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (brand != null && brand.isNotEmpty) params['brand'] = brand;
      if (fuelType != null && fuelType.isNotEmpty) params['fuelType'] = fuelType;
      if (minPrice != null) params['minPrice'] = minPrice.toString();
      if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
      if (minYear != null) params['minYear'] = minYear.toString();
      if (maxYear != null) params['maxYear'] = maxYear.toString();
      if (sortBy != null && sortBy.isNotEmpty) params['sortBy'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty) params['sortOrder'] = sortOrder;

      final uri = Uri.parse('$baseUrl/cars/search').replace(queryParameters: params);

      print('Search URL: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      print('Search response status: ${response.statusCode}');
      print('Search response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Car.fromJson(e)).toList();
      } else {
        throw Exception('Failed to search cars: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching cars: $e');
      throw Exception('Failed to search cars: $e');
    }
  }

  // Получить список уникальных брендов
  Future<List<String>> getBrands() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cars/brands'),
      ).timeout(const Duration(seconds: 10));

      print('Fetching brands from: $baseUrl/cars/brands');
      print('Brands response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        print('Failed to load brands: ${response.statusCode}');
        // Если endpoint не реализован, возвращаем пустой список
        return [];
      }
    } catch (e) {
      print('Error fetching brands: $e');
      // В случае ошибки возвращаем пустой список
      return [];
    }
  }

  // Получить машину по ID
  Future<Car> fetchCarById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cars/$id'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Car.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load car');
      }
    } catch (e) {
      print('Error fetching car: $e');
      throw Exception('Failed to load car: $e');
    }
  }


  Future<bool> checkSearchEndpoint() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cars/search'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 400;
    } catch (e) {
      print('Search endpoint not available: $e');
      return false;
    }
  }


  Future<List<Car>> searchCarsFallback({
    String? search,
    String? brand,
    String? fuelType,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      // Сначала пытаемся использовать серверный поиск
      return await searchCars(
        search: search,
        brand: brand,
        fuelType: fuelType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minYear: minYear,
        maxYear: maxYear,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } catch (e) {
      print('Server search failed, using client-side fallback: $e');

      // Fallback: клиентская фильтрация
      final allCars = await fetchCars();
      List<Car> filteredCars = allCars;

      // Применяем фильтры на клиенте
      if (search != null && search.isNotEmpty) {
        filteredCars = filteredCars.where((car) =>
        car.brand.toLowerCase().contains(search.toLowerCase()) ||
            car.name.toLowerCase().contains(search.toLowerCase())).toList();
      }

      if (brand != null && brand.isNotEmpty) {
        filteredCars = filteredCars.where((car) => car.brand == brand).toList();
      }

      if (fuelType != null && fuelType.isNotEmpty) {
        filteredCars = filteredCars.where((car) => car.fuelType == fuelType).toList();
      }

      if (minPrice != null) {
        filteredCars = filteredCars.where((car) => car.price >= minPrice).toList();
      }

      if (maxPrice != null) {
        filteredCars = filteredCars.where((car) => car.price <= maxPrice).toList();
      }

      if (minYear != null) {
        filteredCars = filteredCars.where((car) => car.year >= minYear).toList();
      }

      if (maxYear != null) {
        filteredCars = filteredCars.where((car) => car.year <= maxYear).toList();
      }

      // Сортировка на клиенте
      if (sortBy != null) {
        filteredCars = _sortCarsClientSide(filteredCars, sortBy, sortOrder);
      }

      return filteredCars;
    }
  }

  // Вспомогательный метод для клиентской сортировки
  List<Car> _sortCarsClientSide(List<Car> cars, String sortBy, String? sortOrder) {
    bool ascending = sortOrder != 'desc';

    switch (sortBy.toLowerCase()) {
      case 'price':
        cars.sort((a, b) => ascending ?
        a.price.compareTo(b.price) : b.price.compareTo(a.price));
        break;
      case 'year':
        cars.sort((a, b) => ascending ?
        a.year.compareTo(b.year) : b.year.compareTo(a.year));
        break;
      case 'brand':
        cars.sort((a, b) => ascending ?
        a.brand.compareTo(b.brand) : b.brand.compareTo(a.brand));
        break;
    }

    return cars;
  }
}