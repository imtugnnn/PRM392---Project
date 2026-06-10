import 'package:flutter/material.dart';

import '../../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.productName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Product ID'),
              subtitle: Text(product.productId),
            ),

            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Description'),
              subtitle: Text(product.description),
            ),

            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Quantity'),
              subtitle: Text(product.quantity.toString()),
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Shelf'),
              subtitle: Text(product.shelfLocation),
            ),

            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Price'),
              subtitle: Text(product.price.toString()),
            ),
          ],
        ),
      ),
    );
  }
}