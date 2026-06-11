import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({
    super.key,
    this.product,
  });

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProductService service = ProductService();

  final idController = TextEditingController();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final quantityController = TextEditingController();
  final shelfController = TextEditingController();
  final priceController = TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      idController.text =
          widget.product!.productId;

      nameController.text =
          widget.product!.productName;

      descController.text =
          widget.product!.description;

      quantityController.text =
          widget.product!.quantity.toString();

      shelfController.text =
          widget.product!.shelfLocation;

      priceController.text =
          widget.product!.price.toString();
    }
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final product = Product(
        productId: idController.text.trim(),
        productName: nameController.text.trim(),
        description: descController.text.trim(),
        quantity: int.parse(
          quantityController.text.trim(),
        ),
        shelfLocation: shelfController.text.trim(),
        price: double.parse(
          priceController.text.trim(),
        ),
      );

      if (widget.product == null) {
        await service.createProduct(product);
      } else {
        await service.updateProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );

      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    descController.dispose();
    quantityController.dispose();
    shelfController.dispose();
    priceController.dispose();

    super.dispose();
  }

  InputDecoration buildDecoration(
    String label,
  ) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null
              ? 'Add Product'
              : 'Edit Product',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(16),
          children: [

            TextFormField(
              controller: idController,
              enabled: widget.product == null,
              decoration: buildDecoration(
                'Product ID',
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  nameController,
              decoration:
                  buildDecoration(
                'Product Name',
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  descController,
              decoration:
                  buildDecoration(
                'Description',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  quantityController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  buildDecoration(
                'Quantity',
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Required';
                }

                if (int.tryParse(
                        value) ==
                    null) {
                  return 'Invalid number';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  shelfController,
              decoration:
                  buildDecoration(
                'Shelf Location',
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  priceController,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              decoration:
                  buildDecoration(
                'Price',
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty) {
                  return 'Required';
                }

                if (double.tryParse(
                        value) ==
                    null) {
                  return 'Invalid price';
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed:
                    isSaving
                        ? null
                        : saveProduct,
                child: isSaving
                  ? const CircularProgressIndicator()
                  : Text(
                      widget.product == null
                          ? 'Save Product'
                          : 'Update Product',
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}