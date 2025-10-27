import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static const String baseUrl = 'http://localhost:5222';

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers() async {
    final t = await _token();
    return {
      'Content-Type': 'application/json',
      if (t != null && t.isNotEmpty) 'Authorization': 'Bearer $t',
    };
  }

  static Future<http.Response> _get(String path) async =>
      http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
  static Future<http.Response> _post(String path, {Object? body}) async =>
      http.post(Uri.parse('$baseUrl$path'), headers: await _headers(), body: body==null?null:jsonEncode(body));
  static Future<http.Response> _put(String path, {Object? body}) async =>
      http.put(Uri.parse('$baseUrl$path'), headers: await _headers(), body: body==null?null:jsonEncode(body));
  static Future<http.Response> _delete(String path) async =>
      http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());

  // --- AUTH ---
  static Future<void> register(String email, String password) async {
    final r = await _post('/auth/register', body: {'Email': email, 'Password': password});
    if (r.statusCode >= 400) throw Exception(_err(r));
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final r = await _post('/auth/login', body: {'Email': email, 'Password': password});
    if (r.statusCode != 200) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> me() async {
    final r = await _get('/auth/me');
    if (r.statusCode != 200) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  // --- PRODUCTS ---
  static Future<List<dynamic>> products({int? companyId}) async {
    final q = companyId == null ? '' : '?companyId=$companyId';
    final r = await _get('/products$q');
    if (r.statusCode != 200) throw Exception(_err(r));
    return jsonDecode(r.body) as List<dynamic>;
  }
  static Future<Map<String, dynamic>> getProduct(int id) async {
    final r = await _get('/products/$id');
    if (r.statusCode != 200) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
  static Future<Map<String, dynamic>> createProduct({required String name, String? description, required double price, required int stock}) async {
    final r = await _post('/products', body: {'Name': name, 'Description': description, 'Price': price, 'Stock': stock});
    if (r.statusCode >= 400) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
  static Future<void> updateProduct(int id, {required String name, String? description, required double price, required int stock}) async {
    final r = await _put('/products/$id', body: {'Name': name, 'Description': description, 'Price': price, 'Stock': stock});
    if (r.statusCode >= 400) throw Exception(_err(r));
  }
  static Future<void> deleteProduct(int id) async {
    final r = await _delete('/products/$id');
    if (r.statusCode >= 400) throw Exception(_err(r));
  }

  // --- CART / ORDERS ---
  static Future<Map<String, dynamic>> getCart() async {
    final r = await _get('/orders/cart');
    if (r.statusCode != 200) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
  static Future<Map<String, dynamic>> addToCart(int productId, int quantity) async {
    final r = await _post('/orders/cart/items', body: {'ProductId': productId, 'Quantity': quantity});
    if (r.statusCode >= 400) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
  static Future<void> removeCartItem(int itemId) async {
    final r = await _delete('/orders/cart/items/$itemId');
    if (r.statusCode >= 400) throw Exception(_err(r));
  }
  static Future<Map<String, dynamic>> checkout() async {
    final r = await _post('/orders/cart/checkout');
    if (r.statusCode != 200) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  // --- ADMIN / COMPANIES ---
  static Future<List<dynamic>> companies() async {
    final r = await _get('/companies');
    if (r.statusCode != 200) throw Exception(_err(r));
    return jsonDecode(r.body) as List<dynamic>;
  }
  static Future<Map<String, dynamic>> getCompany(int id) async {
    final r = await _get('/companies/$id');
    if (r.statusCode != 200) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
  static Future<Map<String, dynamic>> createCompany(String name) async {
    final r = await _post('/companies', body: {'Name': name});
    if (r.statusCode >= 400) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
  static Future<void> updateCompany(int id, String name) async {
    final r = await _put('/companies/$id', body: {'Name': name});
    if (r.statusCode >= 400) throw Exception(_err(r));
  }
  static Future<void> deleteCompany(int id) async {
    final r = await _delete('/companies/$id');
    if (r.statusCode >= 400) throw Exception(_err(r));
  }
  static Future<Map<String, dynamic>> createCompanyUser(int companyId, String email, String password) async {
    final r = await _post('/companies/%d/users'.replaceFirst('%d', companyId.toString()), body: {'Email': email, 'Password': password});
    if (r.statusCode >= 400) throw Exception(_err(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  static String _err(http.Response r) {
    try { final j = jsonDecode(r.body); return j is Map && j['message']!=null ? j['message'].toString() : r.body; }
    catch (_) { return 'HTTP ${r.statusCode}: ${r.reasonPhrase}'; }
  }
}
