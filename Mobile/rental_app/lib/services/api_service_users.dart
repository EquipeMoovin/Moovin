import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
//Tentativa de refatoracao do codigo para usar do arquivo config.dart, alguns parametros foram alterados
//a api permanece não funcionando, existe algum problema entre a camada do backend django e os modelos no flutter
//Possivelmente necessita da implementacao de uma segunda camada como tenant e owner para a integracao entre flutter e django
class ApiService {

  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? userBase;

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData)
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', userData['name']);
        await prefs.setString('email', userData['email']);
        await prefs.setString('password', userData['password']);
        await prefs.setString('userType', userData['user_type']);

        return data;
      } else {
        throw Exception('Falha ao registrar usuário: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de registro: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao fazer login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de login: $e');
    }
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$userId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao atualizar usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de atualização: $e');
    }
  }

//Função que puxa a instacia do usuário
  Future<Map<String, dynamic>> getUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao obter usuário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de obtenção: $e');
    }
  }
  //email-----
   Future<Map<String, dynamic>> requestEmailVerification(String email) async {// print removido por segurança
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/request-email-verification/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Falha ao solicitar verificação de e-mail: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de verificação de e-mail: $e');
    }
  }

  Future<bool> verifyEmailCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/verify-email-code/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        // Sucesso na verificação
        return true;
      } else {
        // Falha na verificação// print removido por segurança
        return false;
      }
    } catch (e) {// print removido por segurança
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users/password-reset/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email, 'new_password': newPassword}),
  );
  return response.statusCode == 200;
}



}
