import 'package:flutter/material.dart';

import '../../api/real/product_api.dart';
import '../../api/real/order_api.dart';
import '../../api/real/distributor_api.dart';
import '../../api/real/goals_api.dart';

class SalesCreateOrderScreen extends StatefulWidget {
  const SalesCreateOrderScreen({super.key});

  @override
  State<SalesCreateOrderScreen> createState() => _SalesCreateOrderScreenState();
}

class _SalesCreateOrderScreenState extends State<SalesCreateOrderScreen> {
  bool loading = true;
  bool submitting = false;

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> distributors = [];

  Map<String, dynamic>? selectedDistributor;

  /// 🔒 BASE GOALS (DO NOT MUTATE)
  Map<String, dynamic> monthlyGoalsRemaining = {};

  List<_OrderRow> rows = [_OrderRow()];

  double get grandTotal => rows.fold(0, (s, r) => s + r.total);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /* ===============================
     LOAD PRODUCTS + DISTRIBUTORS
  =============================== */
  Future<void> loadData() async {
    try {
      products = await ProductApi.getProducts();
      distributors = await DistributorApi.getDistributors();
    } catch (e) {
      _toast(e.toString());
    }
    if (mounted) setState(() => loading = false);
  }

  /* ===============================
     CREATE DRAFT (NO DB DEDUCT)
  =============================== */
  Future<void> createDraft() async {
    if (selectedDistributor == null) {
      _toast("Select distributor");
      return;
    }

    final items = rows
        .where((r) => r.product != null && r.qty > 0)
        .map(
          (r) => {
            "productId": r.product!["productId"].toString(),
            "qty": r.qty,
          },
        )
        .toList();

    if (items.isEmpty) {
      _toast("Add at least one product");
      return;
    }

    setState(() => submitting = true);

    try {
      await OrderApi.createOrder(
        distributorId: selectedDistributor!["distributorId"].toString(),
        distributorName: selectedDistributor!["distributorName"].toString(),
        items: items,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/sales/drafts");
    } catch (e) {
      _toast(e.toString());
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Order")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /* ---------- DISTRIBUTOR ---------- */
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                      labelText: "Select Distributor",
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedDistributor,
                    items: distributors
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(d["distributorName"] ?? ""),
                          ),
                        )
                        .toList(),
                    onChanged: (v) async {
                      selectedDistributor = v;
                      rows = [_OrderRow()];
                      monthlyGoalsRemaining = {};

                      final distributorCode = v?["distributorCode"]?.toString();

                      if (distributorCode == null || distributorCode.isEmpty) {
                        setState(() {});
                        return;
                      }

                      try {
                        monthlyGoalsRemaining =
                            await GoalsApi.getMonthlyGoalsRemaining(
                              distributorCode: distributorCode,
                            );
                      } catch (e) {
                        _toast(e.toString());
                      }

                      if (mounted) setState(() {});
                    },
                  ),
                ),

                _tableHeader(),

                Expanded(
                  child: ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (_, i) => _buildRow(i),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        "Grand Total: ₹${grandTotal.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitting ? null : createDraft,
                          child: Text(
                            submitting
                                ? "Saving Draft..."
                                : "Create Draft Order",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /* ===============================
     TABLE HEADER
  =============================== */
  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: const Row(
        children: [
          _Cell("Product", 3, bold: true),
          _Cell("Price", 2, bold: true),
          _Cell("Qty", 2, bold: true),
          _Cell("Total", 2, bold: true),
          _Cell("Goal Left", 2, bold: true),
          _Cell("", 1),
        ],
      ),
    );
  }

  /* ===============================
     ROW (UI GOAL MINUS ONLY)
  =============================== */
  Widget _buildRow(int index) {
    final r = rows[index];
    final pid = r.product?["productId"]?.toString();

    final baseGoal = pid != null ? monthlyGoalsRemaining[pid] as int? : null;

    /// ✅ UI-only calculation
    final uiGoalLeft = baseGoal == null ? null : (baseGoal - r.qty);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DropdownButton<Map<String, dynamic>>(
            isExpanded: true,
            value: r.product,
            hint: const Text("Product"),
            items: products
                .map(
                  (p) =>
                      DropdownMenuItem(value: p, child: Text(p["name"] ?? "")),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                r.product = v;
                r.price = ((v?["price"] ?? 0) as num).toInt();
                r.qty = 0;
                r.qtyController.text = "";
              });
            },
          ),
        ),

        _Cell("₹${r.price}", 2),

        Expanded(
          flex: 2,
          child: TextField(
            controller: r.qtyController,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() {
                r.qty = int.tryParse(v) ?? 0;
              });
            },
          ),
        ),

        _Cell("₹${r.total.toStringAsFixed(0)}", 2),

        _Cell(
          uiGoalLeft == null ? "—" : uiGoalLeft.toString(),
          2,
          color: uiGoalLeft == null
              ? Colors.grey
              : uiGoalLeft < 0
              ? Colors.red
              : Colors.green,
        ),

        // ➕ ADD ROW
        Expanded(
          flex: 1,
          child: IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue),
            onPressed: () {
              setState(() {
                rows.add(_OrderRow());
              });
            },
          ),
        ),
      ],
    );
  }
}

/* ===============================
   HELPERS
=============================== */

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool bold;
  final Color? color;

  const _Cell(this.text, this.flex, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : null,
          color: color,
        ),
      ),
    );
  }
}

class _OrderRow {
  Map<String, dynamic>? product;
  int price = 0;
  int qty = 0;

  final TextEditingController qtyController = TextEditingController();

  double get total => price * qty.toDouble();
}
