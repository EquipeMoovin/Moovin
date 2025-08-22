import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  _OwnerDashboardScreenState createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  bool? _isOwnerUser;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  void _checkAccess() async {
    final authService = AuthService();
    bool loggedIn = await authService.isLoggedIn();
    bool isOwner = await authService.isOwner();

    if (!loggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else if (!isOwner) {
      Navigator.of(context).pushReplacementNamed('/erro-screen');
    } else {
      setState(() {
        _isOwnerUser = true;
      });
    }
  }

  Future<void> _launchDashboardPage() async {
    final url = Uri.parse('https://moovin.onrender.com/api/users/login-web/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        _errorMessage = 'Não foi possível abrir a página de dashboard.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 250,
                ),
                const Text(
                  'Dashboard do Proprietário',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F6D3C),
                  ),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Color(0xFF2F6D3C),
                  ),
                if (!_isLoading && _errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (!_isLoading && (_isOwnerUser == true))
                  SizedBox(
                    width: 320,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _launchDashboardPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F6D3C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Acessar dashboard',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (!_isLoading && (_isOwnerUser == true))
                  const Text(
                    'Clique acima para acessar a interface web.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF999999),
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
