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

                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            child: Icon(Icons.local_shipping),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ready to Pick",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${items.length} Products • $totalQty Items",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Picking List",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (items.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 50,
                        ),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No Products To Pick",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "All orders have been completed.",
                            ),
                          ],
                        ),
                      ),
                    ),

                  ...items.map((item) {
                    final shortage =
                        item.shortageQuantity > 0;

                    return Card(
                      margin:
                          const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                        side: shortage
                            ? BorderSide(
                                color: Colors.red.shade300,
                              )
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [

                                Expanded(
                                  child: Text(
                                    item.productId,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Chip(
                                  avatar:
                                      const Icon(Icons.place,
                                          size: 18),
                                  label: Text(
                                    item.shelfLocation,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Text(
                              item.productName,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [

                                Expanded(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius:
                                          BorderRadius.circular(
                                              12),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Need",
                                        ),
                                        const SizedBox(
                                            height: 4),
                                        Text(
                                          item.totalQuantity
                                              .toString(),
                                          style:
                                              const TextStyle(
                                            fontSize: 22,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: shortage
                                          ? Colors.red.shade50
                                          : Colors.green
                                              .shade50,
                                      borderRadius:
                                          BorderRadius.circular(
                                              12),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Stock",
                                        ),
                                        const SizedBox(
                                            height: 4),
                                        Text(
                                          item.stockQuantity
                                              .toString(),
                                          style:
                                              TextStyle(
                                            fontSize: 22,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            color: shortage
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (shortage) ...[
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Shortage: ${item.shortageQuantity}",
                                    style:
                                        const TextStyle(
                                      color: Colors.red,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}