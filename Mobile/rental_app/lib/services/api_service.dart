import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tenant.dart';
import '../models/owner.dart';
import '../config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/immobile.dart';
import 'package:dio/dio.dart';
import '../models/review.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ApiService {
  final String _tenantBase = '$apiBase/tenants';
  final String _ownerBase = '$apiBase/owners/owners';
  final String _immobileBase = '$apiBase/immobile';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _photoBlobBase = '$apiBase/photo/blob'; 
  late Dio dio;
  final String _chatBase = '$apiBase/chat/conversations';
  final String _chatBaseMessage = '$apiBase/chat';
  final String _reviewBase = '$apiBase/reviews';

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://moovin.onrender.com/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await _secureStorage.read(key: 'access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshed = await _refreshToken();

          if (refreshed) {
            final newToken = await _secureStorage.read(key: 'access_token');
            e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

            try {
              final retryResponse = await dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (e) {
              return handler.reject(e as DioException);
            }
          }
        }

        return handler.next(e);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    final refresh = await _secureStorage.read(key: 'refresh_token');
    if (refresh == null) return false;

    try {
      final response = await dio.post('/users/token/refresh', data: {'refresh': refresh});
      if (response.statusCode == 200) {
        await _secureStorage.write(key: 'access_token', value: response.data['access']);
        return true;
      }
    } catch (e) {
      print('Erro ao renovar token: $e');
    }

    return false;
  }

  // ========================= TENANT =========================

  Future<Tenant> fetchTenant() async {
  final url = '$_tenantBase/profile/me/'; 

  print('🔎 Fetching Tenant: $url');

  try {
    final response = await dio.get(url); // token será adicionado pelo interceptor

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    if (response.statusCode == 200) {
      return Tenant.fromJson(response.data); // Já vem decodificado em JSON
    } else {
      throw Exception('Erro ao carregar perfil do tenant');
    }
  } on DioException catch (e) {
    print('❌ Erro na requisição: ${e.response?.data}');
    throw Exception('Erro na requisição: ${e.message}');
  }
  }


  Future<Tenant> updateTenant(Map<String, dynamic> data) async {
  final url = '$_tenantBase/profile/me/update-profile/';
  print('✏️ Updating Tenant: $url');

  try {
    final response = await dio.patch(
      url,
      data: data, 
    );

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    if (response.statusCode == 200) {
      return Tenant.fromJson(response.data); 
    } else {
      throw Exception('Erro ao atualizar o perfil do tenant');
    }
  } on DioException catch (e) {
    print('❌ Erro na requisição: ${e.response?.data}');
    throw Exception('Erro na requisição: ${e.message}');
  }
}


  Future<void> favoriteProperty(int tenantId) async {
  final url = '$_tenantBase/profile/$tenantId/favorite_property/';
  print('⭐ Favoriting property for Tenant: $url');

  try {
    final response = await dio.post(url); 

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao favoritar o imóvel');
    }
  } on DioException catch (e) {
    print('❌ Erro na requisição: ${e.response?.data}');
    throw Exception('Erro ao favoritar o imóvel: ${e.message}');
  }
}


  // ========================= OWNER =========================

  Future<Owner> fetchCurrentOwner() async {
    final url ='$_ownerBase/me/';
    print('🔎 Fetching Owner (self): $url');

    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await dio.get(url);

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    if (response.statusCode == 200) {
      return Owner.fromJson(response.data);
    } else {
      throw Exception('Failed to load owner profile');
    }
  }
  Future<Owner> fetchOwnerByImmobile(int immobileId) async {
  final url = '$_ownerBase/$immobileId/getbyimmobile';
  print('🔎 Fetching Owner (self): $url');

  final token = await _secureStorage.read(key: 'access_token');

  if (token == null) {
    throw Exception('Token JWT não encontrado.');
  }

  try {
    final response = await dio.get(
      url,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    if (response.statusCode == 200) {
      return Owner.fromJson(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Proprietário não encontrado para este imóvel.');
    } else {
      throw Exception('Erro ao carregar perfil do proprietário. Código: ${response.statusCode}');
    }

  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw Exception('Tempo de conexão esgotado. Tente novamente.');
    } else if (e.type == DioExceptionType.badResponse) {
      throw Exception('Erro de resposta do servidor: ${e.response?.statusCode}');
    } else if (e.type == DioExceptionType.connectionError) {
      throw Exception('Erro de conexão. Verifique sua internet.');
    } else {
      throw Exception('Erro inesperado: ${e.message}');
    }
  } catch (e) {
    throw Exception('Erro ao buscar proprietário: $e');
  }
}




  Future<Owner> updateCurrentOwner(Map<String, dynamic> data) async {
    // final token = await _secureStorage.read(key: 'access_token');
    // if (token == null) throw Exception('Token JWT não encontrado.');

    final response = await dio.patch(
      '$_ownerBase/me/update-profile/',
      data: data,
    );

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    if (response.statusCode == 200) {
      return Owner.fromJson(response.data);
    } else {
      throw Exception('Erro ao atualizar dados do proprietário');
    }
  }


  // ========================= IMMOBILE =========================
 Future<Immobile> fetchOneImmobile(int idImmobile) async {
  final url = '$_immobileBase/$idImmobile/';
  print('🔎 Fetching Immobile: $url');

  try {
    final response = await dio.get(url);

    print('📡 STATUS: ${response.statusCode}');
    print('📦 IMMOBILE BODY: ${response.data}');

    if (response.statusCode == 200) {
      return Immobile.fromJson(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Imóvel não encontrado');
    } else {
      throw Exception('Erro ao carregar os detalhes do imóvel');
    }
  } on DioException catch (e) {
    print('❌ Erro na requisição: ${e.response?.data}');
    throw Exception('Erro na requisição: ${e.message}');
  }
}


Future<ImmobilePhoto> fetchImageBlob(int photoId) async {
  final url = '$_photoBlobBase/$photoId/';
  print('🔎 Fetching Image Blob: $url');

  try {
    final response = await dio.get(url);

    print('📡 STATUS: ${response.statusCode}');
    print('📦 IMAGE BLOB BODY: ${response.data}');

    if (response.statusCode == 200) {
      return ImmobilePhoto.fromJson(response.data);
    } else if (response.statusCode == 404) {
      throw Exception('Foto não encontrada');
    } else {
      throw Exception('Erro ao carregar blob da imagem com ID $photoId');
    }
  } on DioException catch (e) {
    print('❌ Erro na requisição: ${e.response?.data}');
    throw Exception('Erro na requisição: ${e.message}');
  }
}



  Future<Immobile> updateImmobile(Map<String, dynamic> data) async {
  final token = await _secureStorage.read(key: 'access_token');
  if (token == null) throw Exception('Token JWT não encontrado.');

  try {
    final response = await dio.patch(
      '$_ownerBase/me/update-profile/',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',  // ✅ Enviando token no header
        },
      ),
    );

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      throw Exception('Falha ao atualizar imóvel. Código: ${response.statusCode}');
    }

    // ✅ Aqui você precisa converter response.data em Immobile.
    // Supondo que exista Immobile.fromJson:
    return Immobile.fromJson(response.data);
    
  } on DioException catch (e) {
    print('❌ Erro ao atualizar imóvel: ${e.response?.data}');
    throw Exception('Erro na requisição: ${e.message}');
  }
}


