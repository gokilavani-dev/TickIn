import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_api.dart';

class GoalsApi {
  static Future<Map<String, dynamic>> getMonthlyGoalsRemaining({
    required String distributorCode,
  }) async {
    final res = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/goals/monthly?distributorCode=$distributorCode",
      ),
      headers: AuthApi.authHeaders(),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Failed to fetch monthly goals");
    }

    final Map<String, dynamic> goalsMap = {};
    final List goals = data["goals"] ?? [];

    for (final g in goals) {
      if (g is Map<String, dynamic>) {
        final productId = g["productId"]?.toString();

        final remainingQty = g["remainingQty"];

        if (productId != null && remainingQty != null) {
          goalsMap[productId] = remainingQty is int
              ? remainingQty
              : int.tryParse(remainingQty.toString()) ?? 0;
        }
      }
    }

    // 🔍 DEBUG (remove later)
    debugPrint("GOALS MAP => $goalsMap");

    return goalsMap;
  }
}
