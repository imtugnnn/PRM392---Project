import 'package:flutter/material.dart';

import '../../models/goods_receipt.dart';
import '../../services/goods_receipt_service.dart';
import 'goods_receipt_detail_screen.dart';

class CreateGoodsReceiptScreen extends StatefulWidget {
  const CreateGoodsReceiptScreen({super.key});

  @override
  State<CreateGoodsReceiptScreen> createState() =>
      _CreateGoodsReceiptScreenState();
}

class _CreateGoodsReceiptScreenState
    extends State<CreateGoodsReceiptScreen> {
  final GoodsReceiptService service = GoodsReceiptService();

  final TextEditingController remarkController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  String today() {
    final now = DateTime.now();

    return "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final gr = GoodsReceipt(
        grId: "",
        grDate: "",
        status: "CREATED",
        remark: remarkController.text.trim(),
      );

      // Nhận Goods Receipt vừa được tạo từ SAP
      final createdGR = await service.createGoodsReceipt(gr);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GoodsReceiptDetailScreen(
            goodsReceipt: createdGR,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Goods Receipt"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Goods Receipt Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Status",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Chip(
                        label:
                            const Text("CREATED"),
                        backgroundColor:
                            Colors.orange.shade100,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Date",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        initialValue: today(),
                        enabled: false,
                        decoration:
                            const InputDecoration(
                          border:
                              OutlineInputBorder(),
                          prefixIcon:
                              Icon(Icons.calendar_today),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Remark",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller:
                            remarkController,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          hintText:
                              "Enter remark...",
                          border:
                              OutlineInputBorder(),
                          alignLabelWithHint:
                              true,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return "Please enter a remark";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      loading ? null : save,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle,
                        ),
                  label: Text(
                    loading
                        ? "Creating..."
                        : "Create Receipt",
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