// lib/api/mock/product_api.dart
import 'mock_db.dart';

class MockProductApi {
  static Future<List> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return MockDb.products;
  }
}
