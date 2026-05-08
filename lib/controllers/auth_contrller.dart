// lib/features/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:plannova/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );

    if (result != null) {
      _errorMessage = result;
      setLoading(false);
      return false;
    }

    setLoading(false);
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    setLoading(true);
    clearError();

    final result = await _authService.loginWithEmail(
      email: email,
      password: password,
    );

    if (result != null) {
      _errorMessage = result;
      setLoading(false);
      return false;
    }

    setLoading(false);
    return true;
  }
}