import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_api.dart';

class ProductApi {
  static Future<List<Map<String, dynamic>>> getProducts() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/products"),
      headers: AuthApi.authHeaders(), // ✅ TOKEN
    );

    debugPrint("PRODUCT API STATUS: ${res.statusCode}");
    debugPrint("PRODUCT API BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to load products");
    }

    final data = jsonDecode(res.body);

    // ✅ SAFE CAST (NO DELETE)
    return List<Map<String, dynamic>>.from(data["products"] ?? []);
  }
}
