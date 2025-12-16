import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  static const String _wishlistKey = 'wishlist_items';

  List<Map<String, dynamic>> get items => _items;

  int get itemCount => _items.length;

  WishlistProvider() {
    _loadWishlistFromPrefs();
  }

  Future<void> _loadWishlistFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getString(_wishlistKey);
    if (wishlistJson != null) {
      final List<dynamic> wishlistList = json.decode(wishlistJson);
      _items = wishlistList
          .map((item) => item as Map<String, dynamic>)
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveWishlistToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = json.encode(_items);
    await prefs.setString(_wishlistKey, wishlistJson);
  }

  void addToWishlist(Map<String, dynamic> product) {
    final existingIndex = _items.indexWhere(
      (item) => item['id'] == product['id'],
    );
    if (existingIndex < 0) {
      _items.add(product);
      _saveWishlistToPrefs();
      notifyListeners();
    }
  }

  void removeFromWishlist(int productId) {
    _items.removeWhere((item) => item['id'] == productId);
    _saveWishlistToPrefs();
    notifyListeners();
  }

  bool isInWishlist(int productId) {
    return _items.any((item) => item['id'] == productId);
  }

  void clearWishlist() {
    _items.clear();
    _saveWishlistToPrefs();
    notifyListeners();
  }
}
