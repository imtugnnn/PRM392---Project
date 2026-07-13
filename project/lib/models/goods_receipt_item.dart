class GoodsReceiptItem {
  final String grItemId;
  final String grId;
  final String productId;
  final int quantity;
  final double price;

  GoodsReceiptItem({
    required this.grItemId,
    required this.grId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory GoodsReceiptItem.fromJson(Map<String, dynamic> json) {
    return GoodsReceiptItem(
      grItemId: json['GrItemId'] ?? '',
      grId: json['GrId'] ?? '',
      productId: json['ProductId'] ?? '',
      quantity: int.tryParse(json['Quantity'].toString()) ?? 0,
      price: double.tryParse(json['Price'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'GrItemId': grItemId,
      'GrId': grId,
      'ProductId': productId,
      'Quantity': quantity,
      'Price': price.toStringAsFixed(0),
    };
  }

  GoodsReceiptItem copyWith({
    String? grItemId,
    String? grId,
    String? productId,
    int? quantity,
    double? price,
  }) {
    return GoodsReceiptItem(
      grItemId: grItemId ?? this.grItemId,
      grId: grId ?? this.grId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}