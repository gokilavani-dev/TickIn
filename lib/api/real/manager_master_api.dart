import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_api.dart';
import 'api_config.dart';

class ManagerMasterApi {
  static Map<String, String> get _headers => AuthApi.authHeaders();

  // ===============================
  // GET PENDING ORDERS (MANAGER / MASTER)
  // ===============================
  static Future<List<Map<String, dynamic>>> getPendingOrders() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/orders/pending"),
      headers: _headers,
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Failed to fetch pending orders");
    }

    final List orders = data["orders"] ?? [];

    return List<Map<String, dynamic>>.from(orders);
  }

  // ===============================
  // GET TODAY ORDERS (MASTER)
  // ===============================
  static Future<List<Map<String, dynamic>>> getTodayOrders() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/orders/today"),
      headers: _headers,
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Failed to fetch today orders");
    }

    final List orders = data["orders"] ?? [];

    return List<Map<String, dynamic>>.from(orders);
  }

  // ===============================
  // GET ORDER BY ID
  // ===============================
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/orders/$orderId"),
      headers: _headers,
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Failed to fetch order");
    }

    return Map<String, dynamic>.from(data["order"]);
  }

  static Future<void> savePendingReason({
    required String orderId,
    required String reason,
  }) async {
    final res = await http.patch(
      Uri.parse("${ApiConfig.baseUrl}/orders/$orderId/reason"),
      headers: {
        "Authorization": _headers["Authorization"]!, // 🔥 ONLY auth
        "Content-Type": "application/json", // 🔥 FORCE JSON
      },
      body: jsonEncode({"reason": reason}),
    );

    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data["message"] ?? "Failed to save reason");
    }
  }
}
