import 'package:flutter/material.dart';
import '../models/owner.dart';
import '../models/immobile.dart';
import '../services/api_service.dart';

class ImmobileProvider with ChangeNotifier {
  Immobile? _immobile;
  bool _isLoading = false;
  String? _error;

  Immobile? get immobile => _immobile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> fetchImmobile(int id) async {
  _isLoading = true;
  _error = null;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifyListeners(); // <-- evitar rebuild imediato
  });

  try {
    print('Buscando imóvel com id $id');
    _immobile = await _apiService.fetchOneImmobile(id);
    print('Imóvel recebido: $_immobile');

    if (_immobile?.photosBlob != null) {
      print('Fotos encontradas: ${_immobile!.photosBlob.length}');

      for (final photo in _immobile!.photosBlob) {
        print('Buscando imagem para photoId: ${photo.photoId}');
        final imageData = await _apiService.fetchImageBlob(photo.photoId);
        photo.imageBase64 = imageData.imageBase64;
        photo.contentType = imageData.contentType;
      }
    } else {
      print('Nenhuma foto foi encontrada.');
    }
  } catch (e, stackTrace) {
    print('Erro ao buscar imóvel ou imagens: $e');
    print('StackTrace: $stackTrace');
    _error = e.toString();
  } finally {
    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners(); // <-- também aqui
    });
  }
}

}