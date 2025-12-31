import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_api.dart';

class SlotApi {
  /* ===============================
     GET SLOT GRID
  =============================== */
  static Future<List<dynamic>> getSlots({
    required String companyCode,
    required String date,
  }) async {
    final uri = Uri.parse(
      "${ApiConfig.baseUrl}/api/slots",
    ).replace(queryParameters: {"companyCode": companyCode, "date": date});

    final res = await http.get(uri, headers: AuthApi.authHeaders());
    final data = jsonDecode(res.body);

    if (res.statusCode != 200 || data["ok"] != true) {
      throw Exception(data["error"] ?? "Failed to load slots");
    }

    return data["slots"];
  }

  /* ===============================
     MANAGER: DELETE SLOT
  =============================== */
  static Future<void> deleteSlot({
    required String companyCode,
    required String date,
    required String time,
    required String vehicleType,
    String? pos,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/slots/cancel"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({
        "companyCode": companyCode,
        "date": date,
        "time": time,
        "vehicleType": vehicleType,
        "pos": pos,
      }),
    );

    final data = jsonDecode(res.body);
    if (data["ok"] != true) {
      throw Exception(data["error"] ?? "Delete failed");
    }
  }

  /* ===============================
     MANAGER: EDIT SLOT TIME
  =============================== */
  static Future<void> editSlotTime({
    required String companyCode,
    required String date,
    required String oldTime,
    required String newTime,
    required String vehicleType,
    String? pos,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/slots/edit-time"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({
        "companyCode": companyCode,
        "date": date,
        "oldTime": oldTime,
        "newTime": newTime,
        "vehicleType": vehicleType,
        "pos": pos,
      }),
    );

    final data = jsonDecode(res.body);
    if (data["ok"] != true) {
      throw Exception(data["error"] ?? "Edit failed");
    }
  }

  /* ===============================
     MANAGER: SET FULL TRUCK AMOUNT
  =============================== */
  static Future<void> setFullTruckAmount({
    required String companyCode,
    required int maxAmount,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/slots/set-max"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({"companyCode": companyCode, "maxAmount": maxAmount}),
    );

    final data = jsonDecode(res.body);
    if (data["ok"] != true) {
      throw Exception(data["error"] ?? "Update failed");
    }
  }

  /* ===============================
     ✅ BOOK SLOT (NEW – REAL API)
     Used by "Book Now" button
  =============================== */
  /* ===============================
     ✅ BOOK SLOT (REAL API)
  =============================== */
  static Future<void> bookSlot({
    required String companyCode,
    required String date,
    required String time,
    required String vehicleType, // FULL / HALF
    String? pos,
    required String distributorCode,
    int amount = 0,
  }) async {
    final Map<String, dynamic> body = {
      "companyCode": companyCode,
      "date": date,
      "time": time,
      "vehicleType": vehicleType,
      "distributorCode": distributorCode,
      "amount": amount,
    };

    // ✅ FULL booking → pos mandatory
    if (vehicleType == "FULL") {
      if (pos == null) {
        throw Exception("pos required for FULL booking");
      }
      body["pos"] = pos;
    }

    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/slots/book"),
      headers: AuthApi.authHeaders(), // 🔥 token issue fixed
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200 || data["ok"] != true) {
      throw Exception(data["error"] ?? "Slot booking failed");
    }
  }

  /* ===============================
     MANAGER: SET SLOT MAX AMOUNT
  =============================== */
  static Future<void> managerSetSlotMax({
    required String companyCode,
    required String date,
    required String time,
    required String location,
    required int maxAmount,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/slots/set-max"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({
        "companyCode": companyCode,
        "date": date,
        "time": time,
        "location": location,
        "maxAmount": maxAmount,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["error"] ?? "Set max failed");
    }
  }

  /* ===============================
     MANAGER: EDIT SLOT TIME
  =============================== */
  static Future<void> managerEditSlotTime({
    required String companyCode,
    required String date,
    required String oldTime,
    required String newTime,
    required String location,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/slots/edit-time"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({
        "companyCode": companyCode,
        "date": date,
        "oldTime": oldTime,
        "newTime": newTime,
        "location": location,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["error"] ?? "Edit time failed");
    }
  }

  /* ===============================
     MANAGER: DELETE SLOT
  =============================== */
  static Future<void> managerDeleteSlot({
    required String companyCode,
    required String date,
    required String time,
    required String location,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/slots/delete"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({
        "companyCode": companyCode,
        "date": date,
        "time": time,
        "location": location,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)["error"] ?? "Delete slot failed");
    }
  }
}
