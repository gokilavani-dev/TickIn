import 'mock_db.dart';

class MockOrderApi {
  /// ---------------- CREATE ORDER ----------------
  static Future<Map<String, dynamic>> createOrder({
    required String distributorId,
    required String distributorName,
    required List<Map<String, dynamic>> items,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final bookingId = "BKG${DateTime.now().millisecondsSinceEpoch}";
    final orderId = "ORD${DateTime.now().millisecondsSinceEpoch}";

    final totalAmount = items.fold<int>(
      0,
      (int sum, Map<String, dynamic> i) =>
          sum + ((i["qty"] as int? ?? 0) * 100),
    );

    final booking = {
      "bookingId": bookingId,
      "orderId": orderId,
      "createdByRole": "SALES OFFICER",
      "createdByPk": "SO#TEMP",
      "distributorId": distributorId,
      "distributorName": distributorName,
      "items": items,
      "totalAmount": totalAmount,
      "slotBooked": false,
      "slot": null,
      "createdAt": DateTime.now().toIso8601String(),
      "tripId": null,
    };

    MockDb.bookings.add(booking);

    MockDb.tracking[bookingId] = [
      {
        "key": "ORDER_RECEIVED",
        "title": "Order received",
        "time": DateTime.now().toIso8601String(),
      },
      {
        "key": "SLOT_NOT_BOOKED",
        "title": "Slot not booked yet",
        "time": DateTime.now().toIso8601String(),
      },
    ];

    return booking;
  }

  /// ---------------- GET BOOKINGS ----------------
  static Future<List<Map<String, dynamic>>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockDb.bookings;
  }

  /// ---------------- ATTACH SLOT ----------------
  static Future<void> attachSlot({
    required String bookingId,
    required Map<String, dynamic> slot,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = MockDb.bookings.indexWhere(
      (b) => b["bookingId"] == bookingId,
    );
    if (index == -1) return;

    MockDb.bookings[index]["slot"] = slot;
    MockDb.bookings[index]["slotBooked"] = true;

    MockDb.tracking[bookingId]?.add({
      "key": "SLOT_BOOKED",
      "title": "Slot booked (${slot["time"]})",
      "time": DateTime.now().toIso8601String(),
    });
  }

  /// ---------------- ASSIGN VEHICLE + DRIVER ----------------
  static Future<void> assignVehicleAndDriver({
    required String bookingId,
    required String vehicleNo,
    required String driverName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    MockDb.tracking[bookingId]?.addAll([
      {
        "key": "LOADING_STARTED",
        "title": "Loading started",
        "time": DateTime.now().toIso8601String(),
      },
      {
        "key": "VEHICLE_ASSIGNED",
        "title": "Vehicle $vehicleNo | Driver $driverName",
        "time": DateTime.now().toIso8601String(),
      },
      {
        "key": "LOADING_COMPLETED",
        "title": "Loading completed",
        "time": DateTime.now().toIso8601String(),
      },
    ]);
  }

  /// ---------------- COMPLETE TRIP ----------------
  static Future<void> completeTrip(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    MockDb.tracking[bookingId]?.add({
      "key": "DELIVERED",
      "title": "Delivered",
      "time": DateTime.now().toIso8601String(),
    });
  }

  /// ---------------- GET TRACKING ----------------
  static Future<List<Map<String, dynamic>>> getTracking(
    String bookingId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDb.tracking[bookingId] ?? [];
  }
}
