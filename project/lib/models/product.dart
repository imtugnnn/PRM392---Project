class Product {
  final String productId;
  final String productName;
  final String description;
  final int quantity;
  final String shelfLocation;
  final double price;

  Product({
    required this.productId,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.shelfLocation,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['ProductId'] ?? '',
      productName: json['ProductName'] ?? '',
      description: json['Description'] ?? '',
      quantity: json['Quantity'] ?? 0,
      shelfLocation: json['ShelfLocation'] ?? '',
      price: double.parse(json['Price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductId': productId,
      'ProductName': productName,
      'Description': description,
      'Quantity': quantity,
      'ShelfLocation': shelfLocation,
      'Price': price.toStringAsFixed(2),
    };
  }

  Product copyWith({
    String? productId,
    String? productName,
    String? description,
    int? quantity,
    String? shelfLocation,
    double? price,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      price: price ?? this.price,
    );
  }
}