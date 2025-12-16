import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final int productId;
  final String name;
  final double price;
  final String imagePath;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'price': price,
    'imagePath': imagePath,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['productId'],
    name: json['name'],
    price: json['price'],
    imagePath: json['imagePath'] ?? '',
    quantity: json['quantity'],
  );
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  static const String _cartKey = 'cart_items';

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  CartProvider() {
    _loadCartFromPrefs();
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      final List<dynamic> cartList = json.decode(cartJson);
      _items = cartList.map((item) => CartItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere(
      (i) => i.productId == item.productId,
    );
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    _saveCartToPrefs();
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    _saveCartToPrefs();
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(productId);
      } else {
        _items[index].quantity = quantity;
        _saveCartToPrefs();
        notifyListeners();
      }
    }
  }

  void incrementQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity++;
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void decrementQuantity(int productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        _saveCartToPrefs();
        notifyListeners();
      } else {
        removeItem(productId);
      }
    }
  }

  void clearCart() {
    _items.clear();
    _saveCartToPrefs();
    notifyListeners();
  }

  bool isInCart(int productId) {
    return _items.any((item) => item.productId == productId);
  }

  CartItem? getItem(int productId) {
    return _items.firstWhere((item) => item.productId == productId);
  }
}
