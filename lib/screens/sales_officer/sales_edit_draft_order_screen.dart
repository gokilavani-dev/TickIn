import 'package:flutter/material.dart';
import '../../api/real/product_api.dart';
import '../../api/real/order_api.dart';
import '../../api/real/goals_api.dart';

class SalesEditDraftOrderScreen extends StatefulWidget {
  const SalesEditDraftOrderScreen({super.key});

  @override
  State<SalesEditDraftOrderScreen> createState() =>
      _SalesEditDraftOrderScreenState();
}

class _SalesEditDraftOrderScreenState extends State<SalesEditDraftOrderScreen> {
  bool loading = true;
  bool submitting = false;

  late Map<String, dynamic> order;

  List<Map<String, dynamic>> products = [];
  Map<String, dynamic> monthlyGoalsRemaining = {};

  List<_OrderRow> rows = [];

  double get grandTotal => rows.fold(0, (s, r) => s + r.total);

  @override
  void initState() {
    super.initState();
    Future.microtask(loadData);
  }

  /* ===============================
     LOAD DATA
  =============================== */
  Future<void> loadData() async {
    try {
      order = Map<String, dynamic>.from(
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
      );

      products = await ProductApi.getProducts();

      final distributorCode = order["distributorCode"]?.toString();
      if (distributorCode != null && distributorCode.isNotEmpty) {
        monthlyGoalsRemaining = await GoalsApi.getMonthlyGoalsRemaining(
          distributorCode: distributorCode,
        );
      }

      final items = List<Map<String, dynamic>>.from(order["items"] ?? []);

      rows = items.map((it) {
        final price = (it["price"] ?? 0) as num;
        final qty = (it["qty"] ?? 0) as num;

        return _OrderRow(
          product: products.firstWhere(
            (p) => p["productId"].toString() == it["productId"].toString(),
            orElse: () => {},
          ),
          price: price.toInt(),
          qty: qty.toInt(),
        );
      }).toList();

      if (rows.isEmpty) rows.add(_OrderRow());
    } catch (e) {
      _toast(e.toString());
    }

    if (mounted) setState(() => loading = false);
  }

  /* ===============================
     SAVE DRAFT (NO DB DEDUCT)
  =============================== */
  Future<void> saveDraft() async {
    setState(() => submitting = true);

    try {
      await OrderApi.updateDraftOrder(
        orderId: order["orderId"].toString(),
        items: rows
            .where((r) => r.product != null && r.qty > 0)
            .map((r) => {"productId": r.product!["productId"], "qty": r.qty})
            .toList(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
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
      appBar: AppBar(title: const Text("Edit Draft Order")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    order["distributorName"] ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitting ? null : saveDraft,
                          child: Text(submitting ? "Saving..." : "Save Draft"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

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

  Widget _buildRow(int index) {
    final r = rows[index];
    final pid = r.product?["productId"]?.toString();

    final baseGoal = pid != null ? monthlyGoalsRemaining[pid] as int? : null;

    final uiGoalLeft = baseGoal == null ? null : (baseGoal - r.qty);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DropdownButton<Map<String, dynamic>>(
            isExpanded: true,
            value: r.product?.isEmpty == true ? null : r.product,
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
  int price;
  int qty;

  final TextEditingController qtyController = TextEditingController();

  _OrderRow({this.product, this.price = 0, this.qty = 0}) {
    qtyController.text = qty > 0 ? qty.toString() : "";
  }

  double get total => price * qty.toDouble();
}
