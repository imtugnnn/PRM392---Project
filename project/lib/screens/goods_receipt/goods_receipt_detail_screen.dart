import 'package:flutter/material.dart';

import '../../models/goods_receipt.dart';
import '../../models/goods_receipt_item.dart';
import '../../services/goods_receipt_item_service.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/goods_receipt_service.dart';

class GoodsReceiptDetailScreen extends StatefulWidget {
  final GoodsReceipt goodsReceipt;
  

  const GoodsReceiptDetailScreen({
    super.key,
    required this.goodsReceipt,
  });

  @override
  State<GoodsReceiptDetailScreen> createState() =>
      _GoodsReceiptDetailScreenState();
}

class _GoodsReceiptDetailScreenState
    extends State<GoodsReceiptDetailScreen> {
  final GoodsReceiptItemService service =
      GoodsReceiptItemService();
  final ProductService productService = ProductService();
  List<GoodsReceiptItem> currentItems = [];

  bool isAdding = false;

  Product? selectedProduct;
  final grService = GoodsReceiptService();

  final productIdController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  final itemService = GoodsReceiptItemService();

  late Future<List<GoodsReceiptItem>> future;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      future = service.getByGrId(widget.goodsReceipt.grId);
    });
  }

  Future<void> searchProduct(String id) async {
    try {
      final product =
          await productService.getById(id);

      setState(() {
        selectedProduct = product;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product not found"),
        ),
      );
    }
  }

  Future<void> completeReceipt() async {

    try {

      // Lấy toàn bộ item của GR
      final items = await itemService.getByGrId(
        widget.goodsReceipt.grId,
      );

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Goods Receipt has no items."),
          ),
        );
        return;
      }

      // Cộng tồn kho
      for (final item in items) {

        final product =
            await productService.getById(item.productId);

        final updatedProduct = product.copyWith(
          quantity: product.quantity + item.quantity,
        );

        await productService.updateProduct(
          updatedProduct,
        );
      }

      // Đổi trạng thái GR
      final completedGR =
          widget.goodsReceipt.copyWith(
        status: "COMPLETED",
      );

      await grService.updateGoodsReceipt(
        completedGR,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Goods Receipt completed successfully.",
          ),
        ),
      );

      Navigator.pop(context, true);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> addItem() async {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a product")),
      );
      return;
    }

    try {
      final item = GoodsReceiptItem(
        grItemId: "",
        grId: widget.goodsReceipt.grId,
        productId: selectedProduct!.productId,
        quantity: int.parse(quantityController.text),
        price: double.parse(priceController.text),
      );

      await service.create(item);

      _loadItems(); // reload danh sách

      setState(() {
        isAdding = false;
        selectedProduct = null;

        productIdController.clear();
        quantityController.clear();
        priceController.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Item added successfully"),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  String formatDate(String date) {
    if (date.length != 8) return date;

    return "${date.substring(6, 8)}/"
        "${date.substring(4, 6)}/"
        "${date.substring(0, 4)}";
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        widget.goodsReceipt.status == "COMPLETED";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goodsReceipt.grId),
      ),

      bottomNavigationBar: isCompleted
        ? null
        : SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Complete Receipt"),
                  onPressed: completeReceipt,
                ),
              ),
            ),
          ),

      body: FutureBuilder<List<GoodsReceiptItem>>(
        future: future,
        builder: (_, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final items = snapshot.data ?? [];
          currentItems = items;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadItems();
              });

              await future;
            },
            child: ListView(
              padding:
                  const EdgeInsets.all(16),
              children: [

                /// HEADER
                Card(
                  elevation: 2,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        Row(
                          children: [

                            Expanded(
                              child: Text(
                                widget
                                    .goodsReceipt
                                    .grId,
                                style:
                                    const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            Chip(
                              label: Text(
                                widget
                                    .goodsReceipt
                                    .status,
                              ),
                              backgroundColor:
                                  isCompleted
                                      ? Colors
                                          .green
                                          .shade100
                                      : Colors
                                          .orange
                                          .shade100,
                            ),

                          ],
                        ),

                        const SizedBox(
                            height: 12),

                        Row(
                          children: [

                            const Icon(
                              Icons
                                  .calendar_today,
                              size: 18,
                            ),

                            const SizedBox(
                                width: 8),

                            Text(
                              formatDate(widget
                                  .goodsReceipt
                                  .grDate),
                            ),

                          ],
                        ),

                        const SizedBox(
                            height: 12),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            const Icon(
                              Icons.notes,
                              size: 18,
                            ),

                            const SizedBox(
                                width: 8),

                            Expanded(
                              child: Text(
                                widget
                                    .goodsReceipt
                                    .remark,
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// TITLE

                Row(
                  children: [

                    const Text(
                      "Products",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    Chip(
                      label: Text(
                        "${items.length} Items",
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 12),

                if (items.isEmpty)

                  Container(
                    height: 250,
                    alignment:
                        Alignment.center,
                    child: const Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [

                        Icon(
                          Icons.inventory,
                          size: 60,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          "No products",
                          style: TextStyle(
                            color:
                                Colors.grey,
                            fontSize: 16,
                          ),
                        ),

                      ],
                    ),
                  )

                else

                  ...items.map(

                    (item) => Card(

                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: ListTile(

                        leading:
                            CircleAvatar(
                          child: Text(
                            item.productId,
                            style:
                                const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),

                        title: Text(
                          item.productId,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            const SizedBox(
                                height: 4),

                            Text(
                              "Quantity : ${item.quantity}",
                            ),

                            Text(
                              "Price : ${item.price.toStringAsFixed(0)}",
                            ),

                          ],
                        ),

                        trailing:
                            const Icon(
                          Icons
                              .chevron_right,
                        ),

                        onTap: () {
                          // TODO
                        },

                      ),
                    ),

                  ),

                  if (isAdding)
                    buildEditorCard(),

                  const SizedBox(height: 12),
                    if (!isCompleted)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Add Item"),
                          onPressed: () {
                            setState(() {
                              isAdding = true;
                              selectedProduct = null;

                              productIdController.clear();
                              quantityController.clear();
                              priceController.clear();
                            });
                          },
                        ),
                      ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildEditorCard() {

    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(

              controller: productIdController,

              decoration: const InputDecoration(

                labelText: "Product ID",

              ),

              textInputAction:
                  TextInputAction.search,

              onSubmitted: searchProduct,

            ),

            const SizedBox(height:16),

            if(selectedProduct!=null)

              Column(

                children:[

                  buildReadonly(

                    "Name",

                    selectedProduct!.productName,

                  ),

                  const SizedBox(height:12),

                  buildReadonly(

                    "Shelf",

                    selectedProduct!.shelfLocation,

                  ),

                  const SizedBox(height:12),

                  TextField(

                    controller: quantityController,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        const InputDecoration(

                      labelText:"Quantity",

                    ),

                  ),

                  const SizedBox(height:12),

                  TextField(

                    controller: priceController,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        const InputDecoration(

                      labelText:"Price",

                    ),

                  ),

                  const SizedBox(height:20),

                  Row(

                    children:[

                      Expanded(

                        child: OutlinedButton(

                          onPressed:(){

                            setState((){

                              isAdding=false;

                            });

                          },

                          child: const Text("Cancel"),

                        ),

                      ),

                      const SizedBox(width:12),

                      Expanded(

                        child: ElevatedButton(

                          onPressed:addItem,

                          child: const Text("Add"),

                        ),

                      ),

                    ],

                  ),

                ],

              ),

          ],

        ),

      ),

    );

  }

  Widget buildReadonly(
      String title,
      String value,
  ){

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children:[

        Text(title),

        const SizedBox(height:5),

        Container(

          width: double.infinity,

          padding:
              const EdgeInsets.all(12),

          decoration: BoxDecoration(

            color: Colors.grey.shade100,

            borderRadius:
                BorderRadius.circular(8),

          ),

          child: Text(value),

        ),

      ],

    );

  }
}