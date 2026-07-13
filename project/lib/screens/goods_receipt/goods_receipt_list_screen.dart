import 'package:flutter/material.dart';

import '../../models/goods_receipt.dart';
import '../../services/goods_receipt_service.dart';
import 'create_goods_receipt_screen.dart';
import 'goods_receipt_detail_screen.dart';

class GoodsReceiptListScreen extends StatefulWidget {
  const GoodsReceiptListScreen({super.key});

  @override
  State<GoodsReceiptListScreen> createState() =>
      _GoodsReceiptListScreenState();
}

class _GoodsReceiptListScreenState
    extends State<GoodsReceiptListScreen> {
  final GoodsReceiptService _service = GoodsReceiptService();

  List<GoodsReceipt> goodsReceipts = [];
  List<GoodsReceipt> filteredGoodsReceipts = [];

  bool isLoading = true;

  String searchText = '';
  String selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    loadGoodsReceipts();
  }

  Future<void> loadGoodsReceipts() async {
    try {
      final data = await _service.getGoodsReceipts();

      if (!mounted) return;

      setState(() {
        goodsReceipts = data;
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error : $e"),
        ),
      );
    }
  }

  void applyFilters() {
    filteredGoodsReceipts =
        goodsReceipts.where((gr) {
      final matchSearch =
          gr.grId
              .toLowerCase()
              .contains(searchText.toLowerCase()) ||
          gr.remark
              .toLowerCase()
              .contains(searchText.toLowerCase());

      final matchStatus = selectedFilter == 'ALL'
          ? true
          : gr.status == selectedFilter;

      return matchSearch && matchStatus;
    }).toList();
  }

  String formatDate(String date) {
    if (date.length != 8) return date;

    return "${date.substring(6, 8)}/"
        "${date.substring(4, 6)}/"
        "${date.substring(0, 4)}";
  }

  @override
  Widget build(BuildContext context) {
    final totalReceipt = goodsReceipts.length;

    final completedReceipt = goodsReceipts
        .where((e) => e.status == "COMPLETED")
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Goods Receipts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Create Goods Receipt",
            onPressed: () async {
              final result =
                  await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CreateGoodsReceiptScreen(),
                ),
              );

              if (result == true) {
                loadGoodsReceipts();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadGoodsReceipts,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon:
                                Icons.inventory,
                            value:
                                totalReceipt
                                    .toString(),
                            label:
                                "Receipts",
                          ),
                        ),
                        const SizedBox(
                            width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons
                                .check_circle,
                            value:
                                completedReceipt
                                    .toString(),
                            label:
                                "Completed",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 16),

                    TextField(
                      decoration:
                          InputDecoration(
                        hintText:
                            "Search receipt...",
                        prefixIcon:
                            const Icon(
                                Icons
                                    .search),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                      ),
                      onChanged:
                          (value) {
                        setState(() {
                          searchText =
                              value;
                          applyFilters();
                        });
                      },
                    ),

                    const SizedBox(
                        height: 16),

                    Row(
                      children: [
                        ChoiceChip(
                          label:
                              const Text(
                                  "ALL"),
                          selected:
                              selectedFilter ==
                                  "ALL",
                          onSelected:
                              (_) {
                            setState(() {
                              selectedFilter =
                                  "ALL";
                              applyFilters();
                            });
                          },
                        ),
                        const SizedBox(
                            width: 8),
                        ChoiceChip(
                          label:
                              const Text(
                                  "CREATED"),
                          selected:
                              selectedFilter ==
                                  "CREATED",
                          onSelected:
                              (_) {
                            setState(() {
                              selectedFilter =
                                  "CREATED";
                              applyFilters();
                            });
                          },
                        ),
                        const SizedBox(
                            width: 8),
                        ChoiceChip(
                          label:
                              const Text(
                                  "COMPLETED"),
                          selected:
                              selectedFilter ==
                                  "COMPLETED",
                          onSelected:
                              (_) {
                            setState(() {
                              selectedFilter =
                                  "COMPLETED";
                              applyFilters();
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 16),

                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          filteredGoodsReceipts
                              .length,
                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                                  height: 8),
                      itemBuilder:
                          (_, index) {
                        final gr =
                            filteredGoodsReceipts[
                                index];

                        final isCompleted =
                            gr.status ==
                                "COMPLETED";

                        return Card(
                          color: isCompleted
                              ? Colors.green
                                  .shade50
                              : null,
                          child: ListTile(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GoodsReceiptDetailScreen(
                                    goodsReceipt:
                                        gr,
                                  ),
                                ),
                              );

                              loadGoodsReceipts();
                            },
                            leading:
                                CircleAvatar(
                              child: Text(
                                "${index + 1}",
                              ),
                            ),
                            title: Text(
                              gr.grId,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            subtitle:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  formatDate(
                                      gr.grDate),
                                ),
                                Text(
                                    gr.remark),
                              ],
                            ),
                            trailing:
                                Chip(
                              label: Text(
                                  gr.status),
                              backgroundColor:
                                  isCompleted
                                      ? Colors
                                          .green
                                          .shade100
                                      : Colors
                                          .orange
                                          .shade100,
                            ),
                          ),
                        );
                      },
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
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}