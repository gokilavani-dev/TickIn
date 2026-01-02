import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_api.dart';

class DriverApi {
  /// ✅ GET assigned orders
  static Future<List<Map<String, dynamic>>> getOrders() async {
    final driverId = AuthApi.user!["mobile"];

    final res = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/api/driver/$driverId/orders", // ✅ FIX
      ),
      headers: AuthApi.authHeaders(),
    );

    debugPrint("DRIVER ORDERS STATUS: ${res.statusCode}");
    debugPrint("DRIVER ORDERS BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to load driver orders");
    }

    final data = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(data["data"] ?? []);
  }

  /// ✅ UPDATE driver status
  static Future<void> updateStatus(String orderId, String status) async {
    final res = await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/api/driver/order/$orderId/status", // ✅ FIX
      ),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({ "status": status }),
    );

    debugPrint("DRIVER STATUS UPDATE: $status");
    debugPrint("STATUS API CODE: ${res.statusCode}");
    debugPrint("STATUS API BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to update driver status");
    }
  }
}
