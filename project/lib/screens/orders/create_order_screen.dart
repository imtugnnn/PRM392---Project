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
  final Order? order;
  const CreateOrderScreen({super.key, this.order});

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
  bool get isCompleted =>
    widget.order?.status == 'COMPLETED';

  bool get isEdit =>
    widget.order != null;

  bool isLoading = false;

  List<Product> products = [];

  List<OrderItemForm> orderItems = [
    OrderItemForm.empty(),
  ];

  @override
  void dispose() {
    for (final item in orderItems) {
      item.quantityController.dispose();
    }
    super.dispose();
  }

  @override
    void initState() {
      super.initState();

      initData();
    }

    Future<void> initData() async {
    await loadProducts();

    if (widget.order != null) {
      await loadOrderDetails();
    }
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

  Future<void> markAsCompleted() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Complete Order'),
        content: const Text(
          'This will deduct stock quantities. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
        try {
          setState(() {
            isLoading = true;
          });

          final items =
              await _orderItemService.getByOrderId(
            widget.order!.orderId,
          );

          // Kiểm tra tồn kho
          for (final item in items) {
            final product = products.firstWhere(
              (p) => p.productId == item.productId,
            );

            if (product.quantity < item.quantity) {
              throw Exception(
                'Not enough stock for ${product.productName}',
              );
            }
          }

      // Trừ tồn kho
      for (final item in items) {
        final product = products.firstWhere(
          (p) => p.productId == item.productId,
        );

        final updatedProduct = Product(
          productId: product.productId,
          productName: product.productName,
          description: product.description,
          quantity:
              product.quantity - item.quantity,
          shelfLocation:
              product.shelfLocation,
          price: product.price,
        );

        await _productService.updateProduct(
          updatedProduct,
        );
      }

      // Chuyển trạng thái Order
      await _orderService.updateOrder(
        Order(
          orderId: widget.order!.orderId,
          orderDate: widget.order!.orderDate,
          status: 'COMPLETED',
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Order completed successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
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
        status: 'NEW',
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

  Future<void> loadOrderDetails() async {
    
    if (widget.order == null) return;

    final items =
        await _orderItemService.getByOrderId(
      widget.order!.orderId,
    );

    print('OrderId: ${widget.order!.orderId}');
    print('Items loaded: ${items.length}');

    setState(() {
      orderItems =
          items.map((item) {
            final product = products.firstWhere(
              (p) =>
                  p.productId ==
                  item.productId,
            );

            return OrderItemForm(
              productId: item.productId,
              productName:
                  product.productName,
              quantity: item.quantity,
              unitPrice:
                  item.unitPrice,
            );
          }).toList();
    });
  }

  Widget buildOrderItemCard(
    int index,
  ) {
    final item = orderItems[index];
    print(
      'CARD => '
      '${item.productName} | '
      'qty=${item.quantity} | '
      'price=${item.unitPrice}',
    );

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownSearch<Product>(
              enabled: !isCompleted,
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
                  item.productId = product.productId;
                  item.productName = product.productName;
                  item.unitPrice = product.price;

                  item.quantity = 1;
                  item.quantityController.text = '1';
                });
              }
            ),

            const SizedBox(height: 12),

            TextFormField(
              enabled: !isCompleted,
              controller: item.quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final qty = int.tryParse(value);

                setState(() {
                  item.quantity = qty == null || qty <= 0
                      ? 1
                      : qty;
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
                  onPressed: isCompleted
                    ? null
                    : () {
                        setState(() {
                          orderItems.removeAt(index);
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
        title: Text(
          !isEdit
              ? 'Create Order'
              : isCompleted
                  ? 'Order Details'
                  : 'Edit Order',
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
                onPressed: isCompleted
                    ? null
                    : () {
                        setState(() {
                          orderItems.add(
                            OrderItemForm.empty(),
                          );
                        });
                      },
                icon:
                    const Icon(Icons.add),
                label: const Text('Add Item'),
              ),

              const SizedBox(height: 20),

              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order Total',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            orderTotal.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (isEdit && !isCompleted)
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.check_circle,
                          ),
                          label: const Text(
                            'Mark as Completed',
                          ),
                          onPressed: markAsCompleted,
                        ),

                      if (isCompleted)
                        Container(
                          padding:
                              const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Order Completed',
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (!isEdit)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : createOrder,
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
                    label:
                        const Text('Create Order'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}