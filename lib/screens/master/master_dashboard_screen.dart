import 'package:flutter/material.dart';
import '../../api/real/manager_master_api.dart';
import '../../api/real/timeline_api.dart';
import '../../api/real/auth_api.dart';
import '../tracking/order_unified_tracking_screen.dart';

class MasterDashboardScreen extends StatefulWidget {
  const MasterDashboardScreen({super.key});

  @override
  State<MasterDashboardScreen> createState() => _MasterDashboardScreenState();
}

class _MasterDashboardScreenState extends State<MasterDashboardScreen> {
  bool loading = true;
  List<Map<String, dynamic>> todayOrders = [];
  List<Map<String, dynamic>> pendingOrders = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  String formatDate(String? ts) {
    if (ts == null || ts.isEmpty) return "";
    final d = DateTime.tryParse(ts);
    if (d == null) return "";
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year}";
  }

  Future<void> load() async {
    final t = await ManagerMasterApi.getTodayOrders();
    final p = await ManagerMasterApi.getPendingOrders();

    setState(() {
      todayOrders = t;
      pendingOrders = p;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // ✅ TODAY + PENDING
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Master Dashboard"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                AuthApi.token = null;
                AuthApi.user = null;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/",
                  (route) => false,
                );
              },
            ),
          ],

          /// ✅ TOP NAV BAR (TABS)
          bottom: TabBar(
            tabs: [
              /// TODAY ORDERS TAB
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Today Orders"),
                    const SizedBox(width: 6),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.blue,
                      child: Text(
                        todayOrders.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// PENDING ORDERS TAB (WITH BADGE)
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Pending Orders"),
                    const SizedBox(width: 6),
                    if (pendingOrders.isNotEmpty)
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          pendingOrders.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: load,

                /// ✅ TAB SWITCHING – ONLY CARDS CHANGE
                child: TabBarView(
                  children: [
                    /// TODAY ORDERS VIEW
                    ListView(
                      padding: const EdgeInsets.all(12),
                      children: todayOrders.map(_todayOrderCard).toList(),
                    ),

                    /// PENDING ORDERS VIEW
                    ListView(
                      padding: const EdgeInsets.all(12),
                      children: pendingOrders.map(_pendingOrderCard).toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /* ===============================
     TODAY ORDER CARD (UNCHANGED)
  =============================== */
  Widget _todayOrderCard(Map<String, dynamic> o) {
    final orderId = o["orderId"];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              o["distributorName"] ?? "Distributor",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "₹${o["totalAmount"]} • ${o["orderDate"] ?? ""}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              o["status"] ?? "",
              style: TextStyle(
                color: o["status"] == "DELIVERED"
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.timeline),
                onPressed: () async {
                  final timeline = await TimelineApi.getTimeline(orderId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderUnifiedTrackingScreen(
                        orderId: orderId,
                        timeline: timeline,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ===============================
     PENDING ORDER CARD (UNCHANGED)
  =============================== */
  Widget _pendingOrderCard(Map<String, dynamic> o) {
    final orderId = o["orderId"];

    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              o["distributorName"] ?? "Distributor",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "₹${o["totalAmount"]} • ${formatDate(o["createdAt"] ?? o["orderDate"])}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              o["pendingReason"] ?? "Pending",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.timeline),
                onPressed: () async {
                  final timeline = await TimelineApi.getTimeline(orderId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderUnifiedTrackingScreen(
                        orderId: orderId,
                        timeline: timeline,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
