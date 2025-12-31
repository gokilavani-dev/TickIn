import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_api.dart';

class TimelineApi {
  // ===============================
  // GET ORDER TIMELINE
  // ===============================
  static Future<List<Map<String, dynamic>>> getTimeline(String orderId) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/timeline/$orderId"),
      headers: AuthApi.authHeaders(),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Timeline fetch failed");
    }

    return List<Map<String, dynamic>>.from(data["timeline"] ?? data);
  }

  // ===============================
  // LOADING START
  // POST /timeline/loading-start
  // ===============================
  static Future<void> loadingStart(String orderId) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/timeline/loading-start"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({"orderId": orderId}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Loading start failed");
    }
  }

  // ===============================
  // LOADING ITEM (ONE BY ONE)
  // POST /timeline/loading-item
  // ===============================
  static Future<void> loadingItem({
    required String orderId,
    required String productId,
    required int qty,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/timeline/loading-item"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({
        "orderId": orderId,
        "productId": productId,
        "qty": qty,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Loading item failed");
    }
  }

  // ===============================
  // LOADING END
  // POST /timeline/loading-end
  // ===============================
  static Future<void> loadingEnd(String orderId) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/timeline/loading-end"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({"orderId": orderId}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Loading end failed");
    }
  }

  // ===============================
  // ASSIGN DRIVER
  // POST /timeline/assign-driver
  // ===============================
  static Future<void> assignDriver({
    required String orderId,
    required String driverId,
    required String vehicleNo,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/timeline/assign-driver"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({
        "orderId": orderId,
        "driverId": driverId,
        "vehicleNo": vehicleNo,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Assign driver failed");
    }
  }

  // ===============================
  // DRIVER ARRIVED
  // POST /timeline/arrived
  // ===============================
  static Future<void> arrived(String orderId) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/timeline/arrived"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({"orderId": orderId}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Arrived update failed");
    }
  }

  // ===============================
  // UNLOAD START
  // POST /timeline/unload-start
  // ===============================
  static Future<void> unloadStart(String orderId) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/timeline/unload-start"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({"orderId": orderId}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Unload start failed");
    }
  }

  // ===============================
  // UNLOAD END
  // POST /timeline/unload-end
  // ===============================
  static Future<void> unloadEnd(String orderId) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/timeline/unload-end"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({"orderId": orderId}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Unload end failed");
    }
  }
}
