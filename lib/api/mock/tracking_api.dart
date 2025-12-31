import 'mock_db.dart';

class MockTrackingApi {
  // ---------- GET TIMELINE ----------
  static Future<List<Map<String, dynamic>>> getTimeline({
    required String bookingId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Map<String, dynamic>>.from(MockDb.tracking[bookingId] ?? []);
  }

  // ---------- GET ALL BOOKINGS IN TRIP ----------
  static Future<List<Map<String, dynamic>>> getTripBookings({
    required String tripId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDb.bookings
        .where((b) => b["tripId"] == tripId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // ---------- MANAGER ----------
  static Future<void> loadingStarted({
    required String bookingId,
    required String distributor,
    required String orderId,
  }) async {
    final t = MockDb.tracking[bookingId] ?? [];
    t.add({
      "key": "LOADING_STARTED",
      "title": "Loading started for $distributor (Order $orderId)",
      "time": DateTime.now().toUtc().toIso8601String(),
    });
    MockDb.tracking[bookingId] = t;
  }

  static Future<void> loadingItem({
    required String bookingId,
    required String distributor,
    required String item,
  }) async {
    final t = MockDb.tracking[bookingId] ?? [];
    t.add({
      "key": "LOADING_ITEM",
      "title": "Loaded $item for $distributor",
      "time": DateTime.now().toUtc().toIso8601String(),
    });
    MockDb.tracking[bookingId] = t;
  }

  static Future<void> loadingEnd({
    required String bookingId,
    required String distributor,
  }) async {
    final t = MockDb.tracking[bookingId] ?? [];
    t.add({
      "key": "LOADING_COMPLETED",
      "title": "Loading completed for $distributor",
      "time": DateTime.now().toUtc().toIso8601String(),
    });
    MockDb.tracking[bookingId] = t;
  }

  static Future<void> assignDriver({
    required String distributor,
    required String bookingId,
    required String driver,
    required String vehicle,
  }) async {
    final t = MockDb.tracking[bookingId] ?? [];
    t.add({
      "key": "DRIVER_ASSIGNED",
      "driver": driver,
      "vehicle": vehicle,
      "distributor": distributor,
      "time": DateTime.now().toUtc().toIso8601String(),
    });
    MockDb.tracking[bookingId] = t;
  }

  // ---------- DRIVER ----------
  static Future<void> arrivedAtSite({required String bookingId}) async {
    _add(bookingId, "ARRIVED_AT_SITE", "Arrived at site");
  }

  static Future<void> unloadingStarted({required String bookingId}) async {
    _add(bookingId, "UNLOADING_STARTED", "Unloading started");
  }

  static Future<void> unloadingCompleted({required String bookingId}) async {
    _add(bookingId, "UNLOADING_COMPLETED", "Unloading completed");
  }

  static Future<void> reachedWarehouse({required String bookingId}) async {
    _add(bookingId, "REACHED_WAREHOUSE", "Reached warehouse");
  }

  static void _add(String id, String key, String title) {
    final t = MockDb.tracking[id] ?? [];
    t.add({
      "key": key,
      "title": title,
      "time": DateTime.now().toUtc().toIso8601String(),
    });
    MockDb.tracking[id] = t;
  }

  // ---------- HELPERS ----------
  static String? lastKey(String bookingId) {
    final t = MockDb.tracking[bookingId];
    if (t == null || t.isEmpty) return null;
    return t.last["key"];
  }

  static Future<List<Map<String, dynamic>>> getTripTimeline({
    required String tripId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final bookings = MockDb.bookings.where((b) => b["tripId"] == tripId);
    final List<Map<String, dynamic>> combined = [];

    for (final b in bookings) {
      final t = MockDb.tracking[b["bookingId"]] ?? [];
      combined.addAll(
        t.map(
          (e) => {
            ...e,
            "bookingId": b["bookingId"],
            "distributor": b["distributorName"],
          },
        ),
      );
    }

    combined.sort((a, b) => a["time"].compareTo(b["time"]));
    return combined;
  }

  // ---------- INFO / MANUAL TIMELINE ENTRY ----------
  static Future<void> addInfo({
    required String bookingId,
    required String title,
  }) async {
    final t = MockDb.tracking[bookingId] ?? [];
    t.add({
      "key": "INFO",
      "title": title,
      "time": DateTime.now().toUtc().toIso8601String(),
    });
    MockDb.tracking[bookingId] = t;
  }
}
