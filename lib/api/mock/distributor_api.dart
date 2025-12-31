// lib/api/mock/distributor_api.dart
import 'mock_db.dart';

class MockDistributorApi {
  static Future<List> getDistributors() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return MockDb.distributors;
  }
}
