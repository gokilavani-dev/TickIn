import 'package:flutter/material.dart';
import '../../api/real/manager_master_api.dart';
import '../../api/real/timeline_api.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Master Dashboard")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const Text(
                    "📦 Today Orders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...todayOrders.map(_orderCard),

                  const Divider(height: 32),

                  const Text(
                    "⏳ Pending Orders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...pendingOrders.map(_pendingCard),
                ],
              ),
            ),
    );
  }

  Widget _orderCard(Map<String, dynamic> o) {
    return Card(
      child: ListTile(
        title: Text("Order #${o["orderId"]}"),
        subtitle: Text("₹${o["totalAmount"]} • ${o["status"]}"),
        trailing: const Icon(Icons.timeline),
        onTap: () async {
          final timeline = await TimelineApi.getTimeline(o["orderId"]);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  _TimelineView(orderId: o["orderId"], timeline: timeline),
            ),
          );
        },
      ),
    );
  }

  Widget _pendingCard(Map<String, dynamic> o) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        title: Text("Order #${o["orderId"]}"),
        subtitle: Text(
          o["pendingReason"] ?? "No reason",
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  final String orderId;
  final List<Map<String, dynamic>> timeline;

  const _TimelineView({required this.orderId, required this.timeline});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order $orderId")),
      body: ListView.builder(
        itemCount: timeline.length,
        itemBuilder: (_, i) {
          final t = timeline[i];
          return ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(t["event"] ?? t["title"] ?? ""),
            subtitle: Text(t["createdAt"] ?? ""),
          );
        },
      ),
    );
  }
}
