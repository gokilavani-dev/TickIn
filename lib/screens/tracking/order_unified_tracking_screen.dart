import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/real/order_api.dart';
import '../../api/real/timeline_api.dart';
import '../../api/real/auth_api.dart';

class OrderUnifiedTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderUnifiedTrackingScreen({
    super.key,
    required this.orderId,
    required List<Map<String, dynamic>> timeline,
  });

  @override
  State<OrderUnifiedTrackingScreen> createState() =>
      _OrderUnifiedTrackingScreenState();
}

class _OrderUnifiedTrackingScreenState
    extends State<OrderUnifiedTrackingScreen> {
  bool loading = true;

  /// ORDER
  Map<String, dynamic>? order;
  List<Map<String, dynamic>> items = [];

  /// TIMELINE
  List<Map<String, dynamic>> timeline = [];

  /// LOADING FLOW
  bool loadingStarted = false;
  bool loadingEnded = false;
  int itemIndex = 0;

  /// DRIVER ASSIGN
  String? selectedVehicle;
  String? selectedDriver;
  bool driverAssigned = false;

  final vehicles = [
    "TN64 AD 4438",
    "TN64 AD 4428",
    "TN64 AD 4420",
    "TN64 AD 4430",
    "TN64 XX 0000",
  ];
  final drivers = ["Kathavarayan", "Venkatesh", "Arun", "Sidhik", "Others"];

  bool get isManager =>
      AuthApi.user?["role"] == "MANAGER" || AuthApi.user?["role"] == "MASTER";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    order = await OrderApi.getOrderById(widget.orderId);
    items = List<Map<String, dynamic>>.from(order?["items"] ?? []);
    await loadTimeline();
    setState(() => loading = false);
  }

  // ================= TIMELINE =================

  Future<void> loadTimeline() async {
    final t = await TimelineApi.getTimeline(widget.orderId);
    timeline = List<Map<String, dynamic>>.from(t);
    setState(() {});
  }

  /// 🇮🇳 Indian timestamp formatter
  String _fmtTime(dynamic ts) {
    if (ts == null) return "";
    final d = DateTime.tryParse(ts.toString());
    if (d == null) return "";
    return DateFormat("dd-MM-yyyy hh:mm a").format(d.toLocal());
  }

  // ================= MANAGER ACTIONS =================

  Future<void> startLoading() async {
    await TimelineApi.loadingStart(widget.orderId);
    loadingStarted = true;
    await loadTimeline();
  }

  Future<void> loadNextItem() async {
    if (itemIndex >= items.length) return;

    final item = items[itemIndex];

    await TimelineApi.loadingItem(
      orderId: widget.orderId,
      productId: item["productId"],
      qty: item["qty"],
    );

    itemIndex++;

    /// ✅ Loading end ONLY after last item
    if (itemIndex >= items.length) {
      await TimelineApi.loadingEnd(widget.orderId);
      loadingEnded = true;
      loadingStarted = false;
    }

    await loadTimeline();
    setState(() {});
  }

  Future<void> assignDriver() async {
    if (selectedVehicle == null || selectedDriver == null) return;

    await TimelineApi.assignDriver(
      orderId: widget.orderId,
      driverId: selectedDriver!,
      vehicleNo: selectedVehicle!,
    );

    driverAssigned = true;
    await loadTimeline();
    setState(() {});
  }

  // ================= UI HELPERS =================

  /// ✅ Robust title mapper (FIXES missing events)
  String _title(Map<String, dynamic> t) {
    switch (t["event"]) {
      case "LOAD_START":
        return "Loading started";

      case "LOAD_ITEM":
        final name = t["itemName"] ?? t["name"] ?? t["productName"] ?? "Item";
        final qty = t["qty"] ?? t["quantity"] ?? "";
        return "Loaded $name × $qty";

      case "LOAD_END":
        return "Loading completed";

      case "DRIVER_ASSIGNED":
        return "Driver ${t["driverId"]} • Vehicle ${t["vehicleNo"]}";

      case "REASON_UPDATED":
        return t["reason"] ?? t["message"] ?? t["title"] ?? "Reason updated";

      /// ❌ hide internal noise
      case "VEHICLE_SELECTED":
        return "";

      default:
        return t["title"] ?? t["event"] ?? "";
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order ${widget.orderId} Tracking")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// DISTRIBUTOR NAME
                if (order?["distributorName"] != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      order!["distributorName"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                /// TIMELINE
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: timeline.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = timeline[i];

                      /// hide VEHICLE_SELECTED rows
                      if (t["event"] == "VEHICLE_SELECTED") {
                        return const SizedBox.shrink();
                      }

                      return ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(_title(t)),
                        subtitle: Text(_fmtTime(t["createdAt"] ?? t["time"])),
                      );
                    },
                  ),
                ),

                /// ACTION AREA
                if (isManager)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// LOAD START
                        if (!loadingStarted && !loadingEnded)
                          CheckboxListTile(
                            title: const Text("Loading started"),
                            value: loadingStarted,
                            onChanged: (_) => startLoading(),
                          ),

                        /// ITEM LOADING (name + qty)
                        if (loadingStarted && itemIndex < items.length)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${items[itemIndex]["name"]} × ${items[itemIndex]["qty"]}",
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: loadNextItem,
                              ),
                            ],
                          ),

                        /// DRIVER ASSIGN (ONLY AFTER LOAD END)
                        if (loadingEnded && !driverAssigned) ...[
                          const Divider(),
                          Row(
                            children: [
                              const Text("Vehicle"),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedVehicle,
                                  hint: const Text("Select Vehicle"),
                                  items: vehicles
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(v),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => selectedVehicle = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text("Driver"),
                              const SizedBox(width: 24),
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedDriver,
                                  hint: const Text("Select Driver"),
                                  items: drivers
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (d) =>
                                      setState(() => selectedDriver = d),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed:
                                  selectedDriver != null &&
                                      selectedVehicle != null
                                  ? assignDriver
                                  : null,
                              child: const Text("Assign"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
