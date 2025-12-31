import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthApi {
  static String? token;
  static Map<String, dynamic>? user;

  Future<void> login(String mobile, String password) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"mobile": mobile, "password": password}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      // ✅ backend real message return
      throw Exception(data["message"] ?? "Login failed");
    }

    token = data["token"];
    user = data["user"];
    debugPrint("STATUS => ${res.statusCode}");
    debugPrint("BODY => ${res.body}");
  }

  // ✅ ADD THIS METHOD
  static Map<String, String> authHeaders() {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${AuthApi.token}",
    };
  }
}
