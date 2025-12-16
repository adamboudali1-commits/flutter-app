import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/database_helper.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  double _rating =4.5;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItem = CartItem(
      productId: widget.product['id'],
      name: widget.product['name'],
      price: widget.product['price'],
      imagePath: widget.product['imagePath'] ?? '',
      quantity: _quantity,
    );
    cartProvider.addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.product['name']} added to cart!')),
    );
  }

  void _toggleWishlist() {
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    if (wishlistProvider.isInWishlist(widget.product['id'])) {
      wishlistProvider.removeFromWishlist(widget.product['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product['name']} removed from wishlist!'),
        ),
      );
    } else {
      wishlistProvider.addToWishlist(widget.product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product['name']} added to wishlist!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name']),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlist, child) {
              final isInWishlist = wishlist.isInWishlist(widget.product['id']);
              return IconButton(
                onPressed: _toggleWishlist,
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : Colors.grey,
                ),
                tooltip: isInWishlist
                    ? 'Remove from wishlist'
                    : 'Add to wishlist',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child:
                  widget.product['imagePath'] != null &&
                      widget.product['imagePath'].isNotEmpty
                  ? Image.asset(widget.product['imagePath'], fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product['name'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Product Type
                  Text(
                    widget.product['type'],
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Rating
                  Row(
                    children: [
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 20,
                        ignoreGestures: true,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) {},
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_rating (124 reviews)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Text(
                    '\$${widget.product['price'].toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity Selector
                  Row(
                    children: [
                      Text(
                        'Quantity:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                '$_quantity',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _quantity++),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (widget.product['description'] != null &&
                      widget.product['description'].isNotEmpty) ...[
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product['description'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Stock Information
                  Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        color: widget.product['quantity'] > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.product['quantity'] > 0
                            ? 'In Stock (${widget.product['quantity']} available)'
                            : 'Out of Stock',
                        style: TextStyle(
                          color: widget.product['quantity'] > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.product['quantity'] > 0
                              ? _addToCart
                              : null,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text(
                            'Add to Cart - \$${(widget.product['price'] * _quantity).toStringAsFixed(2)}',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
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
  }
}
