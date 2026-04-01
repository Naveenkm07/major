import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/crop_disease/disease_detection_screen.dart';
import '../screens/market/market_prices_screen.dart';
import '../screens/crop_calendar/crop_calendar_screen.dart';
import '../screens/schemes/schemes_screen.dart';
import '../screens/loans/loans_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/chatbot/chatbot_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String diseaseDetection = '/disease-detection';
  static const String marketPrices = '/market-prices';
  static const String cropCalendar = '/crop-calendar';
  static const String schemes = '/schemes';
  static const String loans = '/loans';
  static const String community = '/community';
  static const String chatbot = '/chatbot';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen());
      case login:
        return _buildRoute(const LoginScreen());
      case register:
        return _buildRoute(const RegisterScreen());
      case home:
        return _buildRoute(const HomeScreen());
      case diseaseDetection:
        return _buildRoute(const DiseaseDetectionScreen());
      case marketPrices:
        return _buildRoute(const MarketPricesScreen());
      case cropCalendar:
        return _buildRoute(const CropCalendarScreen());
      case schemes:
        return _buildRoute(const SchemesScreen());
      case loans:
        return _buildRoute(const LoansScreen());
      case community:
        return _buildRoute(const CommunityScreen());
      case chatbot:
        return _buildRoute(const ChatbotScreen());
      case profile:
        return _buildRoute(const ProfileScreen());
      default:
        return _buildRoute(
          const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
