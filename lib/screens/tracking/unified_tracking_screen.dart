import 'package:flutter/material.dart';
import '../../api/mock/tracking_api.dart';
import '../../api/real/auth_api.dart';

class UnifiedTrackingScreen extends StatefulWidget {
  final String tripId;

  const UnifiedTrackingScreen({super.key, required this.tripId});

  @override
  State<UnifiedTrackingScreen> createState() => _UnifiedTrackingScreenState();
}

class _UnifiedTrackingScreenState extends State<UnifiedTrackingScreen> {
  bool loading = true;

  bool loadingStarted = false;
  bool loadingEnded = false;

  List<Map<String, dynamic>> timeline = [];
  List<Map<String, dynamic>> tripBookings = [];

  int bookingIndex = 0;
  int itemIndex = 0;
  int driverOrderIndex = 0;

  bool arrived = false;
  bool unloadStarted = false;
  bool unloadCompleted = false;

  // 🔹 Vehicle & Driver
  String? selectedVehicle;
  String? selectedDriver;

  final vehicles = ["TN09 AB 1234", "TN10 XY 5678"];
  final drivers = ["Ravi", "Kumar"];

  bool get isManager => AuthApi.user?["role"] == "MANAGER";
  bool get isDriver => AuthApi.user?["role"] == "DRIVER";

  @override
  void initState() {
    super.initState();
    initTrip();
  }

  Future<void> initTrip() async {
    tripBookings = await MockTrackingApi.getTripBookings(tripId: widget.tripId);
    await loadTimeline();
    setState(() => loading = false);
  }

  // ================= TIMELINE =================
  Future<void> loadTimeline() async {
    final rawTimeline = await MockTrackingApi.getTripTimeline(
      tripId: widget.tripId,
    );

    // Distributor / Driver view – 그대로
    if (!isManager) {
      timeline = rawTimeline;
      setState(() {});
      return;
    }

    // ===== MANAGER VIEW : DRIVER_ASSIGNED MERGE =====
    final driverAssigned = rawTimeline
        .where((t) => t["key"] == "DRIVER_ASSIGNED")
        .toList();

    final otherEvents = rawTimeline
        .where((t) => t["key"] != "DRIVER_ASSIGNED")
        .toList();

    if (driverAssigned.isNotEmpty) {
      final driver = driverAssigned.first["driver"];
      final vehicle = driverAssigned.first["vehicle"];

      final distributors = driverAssigned
          .map((e) => e["distributor"])
          .toSet()
          .join(" and ");

      otherEvents.add({
        "key": "DRIVER_ASSIGNED_MERGED",
        "driver": driver,
        "vehicle": vehicle,
        "distributors": distributors,
        "time": driverAssigned.last["time"],
      });
    }

    timeline = otherEvents;
    setState(() {});
  }

  // ================= MANAGER =================
  Future<void> loadNextItem() async {
    if (bookingIndex >= tripBookings.length) return;

    final booking = tripBookings[bookingIndex];
    final items = booking["items"];

    if (itemIndex == 0) {
      await MockTrackingApi.addInfo(
        bookingId: booking["bookingId"],
        title:
            "Loading started for ${booking["distributorName"]} (Order ${booking["orderId"]})",
      );
    }

    await MockTrackingApi.loadingItem(
      bookingId: booking["bookingId"],
      distributor: booking["distributorName"],
      item: items[itemIndex]["name"],
    );

    itemIndex++;

    if (itemIndex >= items.length) {
      // 👇 ADD THIS
      await MockTrackingApi.loadingEnd(
        bookingId: booking["bookingId"],
        distributor: booking["distributorName"],
      );
      bookingIndex++;
      itemIndex = 0;
      loadingStarted = false;
    }

    await loadTimeline();
  }

  Future<void> finishLoading() async {
    if (loadingEnded) return;

    loadingEnded = true;

    for (final b in tripBookings) {
      await MockTrackingApi.assignDriver(
        distributor: b["distributorName"],
        bookingId: b["bookingId"],
        driver: selectedDriver!,
        vehicle: selectedVehicle!,
      );

      // await MockTrackingApi.loadingEnd(bookingId: b["bookingId"]);
    }

    await loadTimeline();
    setState(() {});
  }

  // ================= DRIVER =================
  Future<void> driverArrived() async {
    final booking = tripBookings[driverOrderIndex];
    await MockTrackingApi.arrivedAtSite(bookingId: booking["bookingId"]);
    arrived = true;
    loadTimeline();
  }

  Future<void> driverUnloadStart() async {
    final booking = tripBookings[driverOrderIndex];
    await MockTrackingApi.unloadingStarted(bookingId: booking["bookingId"]);
    unloadStarted = true;
    loadTimeline();
  }

  Future<void> driverUnloadEnd() async {
    final booking = tripBookings[driverOrderIndex];
    await MockTrackingApi.unloadingCompleted(bookingId: booking["bookingId"]);

    arrived = false;
    unloadStarted = false;
    unloadCompleted = false;

    driverOrderIndex++;
    loadTimeline();
  }

  // ================= TITLE BUILDER =================
  String _buildTitle(Map<String, dynamic> t) {
    switch (t["key"]) {
      case "DRIVER_ASSIGNED":
        // Distributor / Driver view
        return "Driver ${t["driver"]} (${t["vehicle"]}) assigned";

      case "DRIVER_ASSIGNED_MERGED":
        // Manager view – single line
        return "Driver ${t["driver"]} (${t["vehicle"]}) assigned for ${t["distributors"]}";

      default:
        return t["title"] ?? "";
    }
  }

  String _extractDistributor(String title) {
    // "Loading completed for ABC Traders"
    if (title.contains("for")) {
      return title.split("for").last.trim();
    }
    return "";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Tracking")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: timeline.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = timeline[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text(_buildTitle(t)),
                            subtitle: Text(t["time"]),
                          ),

                          // 🔹 Visual divider after distributor loading completed (Manager only)
                          if (isManager &&
                              t["key"] == "LOADING_COMPLETED" &&
                              t["title"] != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider(thickness: 1)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      _extractDistributor(t["title"]),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider(thickness: 1)),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // ACTION AREA
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isManager && bookingIndex < tripBookings.length)
                        CheckboxListTile(
                          title: Text(
                            "Loading started – ${tripBookings[bookingIndex]["distributorName"]}",
                          ),
                          value: loadingStarted,
                          onChanged: loadingStarted
                              ? null
                              : (_) => setState(() => loadingStarted = true),
                        ),

                      if (isManager && loadingStarted)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tripBookings[bookingIndex]["items"][itemIndex]["name"],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: loadNextItem,
                            ),
                          ],
                        ),

                      if (isManager &&
                          bookingIndex >= tripBookings.length &&
                          !loadingEnded) ...[
                        const Divider(),

                        Row(
                          children: [
                            const Text("Vehicle"),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text("Select Vehicle"),
                                value: selectedVehicle,
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
                                hint: const Text("Select Driver"),
                                value: selectedDriver,
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
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed:
                                selectedVehicle != null &&
                                    selectedDriver != null
                                ? finishLoading
                                : null,
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
