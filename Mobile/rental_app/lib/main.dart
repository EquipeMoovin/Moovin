import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rental_app/models/immobile.dart';
import 'package:rental_app/providers/immobile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/review_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/owner_provider.dart'; 
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/tenant_profile_screen.dart';
import 'screens/owner_profile_screen.dart';
import 'screens/detail_immobile_screen.dart';
import 'screens/owner_dashboard_screen.dart';
import 'screens/search_immobile_screen.dart';
import 'screens/review_screen.dart';
import 'screens/create_profile_screen.dart';
import 'screens/unauthorized_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/review_create_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/onboarding_screen.dart';
import 'providers/chat_provider.dart';
import 'providers/tenant_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => OwnerProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => ImmobileProvider()),
      ],
      child: MyApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const MyApp({super.key, required this.hasCompletedOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moovin',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.khulaTextTheme(),
      ),
      home: hasCompletedOnboarding
          ? const LoginScreen()
          : const OnboardingScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tenant': (context) => const TenantProfileScreen(),
        '/owner': (context) => const OwnerProfileScreen(),
        '/chat': (context) => const ChatScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/immobile_details': (context) => ChangeNotifierProvider(
              create: (context) => ReviewProvider(),
              child: DetailImmobileScreen(
                immobileId: ModalRoute.of(context)?.settings.arguments as int? ?? 3,
              ),
            ),
        '/owner_dashboard': (context) => const OwnerDashboardScreen(),
        '/search-immobile': (context) => const SearchImmobileScreen(),
        '/erro-screen': (context) => const UnauthorizedScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/conversations': (context) => const ChatScreen(),
        '/create_review': (context) => ChangeNotifierProvider(
              create: (_) => ReviewProvider(),
              child: Builder(
                builder: (newContext) {
                  final args = ModalRoute.of(newContext)?.settings.arguments as Map<String, dynamic>?;
                  final reviewType = args?['reviewType'] as String? ?? 'PROPERTY';
                  final targetId = args?['targetId'] as int? ?? 3;
                  final targetName = args?['targetName'] as String? ?? 'admin';
                  return CreateReviewScreen(
                    reviewType: reviewType,
                    targetId: targetId,
                    targetName: targetName,
                  );
                },
              ),
            ),
        '/review': (context) => ChangeNotifierProvider(
              create: (_) => ReviewProvider(),
              child: Builder(
                builder: (newContext) {
                  final args = ModalRoute.of(newContext)?.settings.arguments as Map<String, dynamic>?;
                  final reviewType = args?['reviewType'] as String? ?? 'immobile';
                  final targetId = args?['targetId'] as int? ?? 1;
                  return ReviewsScreen(
                    reviewType: reviewType,
                    targetId: targetId,
                  );
                },
              ),
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/create-profile') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('userId')) {
            return _errorRoute();
          }

          return MaterialPageRoute(
            builder: (_) => CreateProfileScreen(
              userId: args['userId'].toString(),
              name: args['name'] ?? '',
              email: args['email'] ?? '',
              isOwner: args['isOwner'] ?? false,
            ),
          );
        }

        return _errorRoute();
      },
    );
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Rota não encontrada')),
      ),
    );
  }
}
