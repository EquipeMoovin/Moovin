import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false; // <- Adiciona essa flag

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _disposed = true; // <- marca como descartado
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchReviews({required String type, required int targetId}) async {
    if (!_isLoading) {
      _isLoading = true;
      _error = null;
      safeNotify(); // <- usa safeNotify
    }

    try {
      final fetchedReviews = await _apiService.fetchReviews(type: type, targetId: targetId);
      _reviews = fetchedReviews;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotify(); // <- usa safeNotify
    }
  }

  Future<Map<String, dynamic>> fetchTargetDetails({required String type, required int id}) async {
    return await _apiService.fetchTargetDetails(type: type, id: id);
  }

  Future<void> submitReview({
    required int rating,
    String? comment,
    required String type,
    required int targetId,
    required int authorId,
  }) async {
    _isLoading = true;
    _error = null;
    safeNotify();

    try {
      final newReview = await _apiService.submitReview(
        rating: rating,
        comment: comment,
        type: type,
        targetId: targetId,
      );
      _reviews.add(newReview);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }
}
