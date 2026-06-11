class Order {
  final String orderId;
  final String status;
  final String orderDate;

  Order({
    required this.orderId,
    required this.status,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['OrderId'] ?? '',
      status: json['Status'] ?? '',
      orderDate: json['OrderDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OrderId': orderId,
      'Status': status,
      'OrderDate': orderDate,
    };
  }
}