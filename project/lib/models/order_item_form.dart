import 'package:flutter/material.dart';

class OrderItemForm {
  String productId;
  String productName;
  int quantity;
  double unitPrice;

  late TextEditingController quantityController;

  OrderItemForm({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  }) {
    quantityController =
        TextEditingController(
      text: quantity.toString(),
    );
  }

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