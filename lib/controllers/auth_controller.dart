import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController._internal();

  static final AuthController instance = AuthController._internal();

  final AuthService _service = AuthService();

 UserModel? get currentUser => _service.currentUser;
bool get isLoggedIn => _service.isLoggedIn;
String? get token => _service.token;
int? get userId => _service.userId;

  String? errorMessage;
  bool isLoading = false;

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required ExplorerType explorerType,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.registerLocally(
        fullName: fullName,
        email: email,
        password: password,
        explorerType: explorerType,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } on ArgumentError catch (e) {
      isLoading = false;
      errorMessage = e.message.toString();
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.loginLocally(
        email: email,
        password: password,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } on ArgumentError catch (e) {
      isLoading = false;
      errorMessage = e.message.toString();
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _service.logout();
    errorMessage = null;
    notifyListeners();
  }
}