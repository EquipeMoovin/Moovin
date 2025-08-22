import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; 
import 'register_screen.dart'; 

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      'image': 'assets/images/onboarding_welcome.png', 
      'title': 'Encontre casas para alugar',
      'description': 'O lugar perfeito para você está te esperando!',
    },
    {
      'image': 'assets/images/onboarding_properties.png',
      'title': 'Propriedades perto de você',
      'description': 'Descubra aluguéis na sua região de forma rápida e rápida.',
    },
    {
      'image': 'assets/images/onboarding_start.png', 
      'title': 'Vamos começar!',
      'description': 'Tudo pronto para facilitar sua busca por um novo lar!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToRegister() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true); 
    Navigator.of(context).pushReplacement( 
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                image: onboardingPages[index]['image']!,
                title: onboardingPages[index]['title']!,
                description: onboardingPages[index]['description']!,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: _currentPage == onboardingPages.length -1 ? 210.0 : 120.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingPages.length,
                  (index) => buildDot(index, context),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: _currentPage == onboardingPages.length - 1
                  ? Column( 
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _navigateToLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F6D3C), 
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _navigateToRegister,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2F6D3C),
                              side: const BorderSide(color: Color(0xFF2F6D3C), width: 1.5), 
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Cadastre-se',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row( 
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0) 
                          TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                            child: const Text(
                              'Voltar',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        else
                          const SizedBox(width: 70), 
                        
                        FloatingActionButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                          backgroundColor: const Color(0xFF2F6D3C), 
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(), 
                          elevation: 0, 
                          child: const Icon(Icons.arrow_forward_ios, size: 20), 
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF2F6D3C) : Colors.grey[300], 
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Image.asset(
          image,
          height: MediaQuery.of(context).size.height * 0.45,
          fit: BoxFit.contain, 
        ),
        const SizedBox(height: 30), 

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0), 
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26, 
              fontWeight: FontWeight.bold,
              color: Colors.black, 
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey, 
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}