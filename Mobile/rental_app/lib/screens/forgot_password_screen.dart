import 'package:flutter/material.dart';
import '../services/api_service_users.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum ForgotPasswordFlowState {
  emailInput,
  codeAndNewPasswordInput,
  loading,
  success,
  error,
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ForgotPasswordFlowState _currentState = ForgotPasswordFlowState.emailInput;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final ApiService _apiService = ApiService(baseUrl: 'https://moovin.onrender.com/api');
  String? _errorMessage;

  Future<void> _sendCode() async {
    setState(() {
      _currentState = ForgotPasswordFlowState.loading;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();

    try {
      final response = await _apiService.requestEmailVerification(email);

      if (response['status'] == 'success') {
        setState(() {
          _currentState = ForgotPasswordFlowState.codeAndNewPasswordInput;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código enviado para seu e-mail!')),
        );
      } else {
        throw Exception('Não foi possível enviar o código.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Algo deu errado. Tente novamente.';
        _currentState = ForgotPasswordFlowState.emailInput;
      });
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _currentState = ForgotPasswordFlowState.loading;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'As senhas não coincidem.';
        _currentState = ForgotPasswordFlowState.codeAndNewPasswordInput;
      });
      return;
    }

    try {
      final isCodeValid = await _apiService.verifyEmailCode(email, code);

      if (!isCodeValid) {
        throw Exception('Código inválido ou expirado.');
      }

      final resetSuccess = await _apiService.resetPassword(email, newPassword);

      if (resetSuccess) {
        setState(() {
          _currentState = ForgotPasswordFlowState.success;
        });
      } else {
        throw Exception('Não foi possível redefinir a senha.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Algo deu errado. Tente novamente.';
        _currentState = ForgotPasswordFlowState.codeAndNewPasswordInput;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esqueci a Senha'),
        backgroundColor: Color(0xFF2F6D3C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case ForgotPasswordFlowState.emailInput:
        return _buildEmailInput();
      case ForgotPasswordFlowState.codeAndNewPasswordInput:
        return _buildCodeAndPasswordInput();
      case ForgotPasswordFlowState.loading:
        return const Center(child: CircularProgressIndicator());
      case ForgotPasswordFlowState.success:
        return _buildSuccess();
      case ForgotPasswordFlowState.error:
        return _buildError();
    }
  }

  Widget _buildEmailInput() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
                    'Digite o seu E-mail',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F6D3C)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFD7F0D5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sendCode,
            style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6D3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
            ),
            child: const Text('Enviar Código', style: TextStyle(fontSize: 20, color: Colors.white),),
          ),
        ],
      );

  Widget _buildCodeAndPasswordInput() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Código enviado por e-mail',
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2F6D3C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2F6D3C), width: 2.0),
                ),
            ),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _newPasswordController,
            decoration: const InputDecoration(
              labelText: 'Nova Senha',
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2F6D3C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2F6D3C), width: 2.0),
                ),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(
              labelText: 'Confirmar Nova Senha',
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2F6D3C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2F6D3C), width: 2.0),
                ),
            ),
            obscureText: true,
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetPassword,
            style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6D3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
            ),
            child: const Text('Redefinir Senha',style: TextStyle(fontSize: 20, color: Colors.white),),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentState = ForgotPasswordFlowState.emailInput;
                _errorMessage = null;
              });
            },
            child: const Text('Reenviar código ou mudar e-mail'),
          ),
        ],
      );

  Widget _buildSuccess() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Senha redefinida com sucesso!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Voltar para o Login'),
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Text(
          _errorMessage ?? 'Erro inesperado',
          style: const TextStyle(color: Colors.red),
        ),
      );

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
