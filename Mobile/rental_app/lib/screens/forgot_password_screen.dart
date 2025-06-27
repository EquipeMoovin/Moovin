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

  final ApiService _apiService = ApiService(baseUrl: 'http://127.0.0.1:8000/api');
  String? _errorMessage;

  // Novo estado para controlar o carregamento do botão de reenviar código
  bool _isResendingCode = false;

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
          const SnackBar(
            content: Text('Código enviado para seu e-mail!'),
            backgroundColor: Colors.green, // Adicionado cor para feedback positivo
          ),
        );
      } else {
        // Se o backend retornar um status diferente de 'success' mas não lançar exceção
        throw Exception(response['message'] ?? 'Não foi possível enviar o código.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao enviar código: ${e.toString()}';
        _currentState = ForgotPasswordFlowState.emailInput;
      });
      ScaffoldMessenger.of(context).showSnackBar( // Adicionado SnackBar para feedback de erro
        SnackBar(
          content: Text('Erro: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Novo método para reenviar o código
  Future<void> _resendCode() async {
    setState(() {
      _isResendingCode = true; // Ativa o estado de carregamento do botão de reenviar
      _errorMessage = null; // Limpa qualquer mensagem de erro anterior
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, digite seu e-mail antes de reenviar o código.';
        _isResendingCode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _apiService.requestEmailVerification(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Novo código enviado para seu e-mail!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao reenviar o código. Tente novamente.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao reenviar código: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isResendingCode = false; // Desativa o estado de carregamento
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
      ScaffoldMessenger.of(context).showSnackBar( // Adicionado SnackBar para feedback de erro
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar( // Adicionado SnackBar para feedback positivo
          const SnackBar(
            content: Text('Senha redefinida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Não foi possível redefinir a senha.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: ${e.toString()}';
        _currentState = ForgotPasswordFlowState.codeAndNewPasswordInput;
      });
      ScaffoldMessenger.of(context).showSnackBar( // Adicionado SnackBar para feedback de erro
        SnackBar(
          content: Text('Erro: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esqueci a Senha'),
        backgroundColor: const Color(0xFF2F6D3C),
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
              fillColor: const Color(0xFFD7F0D5),
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
            onPressed: _currentState == ForgotPasswordFlowState.loading ? null : _sendCode, // Desabilita o botão se estiver carregando
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F6D3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _currentState == ForgotPasswordFlowState.loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Enviar Código', style: TextStyle(fontSize: 20, color: Colors.white)),
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
            onPressed: _currentState == ForgotPasswordFlowState.loading ? null : _resetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F6D3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _currentState == ForgotPasswordFlowState.loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Redefinir Senha', style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
          // Botão de reenviar código
          TextButton(
            onPressed: (_isResendingCode || _currentState == ForgotPasswordFlowState.loading) ? null : _resendCode,
            child: _isResendingCode
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F6D3C)),
                  )
                : const Text('Reenviar código', style: TextStyle(color: Color(0xFF2F6D3C), fontWeight: FontWeight.bold)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6D3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Voltar para o Login', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      );

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Erro inesperado',
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentState = ForgotPasswordFlowState.emailInput; // Volta para a tela inicial
                  _errorMessage = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F6D3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Tentar Novamente', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
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
