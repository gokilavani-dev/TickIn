// lib/api/mock/slot_api.dart
class MockSlotApi {
  static Future<List> getSlots({
    required String companyCode,
    required String date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final times = [
      "09:00",
      "09:30",
      "10:00",
      "10:30",
      "11:00",
      "11:30",
      "12:00",
      "12:30",
      "14:00",
      "14:30",
      "15:00",
      "15:30",
      "16:00",
      "16:30",
      "20:00",
      "20:30",
    ];

    // default grid
    return times.map((t) {
      return {"time": t, "booked": false, "vehicleType": "FULL", "pos": "A"};
    }).toList();
  }

  static Future<void> bookSlot({
    required String companyCode,
    required String date,
    required String time,
    required String vehicleType,
    required dynamic pos,
    required dynamic userId,
    required dynamic distributorCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // no-op for now (screen will just refresh)
  }
}
