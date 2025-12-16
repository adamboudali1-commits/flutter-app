class Product {
  final int? id;
  final String name;
  final String type;
  final double price;
  final int quantity;
  final String? imagePath;
  final String? description;
  final String? createdAt;

  Product({
    this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.quantity,
    this.imagePath,
    this.description,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
      'description': description,
      'createdAt': createdAt ?? DateTime.now().toString(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      price: map['price'] is double
          ? map['price']
          : (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      imagePath: map['imagePath'],
      description: map['description'],
      createdAt: map['createdAt'],
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? type,
    double? price,
    int? quantity,
    String? imagePath,
    String? description,
    String? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
