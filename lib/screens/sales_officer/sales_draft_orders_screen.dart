import 'package:flutter/material.dart';
import '../../api/real/order_api.dart';
import '../../api/real/goals_api.dart';

class SalesDraftOrdersScreen extends StatefulWidget {
  const SalesDraftOrdersScreen({super.key});

  @override
  State<SalesDraftOrdersScreen> createState() => _SalesDraftOrdersScreenState();
}

class _SalesDraftOrdersScreenState extends State<SalesDraftOrdersScreen> {
  bool loading = true;
  List<Map<String, dynamic>> drafts = [];

  @override
  void initState() {
    super.initState();
    loadDrafts();
  }

  /* ===============================
     LOAD DRAFT ORDERS
  =============================== */
  Future<void> loadDrafts() async {
    try {
      drafts = await OrderApi.getMyDraftOrders();
    } catch (e) {
      _toast(e.toString());
    }
    if (mounted) setState(() => loading = false);
  }

  /* ===============================
     CONFIRM DRAFT
     ✅ FINAL GOAL CHECK
     ✅ DB DEDUCT HERE ONLY
  =============================== */
  Future<void> _confirmDraft(
    String orderId,
    String distributorCode,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final goals = await GoalsApi.getMonthlyGoalsRemaining(
        distributorCode: distributorCode,
      );

      for (final it in items) {
        final pid = it["productId"].toString();
        final qty = it["qty"] ?? 0;

        if (!goals.containsKey(pid)) continue;

        final remaining = goals[pid] ?? 0;
        if (qty > remaining) {
          _toast("Goal exceeded for ${it["name"]}");
          return;
        }
      }

      await OrderApi.confirmDraftOrder(orderId);

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        "/order-success",
        arguments: orderId,
      );
    } catch (e) {
      _toast(e.toString());
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Draft Orders")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : drafts.isEmpty
          ? const Center(child: Text("No draft orders"))
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => loading = true);
                await loadDrafts();
              },
              child: ListView.builder(
                itemCount: drafts.length,
                itemBuilder: (_, i) {
                  final o = drafts[i];
                  final orderId = o["orderId"]?.toString() ?? "";

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text((o["distributorName"] ?? "").toString()),
                      subtitle: Text("₹${o["totalAmount"] ?? 0}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final updated = await Navigator.pushNamed(
                                context,
                                "/sales/draft-detail",
                                arguments: o,
                              );
                              if (updated == true) {
                                await loadDrafts();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: orderId.isEmpty
                                ? null
                                : () => _confirmDraft(
                                    orderId,
                                    o["distributorCode"].toString(),
                                    List<Map<String, dynamic>>.from(
                                      o["items"] ?? [],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
