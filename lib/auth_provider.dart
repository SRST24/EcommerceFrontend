import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  String? role;
  int? companyId;
  int? userId;

  Future<void> login(String email, String password) async {
    final data = await Api.login(email, password);
    token = data['token'] as String?;
    role = data['role'] as String?;
    companyId = (data['companyId'] as num?)?.toInt();
    userId = (data['userId'] as num?)?.toInt();

    final prefs = await SharedPreferences.getInstance();
    if (token != null && token!.isNotEmpty) {
      await prefs.setString('token', token!);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token = null;
    role = null;
    companyId = null;
    userId = null;
    notifyListeners();
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;
  bool get isClient => role == 'Cliente';
  bool get isCompany => role == 'Empresa';
  bool get isAdmin => role == 'Admin';
}
