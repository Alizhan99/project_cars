import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../models/car.dart';
import '../widgets/car_card.dart';
import 'car_details.dart';
import 'admin_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  final FavoriteService _favoriteService = FavoriteService();

  Future<List<Car>>? _filteredCarsFuture;
  List<Car> _displayedCars = [];

  bool isLoggedIn = false;
  bool _isAdmin = false;
  Map<int, bool> _favoriteStatus = {};
  int? _userId;

  // Переменные для фильтров
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedBrand;
  String? _selectedFuelType;
  String? _selectedSort;
  String _sortOrder = 'asc';
  double _minPrice = 0;
  double _maxPrice = 100000;
  int _minYear = 1990;
  int _maxYear = 2024;

  // Списки для фильтров
  List<String> _brands = [];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> _sortOptions = ['price', 'year', 'brand'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkLoginStatus();
    await _loadBrands();
    _applyFilters();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await api.getBrands();
      setState(() {
        _brands = brands;
      });
    } catch (e) {
      print('Error loading brands: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('id');
    final isAdmin = prefs.getBool('isAdmin') ?? false;

    setState(() {
      isLoggedIn = token != null;
      _userId = userId;
      _isAdmin = isAdmin;
    });
  }

  Future<List<Car>> _loadCarsWithFiltersAndFavorites() async {
    final cars = await api.searchCars(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      brand: _selectedBrand,
      fuelType: _selectedFuelType,
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 100000 ? _maxPrice : null,
      minYear: _minYear > 1990 ? _minYear : null,
      maxYear: _maxYear < 2024 ? _maxYear : null,
      sortBy: _selectedSort,
      sortOrder: _sortOrder,
    );

    // Загружаем статусы избранного
    if (isLoggedIn && _userId != null) {
      for (final car in cars) {
        try {
          final isFavorite = await _favoriteService.checkFavorite(_userId!, car.id);
          _favoriteStatus[car.id] = isFavorite;
        } catch (e) {
          print('Error loading favorite status for car ${car.id}: $e');
          _favoriteStatus[car.id] = false;
        }
      }
    } else {
      for (final car in cars) {
        _favoriteStatus[car.id] = false;
      }
    }

    return cars;
  }

  void _applyFilters() {
    setState(() {
      _filteredCarsFuture = _loadCarsWithFiltersAndFavorites();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedBrand = null;
      _selectedFuelType = null;
      _selectedSort = null;
      _sortOrder = 'asc';
      _minPrice = 0;
      _maxPrice = 100000;
      _minYear = 1990;
      _maxYear = 2024;
    });
    _applyFilters();
  }

  void _refreshCars() {
    _applyFilters();
  }

  Future<void> _refreshData() async {
    _applyFilters();
  }


  void _goToAdminPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminPanel()),
    ).then((_) {
      _refreshCars(); // Обновляем данные после возврата из админки
    });
  }


  void _showUserInfo() {
    if (isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isAdmin ? 'Logged in as Admin' : 'Logged in as User',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _isAdmin ? Colors.purple : Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ✅ ДОБАВЛЕНО: Добавить в избранное
  Future<void> _addToFavorites(Car car) async {
    if (!isLoggedIn || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to log in to add to favorites'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await _favoriteService.addToFavorites(_userId!, car.id);

    if (success) {
      setState(() {
        _favoriteStatus[car.id] = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${car.brand} ${car.name} added to favorites!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add to favorites'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ ДОБАВЛЕНО: Удалить из избранного
  Future<void> _removeFromFavorites(Car car) async {
    if (_userId == null) return;

    final success = await _favoriteService.removeFromFavorites(_userId!, car.id);

    if (success) {
      setState(() {
        _favoriteStatus[car.id] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${car.brand} ${car.name} removed from favorites!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }


  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.filter_list),
              SizedBox(width: 8),
              Text('Filters & Sort'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Сортировка
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSort,
                            decoration: const InputDecoration(
                              hintText: 'Default',
                              border: OutlineInputBorder(),
                            ),
                            items: _sortOptions.map((sort) {
                              return DropdownMenuItem(
                                value: sort,
                                child: Text(sort[0].toUpperCase() + sort.substring(1)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                _selectedSort = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _sortOrder,
                          items: const [
                            DropdownMenuItem(value: 'asc', child: Text('↑ Asc')),
                            DropdownMenuItem(value: 'desc', child: Text('↓ Desc')),
                          ],
                          onChanged: _selectedSort == null ? null : (value) {
                            setDialogState(() {
                              _sortOrder = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Бренд
                DropdownButtonFormField<String>(
                  value: _selectedBrand,
                  decoration: const InputDecoration(
                    labelText: 'Brand',
                    border: OutlineInputBorder(),
                  ),
                  items: _brands.map((brand) {
                    return DropdownMenuItem(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedBrand = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Тип топлива
                DropdownButtonFormField<String>(
                  value: _selectedFuelType,
                  decoration: const InputDecoration(
                    labelText: 'Fuel Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _fuelTypes.map((fuel) {
                    return DropdownMenuItem(
                      value: fuel,
                      child: Text(fuel),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedFuelType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Цена
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Range:'),
                    Row(
                      children: [
                        Text('\$${_minPrice.toInt()}'),
                        const Spacer(),
                        Text('\$${_maxPrice.toInt()}'),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_minPrice, _maxPrice),
                      min: 0,
                      max: 100000,
                      divisions: 20,
                      onChanged: (values) {
                        setDialogState(() {
                          _minPrice = values.start;
                          _maxPrice = values.end;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Год
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Year Range:'),
                    Row(
                      children: [
                        Text(_minYear.toString()),
                        const Spacer(),
                        Text(_maxYear.toString()),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_minYear.toDouble(), _maxYear.toDouble()),
                      min: 1990,
                      max: 2024,
                      divisions: 34,
                      onChanged: (values) {
                        setDialogState(() {
                          _minYear = values.start.toInt();
                          _maxYear = values.end.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resetFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Reset All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Catalog'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: Icon(
                _isAdmin ? Icons.verified_user : Icons.person,
                color: _isAdmin ? Colors.purple : Colors.white,
              ),
              onPressed: _showUserInfo,
              tooltip: _isAdmin ? 'Admin User' : 'Regular User',
            ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: _goToAdminPanel,
              tooltip: 'Admin Panel',
              color: Colors.purple,
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filters & Sort',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCars,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by brand or model...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _applyFilters();
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                // Дебаунс для поиска (чтобы не делать запрос на каждую букву)
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchQuery == value) {
                    _applyFilters();
                  }
                });
              },
            ),
          ),
          // Индикатор активных фильтров
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getActiveFiltersText(),
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: FutureBuilder<List<Car>>(
                future: _filteredCarsFuture,
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
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshCars,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.car_rental, size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No cars found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          if (_hasActiveFilters()) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Try changing your filters',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _resetFilters,
                              child: const Text('Reset Filters'),
                            ),
                          ] else if (_isAdmin) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Add cars in Admin Panel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  final cars = snapshot.data!;

                  return Column(
                    children: [
                      if (_isAdmin)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          color: Colors.purple.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.admin_panel_settings, size: 16, color: Colors.purple),
                              const SizedBox(width: 4),
                              Text(
                                'Admin Mode - ${cars.length} cars',
                                style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Информация о сортировке
                      if (_selectedSort != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(4),
                          color: Colors.green.withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sort, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Sorted by ${_selectedSort!} (${_sortOrder == 'asc' ? '↑' : '↓'})',
                                style: const TextStyle(fontSize: 12, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: cars.length,
                          itemBuilder: (context, index) {
                            final car = cars[index];
                            final isFavorite = _favoriteStatus[car.id] ?? false;

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
                              onFavoriteTap: () {
                                if (isFavorite) {
                                  _removeFromFavorites(car);
                                } else {
                                  _addToFavorites(car);
                                }
                              },
                              isFavorite: isFavorite,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _selectedBrand != null ||
        _selectedFuelType != null ||
        _selectedSort != null ||
        _minPrice > 0 ||
        _maxPrice < 100000 ||
        _minYear > 1990 ||
        _maxYear < 2024;
  }

  String _getActiveFiltersText() {
    List<String> filters = [];
    if (_searchQuery.isNotEmpty) filters.add('search: "$_searchQuery"');
    if (_selectedBrand != null) filters.add('brand: $_selectedBrand');
    if (_selectedFuelType != null) filters.add('fuel: $_selectedFuelType');
    if (_selectedSort != null) filters.add('sort: $_selectedSort ${_sortOrder == 'asc' ? '↑' : '↓'}');
    if (_minPrice > 0 || _maxPrice < 100000) {
      filters.add('price: \$${_minPrice.toInt()}-\$${_maxPrice.toInt()}');
    }
    if (_minYear > 1990 || _maxYear < 2024) {
      filters.add('year: $_minYear-$_maxYear');
    }
    return 'Active: ${filters.join(', ')}';
  }
}