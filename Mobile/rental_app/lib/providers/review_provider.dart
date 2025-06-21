import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  // Fetch reviews for a specific target (e.g., a property or a tenant)
  Future<void> fetchReviews({required String type, required int targetId}) async {
    if (!_isLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners(); // notifica mudança de estado inicial
    }

    try {
      final fetchedReviews = await _apiService.fetchReviews(type: type, targetId: targetId);
      _reviews = fetchedReviews;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // notifica após finalização
    }
  }

  // Fetch details of the review target (optional)
  Future<Map<String, dynamic>> fetchTargetDetails({required String type, required int id}) async {
    return await _apiService.fetchTargetDetails(type: type, id: id);
  }

  // Submit a new review
  Future<void> submitReview({
    required int rating,
    String? comment,
    required String type,
    required int targetId,
    required int authorId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
      notifyListeners();
    }
  }
}
