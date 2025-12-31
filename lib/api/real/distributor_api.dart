import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_api.dart';

class DistributorApi {
  // ===============================
  // GET DISTRIBUTORS FOR SALES
  // ===============================
  static Future<List<Map<String, dynamic>>> getDistributors() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/sales/home"),
      headers: AuthApi.authHeaders(),
    );

    // DEBUG
    debugPrint("DISTRIBUTOR API STATUS => ${res.statusCode}");
    debugPrint("DISTRIBUTOR API BODY => ${res.body}");

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Failed to fetch distributors");
    }

    // 🔥 BACKEND RETURNS: { ok, distributors: [...] }
    final List list = data["distributors"] ?? [];

    // SAFETY MAP CONVERSION
    return list.map<Map<String, dynamic>>((d) {
      return {
        "distributorCode": d["distributorId"] ?? d["distributorCode"] ?? "",
        "distributorName": d["distributorName"] ?? "",
        "area": d["area"] ?? "",
        "phoneNumber": d["phoneNumber"] ?? "",
        "location": d["location"] ?? "",
      };
    }).toList();
  }
}
