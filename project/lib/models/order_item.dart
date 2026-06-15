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
}