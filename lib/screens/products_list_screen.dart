import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../services/database_helper.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class ProductsListScreen extends StatefulWidget {
  final bool isAdmin;

  const ProductsListScreen({super.key, required this.isAdmin});

  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'name';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() async {
    final products = await _dbHelper.getAllProducts();
    setState(() {
      _products = products;
      _filteredProducts = products;
      _isLoading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch =
            product['name'].toString().toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            product['description'].toString().toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
        final matchesCategory =
            _selectedCategory == 'All' || product['type'] == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();

      // Sort products
      _filteredProducts.sort((a, b) {
        switch (_sortBy) {
          case 'price_low':
            return (a['price'] as double).compareTo(b['price'] as double);
          case 'price_high':
            return (b['price'] as double).compareTo(a['price'] as double);
          case 'name':
          default:
            return a['name'].toString().compareTo(b['name'].toString());
        }
      });
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItem = CartItem(
      productId: product['id'],
      name: product['name'],
      price: product['price'],
      imagePath: product['imagePath'] ?? '',
      quantity: 1,
    );
    cartProvider.addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} added to cart!')),
    );
  }

  void _toggleWishlist(Map<String, dynamic> product) {
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    if (wishlistProvider.isInWishlist(product['id'])) {
      wishlistProvider.removeFromWishlist(product['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} removed from wishlist!')),
      );
    } else {
      wishlistProvider.addToWishlist(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} added to wishlist!')),
      );
    }
  }

  void _navigateToProductDetails(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Manage Products' : 'Our Products'),
        backgroundColor: widget.isAdmin ? Colors.blue : Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!widget.isAdmin) ...[
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return badges.Badge(
                  badgeContent: Text(
                    '${cart.totalQuantity}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  showBadge: cart.itemCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
              onPressed: () => setState(() => _isGridView = !_isGridView),
              tooltip: _isGridView ? 'List view' : 'Grid view',
            ),
          ],
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              ),
              tooltip: 'Add Product',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                        ),
                        items:
                            [
                                  'All',
                                  'Electronics',
                                  'Clothing',
                                  'Books',
                                  'Home & Garden',
                                  'Sports',
                                  'Beauty',
                                  'Toys',
                                  'Other',
                                ]
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                          _filterProducts();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: InputDecoration(
                          labelText: 'Sort by',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                          DropdownMenuItem(
                            value: 'price_low',
                            child: Text('Price: Low to High'),
                          ),
                          DropdownMenuItem(
                            value: 'price_high',
                            child: Text('Price: High to Low'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _sortBy = value!);
                          _filterProducts();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Products List/Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 100, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _isGridView
                ? MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => _navigateToProductDetails(product),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child:
                                    product['imagePath'] != null &&
                                        product['imagePath'].isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                        child: Image.asset(
                                          product['imagePath'],
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                        size: 50,
                                      ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${product['price'].toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (!widget.isAdmin)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () =>
                                                  _addToCart(product),
                                              icon: const Icon(
                                                Icons.add_shopping_cart,
                                                size: 16,
                                              ),
                                              label: const Text('Add to Cart'),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _toggleWishlist(product),
                                            icon: Consumer<WishlistProvider>(
                                              builder:
                                                  (context, wishlist, child) {
                                                    final isInWishlist =
                                                        wishlist.isInWishlist(
                                                          product['id'],
                                                        );
                                                    return Icon(
                                                      isInWishlist
                                                          ? Icons.favorite
                                                          : Icons
                                                                .favorite_border,
                                                      color: isInWishlist
                                                          ? Colors.red
                                                          : Colors.grey,
                                                      size: 20,
                                                    );
                                                  },
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => _navigateToProductDetails(product),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Product Image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child:
                                      product['imagePath'] != null &&
                                          product['imagePath'].isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.asset(
                                            product['imagePath'],
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                ),

                                const SizedBox(width: 16),

                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Type: ${product['type']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                      Text(
                                        '\$${product['price'].toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (product['description'] != null &&
                                          product['description'].isNotEmpty)
                                        Text(
                                          product['description'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Actions
                                if (!widget.isAdmin)
                                  Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _addToCart(product),
                                        child: const Text('Add to Cart'),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _toggleWishlist(product),
                                        icon: Consumer<WishlistProvider>(
                                          builder: (context, wishlist, child) {
                                            final isInWishlist = wishlist
                                                .isInWishlist(product['id']);
                                            return Icon(
                                              isInWishlist
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isInWishlist
                                                  ? Colors.red
                                                  : Colors.grey,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
