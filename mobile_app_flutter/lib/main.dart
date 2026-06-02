import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'core/locale.dart';
import 'core/connectivity_service.dart';
import 'providers/auth_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/market_provider.dart';
import 'providers/community_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/farmer_connect_provider.dart';
import 'services/voice_assistant_service.dart';
import 'services/hive_storage_service.dart';
import 'providers/weather_provider.dart';
import 'providers/equipment_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/setup_profile_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/crop_disease/disease_detection_screen.dart';
import 'screens/market/market_prices_screen.dart';
import 'screens/crop_calendar/crop_calendar_screen.dart';
import 'screens/schemes/schemes_screen.dart';
import 'screens/loans/loans_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/community/farmer_connect_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/voice/voice_assistant_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';
import 'screens/insurance/insurance_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/notifications/notifications_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize offline storage
  await HiveStorageService.init();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const KrushikaDharaApp());
}

class KrushikaDharaApp extends StatelessWidget {
  const KrushikaDharaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLocale()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FarmerConnectProvider()),
        ChangeNotifierProvider(create: (_) => VoiceAssistantService()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => EquipmentProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'KrushikaDhara',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/otp': (_) => const OtpScreen(),
          '/setup-profile': (_) => const SetupProfileScreen(),
          '/home': (_) => const HomeScreen(),
          '/disease-detection': (_) => const DiseaseDetectionScreen(),
          '/market-prices': (_) => const MarketPricesScreen(),
          '/crop-calendar': (_) => const CropCalendarScreen(),
          '/schemes': (_) => const SchemesScreen(),
          '/loans': (_) => const LoansScreen(),
          '/community': (_) => const FarmerConnectScreen(),
          '/chatbot': (_) => const ChatbotScreen(),
          '/voice-assistant': (_) => const VoiceAssistantScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/equipment-rental': (_) => const MarketplaceScreen(),
          '/insurance': (_) => const InsuranceScreen(),
          '/help-support': (_) => const HelpSupportScreen(),
          '/notifications': (_) => const NotificationsScreen(),
        },
      ),
    );
  }
}
