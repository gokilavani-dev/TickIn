import 'package:book_yours/screens/tracking/order_unified_tracking_screen.dart';
import 'package:flutter/material.dart';
import '../../api/real/manager_master_api.dart';
import '../../api/real/timeline_api.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  bool loading = true;
  List<Map<String, dynamic>> pendingOrders = [];

  // 🔑 Reasons list
  final List<String> reasons = [
    "Stock not available",
    "Credit limit exceeded",
    "Distributor issue",
    "Invalid order",
    "Other",
  ];

  // 🔑 Selected reason per order (String ONLY)
  final Map<String, String> selectedReasons = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await ManagerMasterApi.getPendingOrders();
    setState(() {
      pendingOrders = p;
      loading = false;
    });
  }

  // ✅ SAVE (NO MAP LOOKUP BUG)
  Future<void> saveReason({
    required String orderId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a reason")));
      return;
    }

    await ManagerMasterApi.savePendingReason(
      orderId: orderId,
      reason: reason.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Reason saved successfully")));

    selectedReasons.clear();
    await load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manager Dashboard")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: pendingOrders.length,
                itemBuilder: (_, i) {
                  final o = pendingOrders[i];

                  // 🔥 FORCE orderId as String (CRITICAL FIX)
                  final String orderId = o["orderId"].toString();

                  // Prefill from DB only once
                  if (!selectedReasons.containsKey(orderId)) {
                    final dbReason = (o["pendingReason"] ?? "")
                        .toString()
                        .trim();
                    if (dbReason.isNotEmpty) {
                      selectedReasons[orderId] = dbReason;
                    }
                  }

                  return Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order #$orderId",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Distributor: ${o["distributorName"] ?? "-"}"),

                          const SizedBox(height: 8),

                          // 🔽 DROPDOWN
                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: selectedReasons[orderId],
                            hint: const Text("Select reason"),
                            items: reasons
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() {
                                selectedReasons[orderId] = val;
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // 💾 SAVE
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: selectedReasons[orderId] == null
                                  ? null
                                  : () => saveReason(
                                      orderId: orderId,
                                      reason: selectedReasons[orderId]!,
                                    ),
                              child: const Text("Save"),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Existing DB value display (UNCHANGED)
                          Text(
                            "Reason: ${(o["pendingReason"] ?? "").toString().isNotEmpty ? o["pendingReason"] : "Not provided"}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Divider(),

                          // 🕒 TIMELINE (UNCHANGED)
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.timeline),
                              onPressed: () async {
                                final timeline = await TimelineApi.getTimeline(
                                  orderId,
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderUnifiedTrackingScreen(
                                      orderId: orderId,
                                      timeline:
                                          timeline, // if constructor accepts it
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
                },
              ),
            ),
    );
  }
}

// class _TimelineView extends StatelessWidget {
//   final String orderId;
//   final List<Map<String, dynamic>> timeline;

//   const _TimelineView({required this.orderId, required this.timeline});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Order $orderId")),
//       body: ListView.builder(
//         itemCount: timeline.length,
//         itemBuilder: (_, i) {
//           final t = timeline[i];
//           return ListTile(
//             leading: const Icon(Icons.check_circle_outline),
//             title: Text(t["event"] ?? t["title"] ?? ""),
//             subtitle: Text(t["createdAt"] ?? ""),
//           );
//         },
//       ),
//     );
//   }
// }
