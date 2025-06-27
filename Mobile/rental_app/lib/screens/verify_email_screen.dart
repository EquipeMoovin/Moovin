import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service_users.dart'; 

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _verificationCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService(baseUrl: 'http://127.0.0.1:8000/api');

  // Variável para controlar o estado de carregamento do botão de reenviar
  bool _isResendingCode = false;

  @override
  void initState() {
    super.initState();
    // Você pode adicionar aqui uma lógica para iniciar um temporizador
    // ou desabilitar o botão de reenviar por alguns segundos após a tela carregar.
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final code = _verificationCodeController.text;
    // Usar widget.arguments para acessar os argumentos passados para a tela
    final arguments = widget.arguments ?? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'];
    final name = arguments?['name'];
    final password = arguments?['password'];
    final isOwner = arguments?['isOwner'];

    print('Email para verificação: $email');
    print('Código digitado: $code');

    if (email != null && code.isNotEmpty) {
      final isCodeValid = await _apiService.verifyEmailCode(email, code);
      print('Resultado da verificação da API: $isCodeValid');
      setState(() {
        _isLoading = false;
      });

      if (isCodeValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verificado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Registrar o usuário AQUI
        final userData = {
          'name': name,
          'email': email,
          'username': email, // Assumindo que o username é o mesmo que o email
          'password': password,
          'user_type': isOwner == true ? 'Proprietario' : 'Inquilino',
        };

        try {
          final registerResponse = await _apiService.registerUser(userData);
          final responseData = registerResponse;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadastro realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navegar para a tela de criação de perfil
          Navigator.pushReplacementNamed(
            context,
            '/create-profile',
            arguments: {
              'userId': responseData['id'].toString(),
              'name': name,
              'email': email,
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
      } else {
        setState(() {
          _errorMessage = 'Código de verificação inválido.';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Por favor, insira o código.';
      });
    }
  }

  // Novo método para reenviar o código
  Future<void> _resendCode() async {
    setState(() {
      _isResendingCode = true; // Ativa o estado de carregamento do botão de reenviar
      _errorMessage = null; // Limpa qualquer mensagem de erro anterior
    });

    // Usar widget.arguments para acessar os argumentos passados para a tela
    final arguments = widget.arguments ?? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'];

    if (email != null) {
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
    } else {
      setState(() {
        _isResendingCode = false;
        _errorMessage = 'Não foi possível reenviar o código: e-mail não encontrado.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar widget.arguments para acessar os argumentos passados para a tela
    final arguments = widget.arguments ?? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'] ?? 'seu_email@exemplo.com';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Verificação de E-mail',
                style: GoogleFonts.khula(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F6D3C),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Um código de verificação foi enviado para ',
                style: GoogleFonts.khula(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: GoogleFonts.khula(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'Digite o código de verificação:',
                style: GoogleFonts.khula(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _verificationCodeController,
                keyboardType: TextInputType.text,
                style: GoogleFonts.khula(fontSize: 18),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD7F0D5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.khula(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6D3C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isLoading ? null : _verifyCode,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Verificar Código',
                          style: GoogleFonts.khula(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isResendingCode || _isLoading ? null : _resendCode, // Desabilita se já estiver carregando ou reenviando
                  child: _isResendingCode
                      ? const CircularProgressIndicator(
                          strokeWidth: 2, // Torna o indicador menor
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6D472F)),
                        )
                      : Text(
                          'Reenviar código',
                          style: GoogleFonts.khula(color: const Color(0xFF6D472F), fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}