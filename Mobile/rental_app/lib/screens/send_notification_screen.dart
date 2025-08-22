import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service_notification.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateButtonState);
    _messageController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _sendNotification() async {
    final email = _emailController.text.trim();
    
    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Por favor, insira um e-mail válido.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.sendNotification(
        _titleController.text.trim(),
        _messageController.text.trim(),
        email,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificação enviada com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao enviar notificação. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateButtonState);
    _messageController.removeListener(_updateButtonState);
    _emailController.removeListener(_updateButtonState);
    _titleController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Notificação'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(), 
                ),
                maxLength: 100,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                maxLength: 500,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Enviar para (e-mail)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                maxLength: 100,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : ElevatedButton(
                        onPressed: _titleController.text.trim().isNotEmpty &&
                                _messageController.text.trim().isNotEmpty &&
                                _emailController.text.trim().isNotEmpty
                            ? _sendNotification
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                        ),
                        child: const Text('Enviar Notificação'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}