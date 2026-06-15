import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/order_item_form.dart';
import '../../models/product.dart';

import '../../services/order_service.dart';
import '../../services/order_item_service.dart';
import '../../services/product_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() =>
      _CreateOrderScreenState();
}

class _CreateOrderScreenState
    extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();
  final OrderItemService _orderItemService =
    OrderItemService();

  String status = 'NEW';

  bool isLoading = false;

  List<Product> products = [];

  List<OrderItemForm> orderItems = [
    OrderItemForm.empty(),
  ];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final result =
          await _productService.getProducts();

      setState(() {
        products = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Load products failed: $e',
          ),
        ),
      );
    }
  }

  double get orderTotal {
    return orderItems.fold(
      0,
      (sum, item) => sum + item.lineTotal,
    );
  }

  Future<void> createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (orderItems.any(
      (item) => item.productId.isEmpty,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select all products',
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final order = Order(
        orderId: '',
        status: status,
        orderDate: '',
      );

      final createdOrder =
          await _orderService.createOrder(
        order,
      );

      final orderId =
          createdOrder.orderId;

      for (int i = 0;
          i < orderItems.length;
          i++) {
        final item = orderItems[i];

        await _orderItemService
            .createOrderItem(
          OrderItem(
            orderItemId: '',
            orderId: orderId,
            productId: item.productId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          ),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order $orderId created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Create failed: $e',
          ),
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

  Widget buildOrderItemCard(
    int index,
  ) {
    final item = orderItems[index];

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownSearch<Product>(
              items: products,
              itemAsString: (Product p) => p.productName,

              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search product...',
                  ),
                ),
              ),

              dropdownDecoratorProps:
                  const DropDownDecoratorProps(
                dropdownSearchDecoration:
                    InputDecoration(
                  labelText: 'Product',
                  border: OutlineInputBorder(),
                ),
              ),

              selectedItem:
                  item.productId.isEmpty
                      ? null
                      : products.firstWhere(
                          (p) =>
                              p.productId ==
                              item.productId,
                        ),

              onChanged: (product) {
                if (product == null) return;

                setState(() {
                  item.productId =
                      product.productId;
                  item.productName =
                      product.productName;
                  item.unitPrice =
                      product.price;
                });
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue:
                  item.quantity.toString(),
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: 'Quantity',
                border:
                    OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  item.quantity =
                      int.tryParse(value) ??
                          1;
                });
              },
            ),

            const SizedBox(height: 12),

            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'Unit Price: ${item.unitPrice.toStringAsFixed(2)}',
              ),
            ),

            const SizedBox(height: 4),

            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'Line Total: ${item.lineTotal.toStringAsFixed(2)}',
              ),
            ),

            if (orderItems.length > 1)
              Align(
                alignment:
                    Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      orderItems.removeAt(
                        index,
                      );
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Order',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<
                  String>(
                value: status,
                decoration:
                    const InputDecoration(
                  labelText: 'Status',
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'NEW',
                    child: Text('NEW'),
                  ),
                  DropdownMenuItem(
                    value: 'COMPLETED',
                    child:
                        Text('COMPLETED'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    status = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...List.generate(
                orderItems.length,
                (index) =>
                    buildOrderItemCard(
                  index,
                ),
              ),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    orderItems.add(
                      OrderItemForm.empty(),
                    );
                  });
                },
                icon:
                    const Icon(Icons.add),
                label: const Text(
                  'Add Item',
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment:
                    Alignment.centerRight,
                child: Text(
                  'Order Total: ${orderTotal.toStringAsFixed(2)}',
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width:
                    double.infinity,
                height: 50,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      isLoading
                          ? null
                          : createOrder,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),
                  label: const Text(
                    'Create Order',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}