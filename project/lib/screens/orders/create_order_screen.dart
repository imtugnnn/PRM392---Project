import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../services/order_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() =>
      _CreateOrderScreenState();
}

class _CreateOrderScreenState
    extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _orderIdController = TextEditingController();

  String status = 'NEW';

  bool isLoading = false;

  final OrderService _orderService = OrderService();

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final order = Order(
        orderId: _orderIdController.text.trim(),
        status: status,
        orderDate: '',
      );

      await _orderService.createOrder(order);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Create failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _orderIdController,
                decoration: const InputDecoration(
                  labelText: 'Order ID',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.receipt_long),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Order ID is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'NEW',
                    child: Text('NEW'),
                  ),
                  DropdownMenuItem(
                    value: 'COMPLETED',
                    child: Text('COMPLETED'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      status = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      isLoading ? null : createOrder,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Create Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}