Future<List<Immobile>> fetchImmobile({
  String? type,
  int? bedrooms,
  int? bathrooms,
  int? garage,
  int? rentValue,
  int? areaSize,
  int? distance,
  DateTime? date,
  bool? wifi,
  bool? airConditioning,
  bool? petFriendly,
  bool? furnished,
  bool? pool,
  String? city,
}) async {
  final queryParams = <String, dynamic>{
    if (type != null) 'type': type,
    if (bedrooms != null) 'bedrooms': bedrooms.toString(),
    if (bathrooms != null) 'bathrooms': bathrooms.toString(),
    if (garage != null) 'garage': garage.toString(),
    if (rentValue != null) 'rentValue': rentValue.toString(),
    if (areaSize != null) 'areaSize': areaSize.toString(),
    if (distance != null) 'distance': distance.toString(),
    if (date != null) 'date': date.toIso8601String(),
    if (wifi != null) 'wifi': wifi.toString(),
    if (airConditioning != null) 'airConditioning': airConditioning.toString(),
    if (petFriendly != null) 'petFriendly': petFriendly.toString(),
    if (furnished != null) 'furnished': furnished.toString(),
    if (pool != null) 'pool': pool.toString(),
    if (city != null) 'city': city,
  };

  final uri = Uri.parse(_immobileBase).replace(queryParameters: queryParams);
  print('🔎 Fetching Immobiles: $uri');

 
    final response = await dio.getUri(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((item) => Immobile.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar imóveis');
  }}
//====== reviews
Future<List<Review>> fetchReviews({required String type, required int targetId}) async {
  final url = '$_reviewBase/reviews/by_object/?type=${type.toLowerCase()}&id=$targetId';
  print('🔎 Fetching Reviews for target (type: $type, id: $targetId): $url');

  final token = await _secureStorage.read(key: 'access_token');
  if (token == null) {
    throw Exception('Token JWT não encontrado para buscar as avaliações.');
  }

  try {
    final response = await dio.get(
      url,
    );

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    final List<dynamic> jsonList = response.data;
    return jsonList.map((json) => Review.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    print('Erro ao buscar avaliações: $e');
    throw Exception('Failed to load reviews');
  }
}

Future<Review> submitReview({
  required int rating,
  String? comment,
  required String type,
  required int targetId,
}) async {
  final url = '$_reviewBase/reviews/';
  print('📝 Submitting Review: $url');

  

  final body = {
    'rating': rating,
    'comment': comment,
    'type': type,
    'object_id': targetId,
  };

  print('📤 Sending Body: $body');

  try {
    final response = await dio.post(
      url,
      data: body,
    );

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    return Review.fromJson(response.data);
  } catch (e) {
    print('Erro ao enviar avaliação: $e');
    throw Exception('Failed to submit review');
  }
}

Future<Map<String, dynamic>> fetchTargetDetails({required String type, required int id}) async {
  String? url;

  if (type == 'TENANT') {
    url = '$apiBase/tenants/$id/';
  } else if (type == 'OWNER') {
    url = '$apiBase/owners/$id/';
  } else if (type == 'PROPERTY') {
    url = '$apiBase/immobile/$id/';
  }

  if (url == null) {
    print('Tipo de objeto inválido para buscar detalhes.');
    return {};
  }

  print('🔎 Fetching Target Details: $url');

  try {
    final response = await dio.get(url);

    print('📡 STATUS: ${response.statusCode}');
    print('📦 BODY: ${response.data}');

    if (response.statusCode == 200) {
      if (response.data is List && response.data.isNotEmpty) {
        return response.data.first as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        print('Formato de resposta inesperado.');
        return {};
      }
    } else {
      print('Falha ao carregar os detalhes: ${response.statusCode}');
      return {};
    }
  } catch (e) {
    print('Erro de conexão: $e');
    return {};
  }
}

  // chat
  Future<List<Conversation>> fetchConversations() async {
    final url = Uri.parse('$_chatBase/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar conversas: ${response.body}');
    }
  }

  Future<Conversation> createConversation({
    required int tenantId,
    required int ownerId,
    required int immobileId,
  }) async {
    final url = Uri.parse('$_chatBase/create/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tenant_id': tenantId,
        'owner_id': ownerId,
        'immobile_id': immobileId,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Conversation.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Falha ao criar conversa: ${response.body}');
    }
  }

  Future<Message> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final url = Uri.parse('$_chatBaseMessage/messages/create/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'conversation_id': conversationId,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Message.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Falha ao enviar mensagem: ${response.body}');
    }
  }

  Future<void> markMessageAsRead(int messageId) async {
    final url = Uri.parse('$_chatBaseMessage/messages/$messageId/read/');
    final token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      throw Exception('Token JWT não encontrado.');
    }

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao marcar mensagem como lida: ${response.body}');
    }
  }
}
