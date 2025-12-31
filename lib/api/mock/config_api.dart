class MockConfigApi {
  static Future<Map<String, dynamic>> getConfig() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      "fullTruckAmount": 90000, // 🔑 Manager modified value
    };
  }
}
