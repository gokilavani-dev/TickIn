import 'package:flutter/material.dart';
import '../../api/api_mode.dart';
import '../../api/mock/booking_api.dart';
import '../../api/real/auth_api.dart';
import '../tracking/unified_tracking_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool loading = true;
  List<Map<String, dynamic>> bookings = [];

  bool get isManager =>
      AuthApi.user?["role"] == "MANAGER" || AuthApi.user?["role"] == "MASTER";

  bool get isSalesOfficer => AuthApi.user?["role"] == "SALES OFFICER";

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    setState(() => loading = true);
    bookings = useMockApi ? await BookingApi.getBookingHistory() : [];
    if (!mounted) return;
    setState(() => loading = false);
  }

  // ✅ GROUP BOOKINGS BY TRIP
  Map<String, List<Map<String, dynamic>>> get groupedTrips {
    final Map<String, List<Map<String, dynamic>>> map = {};
    for (final b in bookings) {
      final tripId = b["tripId"] ?? b["bookingId"];
      map.putIfAbsent(tripId, () => []);
      map[tripId]!.add(b);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final trips = groupedTrips.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Booking History")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: trips.length,
              itemBuilder: (_, i) {
                final tripId = trips[i].key;
                final tripBookings = trips[i].value;
                return _tripCard(tripId, tripBookings);
              },
            ),
    );
  }

  Widget _tripCard(String tripId, List<Map<String, dynamic>> tripBookings) {
    final slotBooked = tripBookings.every((b) => b["slotBooked"] == true);
    final needsApproval = tripBookings.any((b) => b["tripApproved"] != true);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Text(
              "Trip: $tripId",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // ORDERS INSIDE TRIP
            ...tripBookings.map(
              (b) => Text("• ${b["distributorName"]} | Order ${b["orderId"]}"),
            ),

            const SizedBox(height: 8),

            Chip(label: Text(slotBooked ? "Slot Booked" : "Slot Not Booked")),

            const SizedBox(height: 8),

            Row(
              children: [
                // TRACK
                TextButton.icon(
                  icon: const Icon(Icons.timeline),
                  label: const Text("Track"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UnifiedTrackingScreen(tripId: tripId),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // APPROVE TRIP (Manager only)
                if (isManager && needsApproval)
                  ElevatedButton(
                    onPressed: () async {
                      await BookingApi.approveTrip(tripId: tripId);
                      loadBookings();
                    },
                    child: const Text("Approve Trip"),
                  ),

                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
