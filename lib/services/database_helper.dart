import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _orders = [];
  bool _isInitialized = false;

  // Initialize the database
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadUsersFromStorage();
    await _loadProductsFromStorage();
    await _loadOrdersFromStorage();

    _ensureAdminUser();

    _isInitialized = true;
    print(
      'Database initialized with ${_users.length} users, ${_products.length} products, ${_orders.length} orders',
    );
  }

  // Load users from shared preferences
  Future<void> _loadUsersFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users');
      if (usersJson != null && usersJson.isNotEmpty) {
        final List<dynamic> usersList = json.decode(usersJson);
        _users = usersList
            .map((user) => Map<String, dynamic>.from(user))
            .toList();
      } else {
        _users = [];
      }
    } catch (e) {
      print('Error loading users: $e');
      _users = [];
    }
  }

  // Load products from shared preferences
  Future<void> _loadProductsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('products');
      if (productsJson != null && productsJson.isNotEmpty) {
        final List<dynamic> productsList = json.decode(productsJson);
        _products = productsList
            .map((product) => Map<String, dynamic>.from(product))
            .toList();
      } else {
        _products = [];
      }
    } catch (e) {
      print('Error loading products: $e');
      _products = [];
    }
  }

  // Load orders from shared preferences
  Future<void> _loadOrdersFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('orders');
      if (ordersJson != null && ordersJson.isNotEmpty) {
        final List<dynamic> ordersList = json.decode(ordersJson);
        _orders = ordersList
            .map((order) => Map<String, dynamic>.from(order))
            .toList();
      } else {
        _orders = [];
      }
    } catch (e) {
      print('Error loading orders: $e');
      _orders = [];
    }
  }

  // Save all data to storage
  Future<void> _saveAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('users', json.encode(_users));
      await prefs.setString('products', json.encode(_products));
      await prefs.setString('orders', json.encode(_orders));
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  // ALWAYS ensure admin user exists
  void _ensureAdminUser() {
    bool adminExists = _users.any((user) => user['email'] == 'admin@admin.com');
    if (!adminExists) {
      _users.removeWhere((user) => user['email'] == 'admin@admin.com');
      _users.insert(0, {
        'id': 1,
        'name': 'Admin',
        'email': 'admin@admin.com',
        'password': 'admin123',
        'phone': '',
        'address': '',
      });
      _saveAllData();
    }
  }

  // Get next ID for any table
  int _getNextId(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return 1;
    int maxId = list
        .map((item) => item['id'] as int)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  // USER OPERATIONS
  Future<List<Map<String, dynamic>>> queryUsers({
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await initialize();
    List<Map<String, dynamic>> results = List.from(_users);

    if (where != null && whereArgs != null) {
      if (where.contains('email = ?') && whereArgs.isNotEmpty) {
        results = results
            .where((user) => user['email'] == whereArgs[0])
            .toList();
      }
      if (where.contains('password = ?') && whereArgs.length >= 2) {
        results = results
            .where((user) => user['password'] == whereArgs[1])
            .toList();
      }
    }
    return results;
  }

  Future<int> insertUser(Map<String, dynamic> values) async {
    await initialize();

    bool emailExists = _users.any(
      (user) =>
          user['email'] == values['email'] &&
          user['email'] != 'admin@admin.com',
    );
    if (emailExists) throw Exception('Email already exists');

    final newUser = Map<String, dynamic>.from(values);
    newUser['id'] = _getNextId(_users);
    _users.add(newUser);
    await _saveAllData();
    return newUser['id'];
  }

  List<Map<String, dynamic>> getAllUsers() => List.from(_users);

  // PRODUCT OPERATIONS
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    await initialize();
    return List.from(_products);
  }

  Future<int> addProduct(Map<String, dynamic> product) async {
    await initialize();

    final newProduct = Map<String, dynamic>.from(product);
    newProduct['id'] = _getNextId(_products);
    _products.add(newProduct);
    await _saveAllData();
    return newProduct['id'];
  }

  Future<int> updateProduct(int productId, Map<String, dynamic> updates) async {
    await initialize();

    final index = _products.indexWhere((p) => p['id'] == productId);
    if (index != -1) {
      _products[index] = {..._products[index], ...updates};
      await _saveAllData();
      return 1;
    }
    return 0;
  }

  Future<int> deleteProduct(int productId) async {
    await initialize();

    final initialLength = _products.length;
    _products.removeWhere((p) => p['id'] == productId);
    final removed = initialLength - _products.length;

    if (removed > 0) {
      await _saveAllData();
    }
    return removed;
  }

  // ORDER OPERATIONS
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    await initialize();
    return List.from(_orders);
  }

  Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
    await initialize();
    return _orders.where((order) => order['userId'] == userId).toList();
  }

  Future<int> createOrder(Map<String, dynamic> order) async {
    await initialize();

    final newOrder = Map<String, dynamic>.from(order);
    newOrder['id'] = _getNextId(_orders);
    newOrder['orderDate'] = DateTime.now().toString();
    _orders.add(newOrder);

    // Update product quantity
    final productId = order['productId'];
    final quantity = order['quantity'];
    await _updateProductQuantity(productId, -quantity);

    await _saveAllData();
    return newOrder['id'];
  }

  Future<void> _updateProductQuantity(int productId, int quantityChange) async {
    final index = _products.indexWhere((p) => p['id'] == productId);
    if (index != -1) {
      final currentQuantity = _products[index]['quantity'] ?? 0;
      final newQuantity = currentQuantity + quantityChange;
      _products[index]['quantity'] = newQuantity > 0 ? newQuantity : 0;
    }
  }

  // For compatibility
  Future<DatabaseHelper> get database async {
    await initialize();
    return this;
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    await initialize();

    if (table == 'users') {
      return await queryUsers(where: where, whereArgs: whereArgs);
    }
    return [];
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    if (table == 'users') {
      return await insertUser(values);
    }
    return 0;
  }

  Future<void> forceReload() async {}
}
