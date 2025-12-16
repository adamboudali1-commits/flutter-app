import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/client_home_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/products_list_screen.dart';
import 'screens/orders_list_screen.dart';
import 'services/database_helper.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  MyApp({super.key}) {
    // Initialize database when app starts
    _dbHelper.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'E-Commerce App',
          theme: themeProvider.getTheme(),
          home: LoginScreen(),
          routes: {
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/admin': (context) => AdminHomeScreen(),
            '/client': (context) => ClientHomeScreen(),
            '/add-product': (context) => AddProductScreen(),
            '/products': (context) => ProductsListScreen(isAdmin: false),
            '/admin-products': (context) => ProductsListScreen(isAdmin: true),
            '/orders': (context) => OrdersListScreen(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
