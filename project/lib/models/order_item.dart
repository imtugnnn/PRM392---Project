class OrderItem {
  final String orderItemId;
  final String orderId;
  final String productId;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'OrderItemId': orderItemId,
      'OrderId': orderId,
      'ProductId': productId,
      'Quantity': quantity,
      'UnitPrice': unitPrice.toStringAsFixed(2),
    };
  }

  factory OrderItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderItem(
      orderItemId:
          json['OrderItemId'] ?? '',
      orderId:
          json['OrderId'] ?? '',
      productId:
          json['ProductId'] ?? '',
      quantity:
          int.tryParse(
                json['Quantity']
                    .toString(),
              ) ??
              0,
      unitPrice:
          double.tryParse(
                json['UnitPrice']
                    .toString(),
              ) ??
              0,
    );
  }
}