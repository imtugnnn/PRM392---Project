import 'package:flutter/material.dart';

import '../../models/picking_summary.dart';
import '../../services/picking_summary_service.dart';

class PickingSummaryScreen extends StatefulWidget {
  const PickingSummaryScreen({super.key});

  @override
  State<PickingSummaryScreen> createState() =>
      _PickingSummaryScreenState();
}

class _PickingSummaryScreenState
    extends State<PickingSummaryScreen> {
  final PickingSummaryService service =
      PickingSummaryService();

  List<PickingSummary> items = [];

  bool isLoading = true;

  int totalQty = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      items = [];
      totalQty = 0;
    });

    final result = await service.getSummary();
    print('RESULT LENGTH = ${result.length}');

    setState(() {
      items = result;

      totalQty = result.fold(
        0,
        (sum, item) => sum + item.totalQuantity,
      );

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picking Dashboard'),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding:
                    const EdgeInsets.all(12),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.inventory,
                                  size: 32,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  items.length
                                      .toString(),
                                  style:
                                      const TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight
                                            .bold,
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
                                const EdgeInsets
                                    .all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons
                                      .shopping_cart,
                                  size: 32,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  totalQty
                                      .toString(),
                                  style:
                                      const TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                const Text(
                                  'Items To Pick',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Picking List',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(5),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2), // Stock
                          4: FlexColumnWidth(2), // Qty
                        },
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'ID',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Product',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Shelf',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Qty',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Stock',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          ...items.map(
                            (item) {
                              final bool isShortage =
                                  item.shortageQuantity > 0;

                              return TableRow(
                                decoration: BoxDecoration(
                                  color: isShortage
                                      ? Colors.red.shade50
                                      : null,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(item.productId),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        if (isShortage)
                                          Text(
                                            'Thiếu ${item.shortageQuantity} sản phẩm',
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      item.shelfLocation,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      item.totalQuantity.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isShortage
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      item.stockQuantity.toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}