import 'dart:convert';
import '../services/api_service_users.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 180,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cadastro',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F6D3C),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nome',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o e-mail';
                    }
                    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a senha';
                    }
                    if (value.length < 6) {
                      return 'A senha precisa ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar Senha',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme a senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                _buildSubmitButton(
                  text: 'Cadastrar-se como inquilino',
                  onPressed: () async {
                    await _handleRegistration(isOwner: false);
                  },
                ),

                const SizedBox(height: 16),

                _buildSubmitButton(
                  text: 'Cadastrar-se como proprietário',
                  outlined: true,
                  onPressed: () async {
                    await _handleRegistration(isOwner: true);
                  },
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem cadastro? ',
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF6D472F),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
/*Future<void> _handleRegistration({required bool isOwner}) async {
    if (_formKey.currentState?.validate() ?? false) {
      final userType = isOwner ? 'Proprietario' : 'Inquilino';

      final userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'username': _emailController.text,
        'password': _passwordController.text,
        'user_type': userType,
      };

      final apiService = ApiService(baseUrl: 'http://127.0.0.1:8000/api'); //url de emulador

      try {
        final response = await apiService.registerUser(userData);
        final responseData = response;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamed(
          context,
          '/create-profile',
          arguments: {
            'userId': responseData['id'].toString(),
            'name': responseData['name'],
            'email': responseData['email'],
            'isOwner': isOwner,
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no cadastro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }*/
 Future<void> _handleRegistration({required bool isOwner}) async {
    if (_formKey.currentState?.validate() ?? false) {
      final String email = _emailController.text;
      final apiService = ApiService(baseUrl: 'http://127.0.0.1:8000/api'); //URL emulador

      try {
        final response = await apiService.requestEmailVerification(email);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Um código de verificação foi enviado para o seu e-mail.'),
              backgroundColor: Colors.blue,
            ),
          );
          print('Email sendo passado para VerifyEmailScreen: ${_emailController.text}');
          Navigator.pushNamed(
            context,
            '/verify-email', // Nova rota para a tela de verificação
            arguments: {
              'id': response['id'].toString(),
              'name': _nameController.text,
              'email': _emailController.text,
              'password': _passwordController.text,
              'isOwner': isOwner,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao solicitar verificação: ${response['message'] ?? 'Tente novamente.'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro de conexão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F6D3C),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFD7F0D5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required void Function() onPressed,
    bool outlined = false,
  }) {
    return SizedBox(
      width: 320,
      height: 50,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: const BorderSide(color: Color(0xFF2F6D3C), width: 2),
              ),
              child: Text(
                text,
                style: const TextStyle(
                    color: Color(0xFF2F6D3C), fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6D3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
    );
  }
}
