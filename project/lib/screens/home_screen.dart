import 'package:flutter/material.dart';

import 'products/add_product_screen.dart';
import 'products/product_list_screen.dart';
import '../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalProducts = 0;
  int lowStockProducts = 0;
  int totalOrders = 0;
  int totalShipments = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      setState(() {
        isLoading = true;
      });

      final products = await ProductService().getProducts();

      setState(() {
        totalProducts = products.length;

        // sản phẩm tồn kho thấp (<10)
        lowStockProducts =
            products.where((p) => p.quantity < 10).length;

        // hiện chưa có API Order và Shipment
        totalOrders = 0;
        totalShipments = 0;

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Store Warehouse',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Inventory Overview',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      'Products',
                      totalProducts.toString(),
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      'Low Stock',
                      lowStockProducts.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      'Orders',
                      totalOrders.toString(),
                      Icons.shopping_cart,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      'Shipment',
                      totalShipments.toString(),
                      Icons.local_shipping,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('View Products'),
                  subtitle: const Text(
                    'Manage inventory products',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductListScreen(),
                      ),
                    ).then((_) {
                      loadDashboard();
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.add_box),
                  title: const Text('Add Product'),
                  subtitle: const Text(
                    'Create a new product',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddProductScreen(),
                      ),
                    ).then((_) {
                      loadDashboard();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 12,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}