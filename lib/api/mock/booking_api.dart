// lib/api/mock/booking_api.dart
import '../real/auth_api.dart';
import 'mock_db.dart';

class BookingApi {
  static Future<List<Map<String, dynamic>>> getBookingHistory() async {
    await Future.delayed(const Duration(milliseconds: 250));

    final role = AuthApi.user?["role"] ?? "";
    final pk = AuthApi.user?["pk"] ?? "";
    final distributorCode = AuthApi.user?["distributorCode"] ?? "";

    // Manager: all bookings
    if (role == "MANAGER" || role == "MASTER") {
      return List<Map<String, dynamic>>.from(MockDb.bookings);
    }

    // Sales Officer: only those created by him (createdByPk match)
    if (role == "SALES OFFICER") {
      return MockDb.bookings
          .where((b) => b["createdByPk"] == pk || pk == "SO#111")
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    // Distributor: only his bookings (distributorId match)
    if (role == "DISTRIBUTOR") {
      return MockDb.bookings
          .where((b) => b["distributorId"] == distributorCode)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  }

  static void _recalculateTrip(String tripId) {
    final trip = MockDb.trips[tripId];
    if (trip == null) return;

    final tripBookings = MockDb.bookings
        .where((b) => b["tripId"] == tripId)
        .toList();

    final total = tripBookings.fold<int>(
      0,
      (sum, b) => sum + (b["totalAmount"] as int),
    );

    trip["needsApproval"] = total >= 100000 && total < 150000;
  }

  static Future<void> attachSlotToBooking({
    required String bookingId,
    required Map<String, dynamic> slot,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final idx = MockDb.bookings.indexWhere((b) => b["bookingId"] == bookingId);
    if (idx == -1) return;

    MockDb.bookings[idx]["slotBooked"] = true;
    MockDb.bookings[idx]["slot"] = slot;

    final t = MockDb.tracking[bookingId] ?? [];
    t.add({
      "key": "SLOT_BOOKED",
      "title": "Slot booked",
      "time": DateTime.now().toUtc().toIso8601String(),
    });

    // remove SLOT_NOT_BOOKED if exists
    t.removeWhere((e) => e["key"] == "SLOT_NOT_BOOKED");
    MockDb.tracking[bookingId] = t;

    _recalculateTrip(MockDb.bookings[idx]["tripId"]);
  }

  static Future<void> approveTrip({required String tripId}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // mark all bookings in this trip as approved
    for (final b in MockDb.bookings) {
      if (b["tripId"] == tripId) {
        b["tripApproved"] = true;
      }
    }

    // add tracking entry for all bookings in trip
    for (final b in MockDb.bookings) {
      if (b["tripId"] == tripId) {
        final bookingId = b["bookingId"];
        final t = MockDb.tracking[bookingId] ?? [];
        t.add({
          "key": "TRIP_APPROVED",
          "title": "Trip approved by manager",
          "time": DateTime.now().toUtc().toIso8601String(),
        });
        MockDb.tracking[bookingId] = t;
      }
    }
  }
}
