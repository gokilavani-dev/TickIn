import 'package:flutter/material.dart';
import '../../api/real/order_api.dart';

class SalesDraftDetailScreen extends StatefulWidget {
  const SalesDraftDetailScreen({super.key});

  @override
  State<SalesDraftDetailScreen> createState() => _SalesDraftDetailScreenState();
}

class _SalesDraftDetailScreenState extends State<SalesDraftDetailScreen> {
  bool submitting = false;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> order = Map<String, dynamic>.from(
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
    );

    // 🔒 SAFE COPY (no side effects)
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      (order["items"] ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    final String orderId = (order["orderId"] ?? "").toString();

    return Scaffold(
      appBar: AppBar(title: const Text("Draft Order")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              (order["distributorName"] ?? "").toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            /* =========================
               ITEMS LIST
            ========================= */
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final it = items[i];
                  return ListTile(
                    title: Text((it["name"] ?? "").toString()),
                    subtitle: Text(
                      "Qty: ${it["qty"] ?? 0} • ₹${it["price"] ?? 0}",
                    ),
                    trailing: Text("₹${it["total"] ?? 0}"),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Text(
              "Grand Total: ₹${order["totalAmount"] ?? 0}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            /* =========================
               ACTION BUTTONS
            ========================= */
            Row(
              children: [
                // ✏️ EDIT DRAFT
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Order"),
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        "/sales/edit-draft",
                        arguments: order,
                      );

                      // 🔄 refresh after edit
                      if (mounted) setState(() {});
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // 💾 SAVE DRAFT
                Expanded(
                  child: ElevatedButton(
                    onPressed: submitting
                        ? null
                        : () async {
                            if (orderId.isEmpty) {
                              _toast("Invalid orderId");
                              return;
                            }

                            if (submitting) return; // 🛑 safety

                            setState(() => submitting = true);

                            try {
                              await OrderApi.updateDraftOrder(
                                orderId: orderId,
                                items: items
                                    .map(
                                      (e) => {
                                        "productId": e["productId"],
                                        "qty": e["qty"],
                                      },
                                    )
                                    .toList(),
                              );

                              if (!mounted) return;

                              Navigator.pop(context, true);
                            } catch (e) {
                              _toast(e.toString());
                            } finally {
                              if (mounted) {
                                setState(() => submitting = false);
                              }
                            }
                          },
                    child: Text(submitting ? "Saving..." : "Save Draft"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
