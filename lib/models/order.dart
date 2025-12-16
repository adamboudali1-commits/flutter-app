class Order {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;
  final double totalPrice;
  final String? orderDate;
  final String? productName;
  final String? userName;

  Order({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    this.orderDate,
    this.productName,
    this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'orderDate': orderDate,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      productId: map['productId'],
      quantity: map['quantity'],
      totalPrice: map['totalPrice'] is double
          ? map['totalPrice']
          : (map['totalPrice'] as num).toDouble(),
      orderDate: map['orderDate'],
      productName: map['productName'],
      userName: map['userName'],
    );
  }
}
