import 'package:flutter/material.dart';
import '../models/owner.dart';
import '../services/api_service.dart';

class OwnerProvider with ChangeNotifier {
  Owner? _owner;
  bool _isLoading = false;
  String? _error;

  Owner? get owner => _owner;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> fetchOwner({int? immobileId}) async {
    _isLoading = true;
    _error = null;

    // 🔄 Notifica após o build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      if (immobileId != null) {
        _owner = await _apiService.fetchOwnerByImmobile(immobileId);
      } else {
        _owner = await _apiService.fetchCurrentOwner();
      }
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
