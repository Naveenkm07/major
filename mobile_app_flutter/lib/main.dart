import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
import 'screens/admin/admin_notification_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env variables securely (Optional on Vercel)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('No .env file found, relying on hardcoded keys');
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase (Hardcoded for Vercel deployment)
  final supabaseUrl = 'https://kiqgnfilifuqskmgkyaa.supabase.co';
  final supabaseAnonKey = 'sb_publishable_Hmmhp4FJYoARgEx_pmFHsA_jf0PYqbW';
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
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
        builder: (context, child) {
          if (kIsWeb) {
            return Container(
              color: const Color(0xFFF0F2F5), // Light background for desktop
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450), // Mobile width constraint
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: child!,
                ),
              ),
            );
          }
          return child!;
        },
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
          '/admin-notifications': (_) => const AdminNotificationScreen(),
        },
      ),
    );
  }
}
