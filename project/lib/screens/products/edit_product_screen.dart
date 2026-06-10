import 'package:flutter/material.dart';

import '../../models/product.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController quantityController;
  late TextEditingController shelfController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.product.productName);

    descController =
        TextEditingController(text: widget.product.description);

    quantityController =
        TextEditingController(
          text: widget.product.quantity.toString(),
        );

    shelfController =
        TextEditingController(
          text: widget.product.shelfLocation,
        );

    priceController =
        TextEditingController(
          text: widget.product.price.toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Product Name',
            ),
          ),

          TextFormField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
          ),

          TextFormField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
            ),
          ),

          TextFormField(
            controller: shelfController,
            decoration: const InputDecoration(
              labelText: 'Shelf Location',
            ),
          ),

          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Price',
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              // TODO call updateProduct()
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}