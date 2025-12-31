import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_api.dart';

class OrderApi {
  // ===============================
  // CREATE ORDER (DRAFT)
  // ===============================
  static Future<Map<String, dynamic>> createOrder({
    required String distributorId,
    required String distributorName,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/orders/create"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({
        "distributorId": distributorId,
        "distributorName": distributorName,
        "items": items,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Order create failed");
    }
    return data;
  }

  // ===============================
  // CONFIRM DRAFT (FINAL ORDER PLACED)
  // ===============================
  static Future<void> confirmDraftOrder(String orderId) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/orders/confirm-draft/$orderId"),
      headers: AuthApi.authHeaders(),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Draft confirm failed");
    }
  }

  // ===============================
  // GET MY DRAFT ORDERS (FILTERED)
  // ===============================
  static Future<List<Map<String, dynamic>>> getMyDraftOrders() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/orders/my"),
      headers: AuthApi.authHeaders(),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Fetch draft orders failed");
    }

    final allOrders = List<Map<String, dynamic>>.from(data["orders"] ?? []);

    // 🔑 ONLY DRAFT
    return allOrders.where((o) => o["status"] == "DRAFT").toList();
  }

  // ===============================
  // GET MY ORDERS (PLACED / PENDING)
  // ===============================
  static Future<List<Map<String, dynamic>>> getMyPlacedOrders() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/orders/my"),
      headers: AuthApi.authHeaders(),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Fetch confirm orders failed");
    }

    final allOrders = List<Map<String, dynamic>>.from(data["orders"] ?? []);

    // 🔑 ONLY PENDING
    return allOrders.where((o) => o["status"] == "PENDING").toList();
  }

  // ===============================
  // 🔹 ALIAS (FOR SCREENS EXPECTING getMyOrders)
  // NO DELETE, JUST DELEGATE
  // ===============================
  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    return getMyPlacedOrders();
  }

  // ===============================
  // 🔹 GET ALL ORDERS (MANAGER / MASTER)
  // ===============================
  // static Future<List<Map<String, dynamic>>> getAllOrders(String orderId) async {
  //   final res = await http.get(
  //     Uri.parse("${ApiConfig.baseUrl}/orders/$orderId"),
  //     headers: AuthApi.authHeaders(),
  //   );

  //   final data = jsonDecode(res.body);
  //   if (res.statusCode != 200) {
  //     throw Exception(data["message"] ?? "Fetch all orders failed");
  //   }

  //   return List<Map<String, dynamic>>.from(data["orders"] ?? []);
  // }

  // ===============================
  // GET ORDER BY ID
  // ===============================
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/orders/$orderId"),
      headers: AuthApi.authHeaders(),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Failed to fetch order");
    }

    // backend response: { order: {...} }
    return Map<String, dynamic>.from(data["order"]);
  }

  // ===============================
  // UPDATE DRAFT ORDER
  // ===============================
  static Future<void> updateDraftOrder({
    required String orderId,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await http.patch(
      Uri.parse("${ApiConfig.baseUrl}orders/update/$orderId"),
      headers: AuthApi.authHeaders(),
      body: jsonEncode({"items": items}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Update draft failed");
    }
  }

  //===============================
  // GET PENDING ORDERS (MANAGER / MASTER)
  // ===============================
  static Future<List<Map<String, dynamic>>> getAllPendingOrders() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/orders/pending"),
      headers: AuthApi.authHeaders(),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Failed to fetch pending orders");
    }

    final List orders = data["orders"] ?? [];

    return List<Map<String, dynamic>>.from(orders);
  }
}
