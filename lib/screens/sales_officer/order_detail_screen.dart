import 'dart:async';
import 'package:flutter/material.dart';
import '../../api/real/order_api.dart';
import '../../api/real/auth_api.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Map<String, dynamic> order;

  bool loading = true;
  bool bookingInProgress = false;
  bool refreshing = false; // 🔒 safety

  Timer? refreshTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ SAFE ARGUMENT READ
    order = Map<String, dynamic>.from(
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
    );

    // ✅ ROLE SAFETY (fallback)
    order["viewerRole"] ??= AuthApi.user?["role"] == "MANAGER"
        ? "MANAGER"
        : "SALES_OFFICER";

    loadOrder();

    // 🔔 AUTO REFRESH
    refreshTimer ??= Timer.periodic(
      const Duration(seconds: 8),
      (_) => loadOrder(silent: true),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  /* ===============================
     FETCH LATEST ORDER
  =============================== */
  Future<void> loadOrder({bool silent = false}) async {
    if (refreshing) return;
    refreshing = true;

    try {
      final fresh = await OrderApi.getOrderById(order["orderId"].toString());

      // 🔒 Preserve viewerRole
      order = {
        ...Map<String, dynamic>.from(fresh),
        "viewerRole": order["viewerRole"],
      };

      if (mounted && !silent) {
        setState(() => loading = false);
      }
    } catch (e) {
      if (!silent) _toast(e.toString());
    } finally {
      refreshing = false;
    }
  }

  /* ===============================
     SLOT BOOKING
  =============================== */
  void onBookSlot() {
    if (bookingInProgress) return;

    final bool slotBooked = order["slotBooked"] == true;

    if (slotBooked) {
      _toast("Slot already booked");
      return;
    }

    setState(() => bookingInProgress = true);

    Navigator.pushNamed(
      context,
      "/slot-booking",
      arguments: {
        "orderId": order["orderId"],
        "distributorName": order["distributorName"],
        "distributorId": order["distributorId"],
        "amount": order["totalAmount"],
      },
    ).then((_) async {
      await loadOrder();
      if (mounted) setState(() => bookingInProgress = false);
    });
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final String role = order["viewerRole"]?.toString() ?? "SALES_OFFICER";

    final bool isSalesOfficer = role == "SALES_OFFICER";
    final bool isManager = role == "MANAGER";

    final bool slotBooked = order["slotBooked"] == true;
    final Map<String, dynamic>? slot =
        order["slotDetails"] as Map<String, dynamic>?;

    // ✅ SAFE ITEMS COPY
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      (order["items"] ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isManager ? "Order Details (Manager)" : "Order Details"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /* ---------- HEADER ---------- */
                  Text(
                    order["distributorName"]?.toString() ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Order ID: ${order["orderId"]}"),
                  const SizedBox(height: 10),

                  /* ---------- ITEMS ---------- */
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final it = items[i];
                        return ListTile(
                          title: Text(it["name"]?.toString() ?? ""),
                          subtitle: Text("Qty: ${it["qty"] ?? 0}"),
                          trailing: Text("₹${it["total"] ?? 0}"),
                        );
                      },
                    ),
                  ),

                  /* ---------- TOTAL ---------- */
                  Text(
                    "Grand Total: ₹${order["totalAmount"] ?? 0}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /* ---------- SLOT DETAILS ---------- */
                  if (slotBooked && slot != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📦 Slot Booked",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text("Date: ${slot["date"] ?? "-"}"),
                          Text("Time: ${slot["time"] ?? "-"}"),
                        ],
                      ),
                    ),

                  /* ---------- BOOK SLOT ---------- */
                  if (isSalesOfficer || isManager)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          slotBooked
                              ? "Slot Booked"
                              : bookingInProgress
                              ? "Booking..."
                              : "Book Slot",
                        ),
                        onPressed: slotBooked || bookingInProgress
                            ? null
                            : onBookSlot,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
