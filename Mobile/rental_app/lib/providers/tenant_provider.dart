import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../services/api_service.dart';

class TenantProvider with ChangeNotifier {
  Tenant? _tenant;
  bool _isLoading = false;
  String? _error;

  Tenant? get tenant => _tenant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> fetchTenant() async {
    _isLoading = true;
    _error = null;

    // 🚨 Evita notificações durante o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _tenant = await _apiService.fetchTenant();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
