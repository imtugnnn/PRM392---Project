import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../products/add_product_screen.dart';
// import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService service = ProductService();

  List<Product> products = [];
  List<Product> filteredProducts = [];

  bool isLoading = true;
  bool lowStockOnly = false;

  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final result = await service.getProducts();

      setState(() {
        products = result;
        filteredProducts = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void applyFilter() {
    setState(() {
      filteredProducts = products.where((product) {
        final matchSearch = product.productName
            .toLowerCase()
            .contains(searchText.toLowerCase());

        final matchStock =
            !lowStockOnly || product.quantity <= 10;

        return matchSearch && matchStock;
      }).toList();
    });
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

    final lowStockCount = products
        .where((e) => e.quantity <= 10)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddProductScreen(),
            ),
          );

          if (result == true) {
            loadProducts();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        onRefresh: loadProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// DASHBOARD
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.inventory_2,
                              size: 32,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              products.length.toString(),
                              style:
                                  const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Products',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.warning,
                              size: 32,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lowStockCount.toString(),
                              style:
                                  const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Low Stock',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// SEARCH
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search product...',
                  prefixIcon:
                      const Icon(Icons.search),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  searchText = value;
                  applyFilter();
                },
              ),

              const SizedBox(height: 12),

              /// FILTER
              Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: !lowStockOnly,
                    onSelected: (_) {
                      lowStockOnly = false;
                      applyFilter();
                    },
                  ),

                  const SizedBox(width: 10),

                  FilterChip(
                    label:
                        const Text('Low Stock'),
                    selected: lowStockOnly,
                    onSelected: (_) {
                      lowStockOnly = true;
                      applyFilter();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// TABLE
              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowColor:
                      MaterialStateProperty.all(
                    Colors.grey.shade200,
                  ),
                  columns: const [
                    DataColumn(
                        label: Text('ID')),
                    DataColumn(
                        label: Text('Name')),
                    DataColumn(
                        label: Text('Description')),
                    DataColumn(
                        label: Text('Qty')),
                    DataColumn(
                        label: Text('Shelf')),
                    DataColumn(
                        label: Text('Price')),
                  ],
                  rows: filteredProducts
                      .map((product) {
                    final isLowStock =
                        product.quantity <= 10;

                    return DataRow(
                      onSelectChanged: (_) async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddProductScreen(
                              product: product,
                            ),
                          ),
                        );

                        if (result == true) {
                          loadProducts();
                        }
                      },

                      color: MaterialStateProperty.resolveWith(
                        (states) => isLowStock
                            ? Colors.red.shade50
                            : null,
                      ),
                      cells: [
                        DataCell(
                          Text(
                              product.productId),
                        ),

                        DataCell(
                          Text(product
                              .productName),
                        ),

                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(product
                                .description),
                          ),
                        ),

                        DataCell(
                          Row(
                            children: [
                              Text(product
                                  .quantity
                                  .toString()),
                              if (isLowStock)
                                const Padding(
                                  padding:
                                      EdgeInsets.only(
                                    left: 5,
                                  ),
                                  child: Icon(
                                    Icons.warning,
                                    color:
                                        Colors.red,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        DataCell(
                          Text(product
                              .shelfLocation),
                        ),

                        DataCell(
                          Text(product.price
                              .toStringAsFixed(
                                  0)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}