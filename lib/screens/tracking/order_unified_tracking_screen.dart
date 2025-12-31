import 'package:flutter/material.dart';
import '../../api/real/order_api.dart';
import '../../api/real/timeline_api.dart';
import '../../api/real/auth_api.dart';

class OrderUnifiedTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderUnifiedTrackingScreen({super.key, required this.orderId, required List<Map<String, dynamic>> timeline});

  @override
  State<OrderUnifiedTrackingScreen> createState() =>
      _OrderUnifiedTrackingScreenState();
}

class _OrderUnifiedTrackingScreenState
    extends State<OrderUnifiedTrackingScreen> {
  bool loading = true;

  // order data
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> timeline = [];

  // loading flow
  bool loadingStarted = false;
  bool loadingEnded = false;
  int itemIndex = 0;

  // driver flow
  bool arrived = false;
  bool unloadStarted = false;

  // assign
  String? selectedVehicle;
  String? selectedDriver;

  final vehicles = ["TN09 AB 1234", "TN10 XY 5678"];
  final drivers = ["DRV01", "DRV02"];

  bool get isManager =>
      AuthApi.user?["role"] == "MANAGER" || AuthApi.user?["role"] == "MASTER";

  bool get isDriver => AuthApi.user?["role"] == "DRIVER";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final order = await OrderApi.getOrderById(widget.orderId);
    items = List<Map<String, dynamic>>.from(order["items"] ?? []);
    await loadTimeline();
    setState(() => loading = false);
  }

  // ================= TIMELINE =================
  Future<void> loadTimeline() async {
    final t = await TimelineApi.getTimeline(widget.orderId);
    setState(() {
      timeline = List<Map<String, dynamic>>.from(t);
    });
  }

  // ================= MANAGER =================
  Future<void> startLoading() async {
    await TimelineApi.loadingStart(widget.orderId);
    loadingStarted = true;
    await loadTimeline();
    setState(() {});
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

    if (itemIndex >= items.length) {
      await TimelineApi.loadingEnd(widget.orderId);
      loadingEnded = true;
      loadingStarted = false;
    }

    await loadTimeline();
    setState(() {});
  }

  Future<void> assignDriver() async {
    await TimelineApi.assignDriver(
      orderId: widget.orderId,
      driverId: selectedDriver!,
      vehicleNo: selectedVehicle!,
    );

    await loadTimeline();
    setState(() {});
  }

  // ================= DRIVER =================
  Future<void> markArrived() async {
    await TimelineApi.arrived(widget.orderId);
    arrived = true;
    await loadTimeline();
    setState(() {});
  }

  Future<void> startUnload() async {
    await TimelineApi.unloadStart(widget.orderId);
    unloadStarted = true;
    await loadTimeline();
    setState(() {});
  }

  Future<void> endUnload() async {
    await TimelineApi.unloadEnd(widget.orderId);
    unloadStarted = false;
    arrived = false;
    await loadTimeline();
    setState(() {});
  }

  // ================= UI HELPERS =================
  String _title(Map<String, dynamic> t) {
    return t["event"] ?? t["title"] ?? "";
  }

  String _time(Map<String, dynamic> t) {
    return t["createdAt"] ?? "";
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
                // ===== TIMELINE =====
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: timeline.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = timeline[i];
                      return ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(_title(t)),
                        subtitle: Text(_time(t)),
                      );
                    },
                  ),
                ),

                // ===== ACTION AREA =====
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MANAGER: START LOADING
                      if (isManager && !loadingStarted && !loadingEnded)
                        CheckboxListTile(
                          title: const Text("Loading started"),
                          value: loadingStarted,
                          onChanged: (_) => startLoading(),
                        ),

                      // MANAGER: ITEM BY ITEM
                      if (isManager && loadingStarted)
                        Row(
                          children: [
                            Expanded(child: Text(items[itemIndex]["name"])),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: loadNextItem,
                            ),
                          ],
                        ),

                      // MANAGER: ASSIGN DRIVER
                      if (isManager && loadingEnded) ...[
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

                      // DRIVER FLOW
                      if (isDriver && !arrived)
                        ElevatedButton(
                          onPressed: markArrived,
                          child: const Text("Arrived"),
                        ),

                      if (isDriver && arrived && !unloadStarted)
                        ElevatedButton(
                          onPressed: startUnload,
                          child: const Text("Unload Start"),
                        ),

                      if (isDriver && unloadStarted)
                        ElevatedButton(
                          onPressed: endUnload,
                          child: const Text("Unload End"),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
