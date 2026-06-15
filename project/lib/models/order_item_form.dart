class OrderItemForm {
  String productId;
  String productName;
  int quantity;
  double unitPrice;

  OrderItemForm({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemForm.empty() {
    return OrderItemForm(
      productId: '',
      productName: '',
      quantity: 1,
      unitPrice: 0,
    );
  }

  double get lineTotal =>
      quantity * unitPrice;
}