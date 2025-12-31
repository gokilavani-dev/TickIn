import 'package:flutter/material.dart';
import '../../api/real/order_api.dart';
import '../../api/real/auth_api.dart';

class SalesConfirmedOrdersScreen extends StatefulWidget {
  const SalesConfirmedOrdersScreen({super.key});

  @override
  State<SalesConfirmedOrdersScreen> createState() =>
      _SalesConfirmedOrdersScreenState();
}

class _SalesConfirmedOrdersScreenState
    extends State<SalesConfirmedOrdersScreen> {
  bool loading = true;
  List<Map<String, dynamic>> orders = [];

  /* ===============================
     ROLE HELPERS
  =============================== */
  bool get isManager =>
      AuthApi.user?["role"] == "MANAGER" || AuthApi.user?["role"] == "MASTER";

  bool get isSalesOfficer => AuthApi.user?["role"] == "SALES OFFICER";

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  /* ===============================
     LOAD CONFIRMED (PENDING) ORDERS
  =============================== */
  Future<void> loadOrders() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      if (isManager) {
        // 👑 Manager / Master – ALL pending orders
        orders = await OrderApi.getAllPendingOrders();
      } else if (isSalesOfficer) {
        // 👤 Sales Officer – only my pending orders
        orders = await OrderApi.getMyPlacedOrders();
      } else {
        orders = [];
      }
    } catch (e) {
      _toast(e.toString());
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isManager ? "All Orders" : "My Orders")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text("No confirmed orders"))
          : RefreshIndicator(
              onRefresh: loadOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (_, i) {
                  final order = orders[i];
                  return _orderCard(order);
                },
              ),
            ),
    );
  }

  /* ===============================
     ORDER CARD (INLINE BOOK SLOT ADDED)
  =============================== */
  Widget _orderCard(Map<String, dynamic> order) {
    debugPrint("ORDER CARD DATA => $order"); // 👈 ADD
    final bool slotBooked = order["slotBooked"] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* -------- BASIC INFO -------- */
            Text(
              order["distributorName"]?.toString() ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text("Order ID: ${order["orderId"] ?? ""}"),
            Text("Amount: ₹${order["totalAmount"] ?? 0}"),

            const SizedBox(height: 6),

            Text(
              slotBooked ? "Slot Booked" : "Slot Not Booked",
              style: TextStyle(
                color: slotBooked ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            /* -------- INLINE BOOK SLOT BUTTON -------- */
            if (!slotBooked)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: const Text("Book Slot"),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/slot-booking",
                      arguments: {
                        "bookingId": order["orderId"],

                        // ✅ IMPORTANT FIX
                        "distributorCode":
                            order["distributorCode"] ??
                            order["distributorId"] ??
                            order["distributor_code"],

                        "distributorName": order["distributorName"],
                        "distributorZone": order["distributorZone"],

                        "amount": order["totalAmount"],
                      },
                    ).then((_) {
                      loadOrders(); // refresh after booking
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
