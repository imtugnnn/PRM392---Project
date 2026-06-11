import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../services/order_service.dart';
import 'create_order_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderService _orderService = OrderService();

  List<Order> orders = [];
  List<Order> filteredOrders = [];

  bool isLoading = true;

  String searchText = '';
  String selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      final data = await _orderService.getOrders();

      if (!mounted) return;

      setState(() {
        orders = data;
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void applyFilters() {
    filteredOrders = orders.where((order) {
      final matchSearch = order.orderId
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchStatus = selectedFilter == 'ALL'
          ? true
          : order.status == selectedFilter;

      return matchSearch && matchStatus;
    }).toList();
  }

  Future<void> deleteOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Delete order $orderId ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _orderService.deleteOrder(orderId);

      await loadOrders();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
        ),
      );
    }
  }

  String formatDate(String date) {
    if (date.length != 8) return date;

    return '${date.substring(6, 8)}/'
        '${date.substring(4, 6)}/'
        '${date.substring(0, 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final totalOrders = orders.length;

    final completedOrders = orders
        .where((o) => o.status == 'COMPLETED')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateOrderScreen(),
            ),
          );

          if (result == true) {
            loadOrders();
          }
        },
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadOrders,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.receipt_long,
                            value: totalOrders.toString(),
                            label: 'Orders',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle,
                            value:
                                completedOrders.toString(),
                            label: 'Completed',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search order...',
                        prefixIcon:
                            const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                          applyFilters();
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected:
                              selectedFilter == 'ALL',
                          onSelected: (_) {
                            setState(() {
                              selectedFilter = 'ALL';
                              applyFilters();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('NEW'),
                          selected:
                              selectedFilter == 'NEW',
                          onSelected: (_) {
                            setState(() {
                              selectedFilter = 'NEW';
                              applyFilters();
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label:
                              const Text('COMPLETED'),
                          selected:
                              selectedFilter ==
                                  'COMPLETED',
                          onSelected: (_) {
                            setState(() {
                              selectedFilter =
                                  'COMPLETED';
                              applyFilters();
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label: Text('ID'),
                          ),
                          DataColumn(
                            label: Text('Status'),
                          ),
                          DataColumn(
                            label: Text('Date'),
                          ),
                          DataColumn(
                            label: Text('Action'),
                          ),
                        ],
                        rows: filteredOrders.map(
                          (order) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(order.orderId),
                                ),
                                DataCell(
                                  Text(order.status),
                                ),
                                DataCell(
                                  Text(
                                    formatDate(
                                      order.orderDate,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        deleteOrder(
                                      order.orderId,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}