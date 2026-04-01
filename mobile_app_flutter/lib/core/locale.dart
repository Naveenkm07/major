/// Kannada ↔ English translation map for farmer-friendly UI.
/// Usage: AppLocale.t(context, 'home') → 'ಮನೆ' or 'Home'
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AppLocale extends ChangeNotifier {
  static const String _prefKey = 'lang';

  String _languageCode = 'en';
  String get languageCode => _languageCode;
  bool get isKannada => _languageCode == 'kn';

  AppLocale() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(_prefKey) ?? 'en';
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _languageCode = _languageCode == 'en' ? 'kn' : 'en';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
    notifyListeners();
  }

  /// Quick translate helper
  static String t(BuildContext context, String key) {
    try {
      final locale = Provider.of<AppLocale>(context);
      final code = locale.languageCode;
      return _translations[code]?[key] ?? _translations['en']?[key] ?? key;
    } catch (_) {
      return key;
    }
  }

  /// Direct translate (non-context)
  String tr(String key) {
    return _translations[_languageCode]?[key] ?? _translations['en']?[key] ?? key;
  }

  // ═══════════════════════════════════════════════════
  // Translation strings
  // ═══════════════════════════════════════════════════
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // ─── Navigation ──────────────────────────
      'dashboard': 'Dashboard',
      'pest_scan': 'Pest Scan',
      'market': 'Market',
      'community': 'Community',
      'profile': 'Profile',

      // ─── Home ────────────────────────────────
      'app_name': 'KrushikaDhara',
      'tagline': 'Smart Farming Companion',
      'welcome': 'Welcome, Farmer!',
      'ask_ai': 'Ask AI Assistant',
      'quick_actions': 'Quick Actions',
      'todays_tips': "Today's Tips",

      // ─── Feature Cards ───────────────────────
      'pest_detection': 'Pest\nDetection',
      'market_prices': 'Market\nPrices',
      'crop_calendar': 'Crop\nCalendar',
      'govt_schemes': 'Govt\nSchemes',
      'loan_guidance': 'Loan\nGuidance',
      'farmer_connect': 'Farmer\nConnect',

      // ─── Disease Detection ───────────────────
      'capture_photo': 'Take a clear, close-up photo of the affected leaf or plant part.',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'detect_disease': 'Detect Disease',
      'analyzing': 'Analyzing...',
      'treatment': 'Treatment',
      'prevention': 'Prevention',

      // ─── Market ──────────────────────────────
      'search_crop': 'Search crop (e.g., Wheat, Rice)...',
      'no_prices': 'No market prices found',

      // ─── Calendar ────────────────────────────
      'crop_calendar_title': 'Crop Calendar',
      'tasks_for': 'Tasks for',

      // ─── Schemes ─────────────────────────────
      'govt_schemes_title': 'Government Schemes',
      'benefits': 'Benefits',
      'eligibility': 'Eligibility',
      'apply_now': 'Apply Now',

      // ─── Loans ───────────────────────────────
      'loan_guidance_title': 'Loan Guidance',
      'view_details': 'View Details',

      // ─── Community ──────────────────────────
      'farmer_community': 'Farmer Community',
      'share_post': 'Share with the community',
      'post_hint': "What's on your mind? Share farming tips, ask questions...",
      'post': 'Post',
      'no_posts': 'No posts yet',

      // ─── Chatbot ─────────────────────────────
      'ai_assistant': 'AI Assistant',
      'ask_farming': 'Ask about farming...',
      'thinking': 'Thinking...',
      'greeting': "Hi! I'm your farming assistant 🌾",
      'ask_anything': 'Ask me anything about farming!',

      // ─── Auth ────────────────────────────────
      'login': 'Sign In',
      'register': 'Create Account',
      'email': 'Email',
      'password': 'Password',
      'phone': 'Phone Number',
      'full_name': 'Full Name',
      'no_account': "Don't have an account?",
      'logout': 'Logout',
      'kharif': 'Kharif',
      'rabi': 'Rabi',
      'zaid': 'Zaid',

      // ─── General ─────────────────────────────
      'refresh': 'Refresh',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'retry': 'Retry',
      'language': 'Language',
      'kannada': 'ಕನ್ನಡ',
      'english': 'English',
      'farm_details': 'Farm Details',
      'land_area': 'Land Area (Acres)',
      'crops_grown': 'Crops Grown',
      'enter_area': 'Enter farm area',
      'enter_crops': 'Enter crops (e.g. Wheat, Rice)',
      'update': 'Update',
      'save': 'Save',
      'irrigation_wheat': 'Irrigation – Wheat CRI stage',
      'apply_urea': 'Apply urea top-dressing',
      'pest_monitoring': 'Pest monitoring – aphid check',
      'foliar_spray': 'Foliar spray – zinc sulphate',
      'market_survey': 'Market survey for crop rates',
      'growth_stage': 'Growth Stage',
      'activities': 'Activities',
      'week': 'Week',
      'days': 'days',
      'category': 'Category',
      'cereal': 'Cereal',
      'vegetable': 'Vegetable',
      'fruit': 'Fruit',
      'pulse': 'Pulse',
      'all': 'All',
      'central': 'Central',
      'state_schemes': 'State',
      'no_schemes': 'No schemes found',
      'loan_type': 'Loan Type',
      'bank': 'Bank',
      'interest_rate': 'Interest Rate',
      'subsidy': 'Subsidy',
      'view_details_loans': 'View Details',
      'no_loans': 'No loan options available',
      'share_post_title': 'Share Post',
      'comments': 'Comments',
      'likes': 'Likes',
      'write_comment': 'Write a comment...',
      'creating_post': 'Creating post...',
      'min_price': 'Min',
      'max_price': 'Max',
      'stable': 'Stable',
      'rising': 'Rising',
      'falling': 'Falling',
      'confidence': 'confidence',
      'stories': 'Stories',
      'crop_advice': 'Crops',
      'market_discussion': 'Market',
      'success_story': 'Stories',
      'be_first': 'Be the first to share!',
      'required': 'Required',
      'invalid_email': 'Enter valid email',
      'min_password': 'Min 6 characters',
      'invalid_phone': 'Enter 10-digit phone',
      'stories_title': 'Stories',
      'categories': 'Categories',
      'village': 'Village',
      'district': 'District',
      'state': 'State',
      'preferred_language': 'Preferred Language',
      'location': 'Location',
      'not_set': 'Not set',
      'crop_types_hint': 'Crop Types (comma separated)',
      'save_profile': 'Save Profile',
      'profile_updated': 'Profile updated successfully!',
      'land_preparation': 'Land Preparation',
      'sowing': 'Sowing',
      'vegetative_stage': 'Vegetative Stage',
      'flowering_stage': 'Flowering Stage',
      'maturity_stage': 'Maturity Stage',
      'harvesting': 'Harvesting',
      'ploughing': 'Ploughing',
      'fertilizer_application': 'Fertilizer Application',
      'irrigation': 'Irrigation',
      'weed_control': 'Weed Control',
      'pesticide_spray': 'Pesticide Spray',
      'crops_attention': 'Your crops need attention today',
      'irrigation_tip': 'Irrigation Reminder',
      'irrigation_desc': 'Check soil moisture before irrigating. Over-watering damages roots.',
      'pest_alert': 'Pest Alert',
      'pest_desc': 'Yellow stem borer activity reported in your region. Monitor rice fields.',
      'weather_tip': 'Weather',
      'weather_desc': 'Clear skies expected for 3 days — good time for spraying operations.',
      'humidity': 'Humidity',
      'rainfall': 'Rainfall',
      'wind_speed': 'Wind',
      'rain_prob': 'Rain Chance',
      'weather_recommendation': 'Expert Advice',
      'equipment_rental': 'Equipment Rental',
      'list_equipment': 'List Equipment',
      'rent_now': 'Rent Now',
      'no_equipment_found': 'No equipment listed in your area',
      'feature_coming_soon': 'Feature coming soon!',
      'crop_insurance': 'Crop Insurance',
      'pmfby_tracker': 'PMFBY Tracker',
      'check_deadline': 'Check Deadlines',
      'premium_calc': 'Premium Calculator',
      'file_claim': 'File Claim',
    },

    'kn': {
      // ─── Navigation ──────────────────────────
      'dashboard': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
      'pest_scan': 'ರೋಗ ಪತ್ತೆ',
      'market': 'ಮಾರುಕಟ್ಟೆ',
      'community': 'ಸಮುದಾಯ',
      'profile': 'ಪ್ರೊಫೈಲ್',

      // ─── Home ────────────────────────────────
      'app_name': 'ಕೃಷಿಕಾಧಾರ',
      'tagline': 'ಸ್ಮಾರ್ಟ್ ಕೃಷಿ ಸಂಗಾತಿ',
      'welcome': 'ಸ್ವಾಗತ, ರೈತರೇ!',
      'ask_ai': 'AI ಸಹಾಯಕನನ್ನು ಕೇಳಿ',
      'quick_actions': 'ತ್ವರಿತ ಕ್ರಿಯೆಗಳು',
      'todays_tips': 'ಇಂದಿನ ಸಲಹೆಗಳು',

      // ─── Feature Cards ───────────────────────
      'pest_detection': 'ರೋಗ\nಪತ್ತೆ',
      'market_prices': 'ಮಾರುಕಟ್ಟೆ\nಬೆಲೆ',
      'crop_calendar': 'ಬೆಳೆ\nಕ್ಯಾಲೆಂಡರ್',
      'govt_schemes': 'ಸರ್ಕಾರಿ\nಯೋಜನೆಗಳು',
      'loan_guidance': 'ಸಾಲ\nಮಾರ್ಗದರ್ಶನ',
      'farmer_connect': 'ರೈತ\nಸಂಪರ್ಕ',

      // ─── Disease Detection ───────────────────
      'capture_photo': 'ಬಾಧಿತ ಎಲೆಯ ಅಥವಾ ಸಸ್ಯ ಭಾಗದ ಸ್ಪಷ್ಟ ಫೋಟೋ ತೆಗೆಯಿರಿ.',
      'camera': 'ಕ್ಯಾಮೆರಾ',
      'gallery': 'ಗ್ಯಾಲರಿ',
      'detect_disease': 'ರೋಗ ಪತ್ತೆ ಮಾಡಿ',
      'analyzing': 'ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ...',
      'treatment': 'ಚಿಕಿತ್ಸೆ',
      'prevention': 'ತಡೆಗಟ್ಟುವಿಕೆ',

      // ─── Market ──────────────────────────────
      'search_crop': 'ಬೆಳೆ ಹುಡುಕಿ (ಉದಾ: ಗೋಧಿ, ಭತ್ತ)...',
      'no_prices': 'ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳು ಲಭ್ಯವಿಲ್ಲ',

      // ─── Calendar ────────────────────────────
      'crop_calendar_title': 'ಬೆಳೆ ಕ್ಯಾಲೆಂಡರ್',
      'tasks_for': 'ಕಾರ್ಯಗಳು',

      // ─── Schemes ─────────────────────────────
      'govt_schemes_title': 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
      'benefits': 'ಪ್ರಯೋಜನಗಳು',
      'eligibility': 'ಅರ್ಹತೆ',
      'apply_now': 'ಈಗ ಅರ್ಜಿ ಸಲ್ಲಿಸಿ',

      // ─── Loans ───────────────────────────────
      'loan_guidance_title': 'ಸಾಲ ಮಾರ್ಗದರ್ಶನ',
      'view_details': 'ವಿವರಗಳನ್ನು ನೋಡಿ',

      // ─── Community ──────────────────────────
      'farmer_community': 'ರೈತ ಸಮುದಾಯ',
      'share_post': 'ಸಮುದಾಯದೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಿ',
      'post_hint': 'ನಿಮ್ಮ ಮನಸ್ಸಿನಲ್ಲಿ ಏನಿದೆ? ಕೃಷಿ ಸಲಹೆಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಿ...',
      'post': 'ಪೋಸ್ಟ್',
      'no_posts': 'ಯಾವುದೇ ಪೋಸ್ಟ್‌ಗಳಿಲ್ಲ',

      // ─── Chatbot ─────────────────────────────
      'ai_assistant': 'AI ಸಹಾಯಕ',
      'ask_farming': 'ಕೃಷಿ ಬಗ್ಗೆ ಕೇಳಿ...',
      'thinking': 'ಯೋಚಿಸುತ್ತಿದೆ...',
      'greeting': 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮ್ಮ ಕೃಷಿ ಸಹಾಯಕ 🌾',
      'ask_anything': 'ಕೃಷಿ ಬಗ್ಗೆ ಏನನ್ನಾದರೂ ಕೇಳಿ!',

      // ─── Auth ────────────────────────────────
      'login': 'ಲಾಗಿನ್',
      'register': 'ಖಾತೆ ರಚಿಸಿ',
      'email': 'ಇಮೇಲ್',
      'password': 'ಪಾಸ್‌ವರ್ಡ್',
      'phone': 'ಫೋನ್ ಸಂಖ್ಯೆ',
      'full_name': 'ಪೂರ್ಣ ಹೆಸರು',
      'no_account': 'ಖಾತೆ ಇಲ್ಲವೇ?',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'kharif': 'ಮುಂಗಾರು',
      'rabi': 'ಹಿಂಗಾರು',
      'zaid': 'ಬೇಸಿಗೆ',

      // ─── General ─────────────────────────────
      'refresh': 'ರಿಫ್ರೆಶ್',
      'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
      'error': 'ಏನೋ ತಪ್ಪಾಗಿದೆ',
      'retry': 'ಮರುಪ್ರಯತ್ನ',
      'language': 'ಭಾಷೆ',
      'kannada': 'ಕನ್ನಡ',
      'english': 'English',
      'farm_details': 'ಜಮೀನಿನ ವಿವರಗಳು',
      'land_area': 'ಜಮೀನಿನ ವಿಸ್ತೀರ್ಣ (ಎಕರೆ)',
      'crops_grown': 'ಬೆಳೆಯುವ ಬೆಳೆಗಳು',
      'enter_area': 'ಜಮೀನಿನ ವಿಸ್ತೀರ್ಣ ನಮೂದಿಸಿ',
      'enter_crops': 'ಬೆಳೆಗಳನ್ನು ನಮೂದಿಸಿ (ಉದಾ: ಗೋಧಿ, ಭತ್ತ)',
      'update': 'ಅಪ್‌ಡೇಟ್',
      'save': 'ಉಳಿಸಿ',
      'irrigation_wheat': 'ನೀರಾವರಿ - ಗೋಧಿ ಸಿಆರ್‌ಐ ಹಂತ',
      'apply_urea': 'ಯೂರಿಯಾ ಗೊಬ್ಬರ ಹಾಕಿ',
      'pest_monitoring': 'ಕೀಟಗಳ ಮೇಲ್ವಿಚಾರಣೆ - ಅಫಿಡ್ ತಪಾಸಣೆ',
      'foliar_spray': 'ಎಲೆಗಳ ಸಿಂಪಡಣೆ - ಜಿಂಕ್ ಸಲ್ಫೇಟ್',
      'market_survey': 'ಬೆಳೆ ದರಗಳ ಮಾರುಕಟ್ಟೆ ಸಮೀಕ್ಷೆ',
      'growth_stage': 'ಬೆಳವಣಿಗೆಯ ಹಂತ',
      'activities': 'ಚಟುವಟಿಕೆಗಳು',
      'week': 'ವಾರ',
      'days': 'ದಿನಗಳು',
      'category': 'ವರ್ಗ',
      'cereal': 'ಧಾನ್ಯ',
      'vegetable': 'ತರಕಾರಿ',
      'fruit': 'ಹಣ್ಣು',
      'pulse': 'ಬೇಳೆಕಾಳು',
      'all': 'ಎಲ್ಲಾ',
      'central': 'ಕೇಂದ್ರ ಸರ್ಕಾರ',
      'state_schemes': 'ರಾಜ್ಯ ಸರ್ಕಾರ',
      'no_schemes': 'ಯಾವುದೇ ಯೋಜನೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ',
      'loan_type': 'ಸಾಲದ ವಿಧ',
      'bank': 'ಬ್ಯಾಂಕ್',
      'interest_rate': 'ಬಡ್ಡಿ ದರ',
      'subsidy': 'ಸಬ್ಸಿಡಿ',
      'view_details_loans': 'ವಿವರ ನೋಡಿ',
      'no_loans': 'ಯಾವುದೇ ಸಾಲದ ಆಯ್ಕೆಗಳು ಲಭ್ಯವಿಲ್ಲ',
      'share_post_title': 'ಪೋಸ್ಟ್ ಹಂಚಿಕೊಳ್ಳಿ',
      'comments': 'ಕಾಮೆಂಟ್‌ಗಳು',
      'likes': 'ಲೈಕ್‌ಗಳು',
      'write_comment': 'ಕಾಮೆಂಟ್ ಬರೆಯಿರಿ...',
      'creating_post': 'ಪೋಸ್ಟ್ ರಚಿಸಲಾಗುತ್ತಿದೆ...',
      'min_price': 'ಕನಿಷ್ಠ',
      'max_price': 'ಗರಿಷ್ಠ',
      'stable': 'ಸ್ಥಿರ',
      'rising': 'ಏರಿಕೆ',
      'falling': 'ಇಳಿಕೆ',
      'confidence': 'ಭರವಸೆ',
      'stories': 'ಕಥೆಗಳು',
      'crop_advice': 'ಬೆಳೆಗಳು',
      'market_discussion': 'ಮಾರುಕಟ್ಟೆ',
      'success_story': 'ಕಥೆಗಳು',
      'be_first': 'ಮೊದಲನೆಯವರಾಗಿ ಹಂಚಿಕೊಳ್ಳಿ!',
      'required': 'ಅಗತ್ಯವಿದೆ',
      'invalid_email': 'ಸರಿಯಾದ ಇಮೇಲ್ ನಮೂದಿಸಿ',
      'min_password': 'ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳು ಇರಬೇಕು',
      'invalid_phone': '10-ಅಂಕಿಯ ಫೋನ್ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ',
      'stories_title': 'ಕಥೆಗಳು',
      'categories': 'ವರ್ಗಗಳು',
      'village': 'ಗ್ರಾಮ',
      'district': 'ಜಿಲ್ಲೆ',
      'state': 'ರಾಜ್ಯ',
      'preferred_language': 'ಆದ್ಯತೆಯ ಭಾಷೆ',
      'location': 'ಸ್ಥಳ',
      'not_set': 'ನಿಗದಿಪಡಿಸಿಲ್ಲ',
      'crop_types_hint': 'ಬೆಳೆ ವಿಧಗಳು (ಅಲ್ಪವಿರಾಮದಿಂದ ಬೇರ್ಪಡಿಸಿ)',
      'save_profile': 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಿ',
      'profile_updated': 'ಪ್ರೊಫೈಲ್ ಯಶಸ್ವಿಯಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ!',
      'land_preparation': 'ಭೂಮಿ ಸಿದ್ಧತೆ',
      'sowing': 'ಬಿತ್ತನೆ',
      'vegetative_stage': 'ಸಸ್ಯಕ ಹಂತ',
      'flowering_stage': 'ಹೂಬಿಡುವ ಹಂತ',
      'maturity_stage': 'ಪಕ್ವತೆಯ ಹಂತ',
      'harvesting': 'ಕೊಯ್ಲು',
      'ploughing': 'ಉಳುಮೆ',
      'fertilizer_application': 'ಗೊಬ್ಬರ ಹಾಕುವುದು',
      'irrigation': 'ನೀರಾವರಿ',
      'weed_control': 'ಕಳೆ ನಿಯಂತ್ರಣ',
      'pesticide_spray': 'ಕೀಟನಾಶಕ ಸಿಂಪಡಣೆ',
      'crops_attention': 'ನಿಮ್ಮ ಬೆಳೆಗಳಿಗೆ ಇಂದು ಗಮನ ಹರಿಸಬೇಕಾಗಿದೆ',
      'irrigation_tip': 'ನೀರಾವರಿ ಜ್ಞಾಪನೆ',
      'irrigation_desc': 'ನೀರಾವರಿ ಮಾಡುವ ಮೊದಲು ಮಣ್ಣಿನ ತೇವಾಂಶವನ್ನು ಪರೀಕ್ಷಿಸಿ. ಅತಿಯಾದ ನೀರು ಬೇರುಗಳನ್ನು ಹಾನಿಗೊಳಿಸುತ್ತದೆ.',
      'pest_alert': 'ಕೀಟಗಳ ಎಚ್ಚರಿಕೆ',
      'pest_desc': 'ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಹಳದಿ ಕಾಂಡ ಕೊರಕದ ಚಟುವಟಿಕೆ ವರದಿಯಾಗಿದೆ. ಭತ್ತದ ಗದ್ದೆಗಳನ್ನು ಗಮನಿಸಿ.',
      'weather_tip': 'ಹವಾಮಾನ',
      'weather_desc': '3 ದಿನಗಳವರೆಗೆ ಶುಭ್ರ ಆಕಾಶ ನಿರೀಕ್ಷಿಸಲಾಗಿದೆ — ಸಿಂಪಡಣೆ ಕಾರ್ಯಗಳಿಗೆ ಉತ್ತಮ ಸಮಯ.',
      'humidity': 'ತೇವಾಂಶ',
      'rainfall': 'ಮಳೆ',
      'wind_speed': 'ಗಾಳಿ',
      'rain_prob': 'ಮಳೆಯ ಸಾಧ್ಯತೆ',
      'weather_recommendation': 'ತಜ್ಞರ ಸಲಹೆ',
      'equipment_rental': 'ಸಲಕರಣೆ ಬಾಡಿಗೆ',
      'list_equipment': 'ಸಲಕರಣೆ ಪಟ್ಟಿ ಮಾಡಿ',
      'rent_now': 'ಈಗ ಬಾಡಿಗೆಗೆ ಪಡೆಯಿರಿ',
      'no_equipment_found': 'ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಯಾವುದೇ ಸಲಕರಣೆಗಳಿಲ್ಲ',
      'feature_coming_soon': 'ಈ ವೈಶಿಷ್ಟ್ಯವು ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ!',
      'crop_insurance': 'ಬೆಳೆ ವಿಮೆ',
      'pmfby_tracker': 'PMFBY ಟ್ರ್ಯಾಕರ್',
      'check_deadline': 'ಅಂತಿಮ ದಿನಾಂಕ ಪರಿಶೀಲಿಸಿ',
      'premium_calc': 'ಪ್ರೀಮಿಯಂ ಕ್ಯಾಲ್ಕುಲೇಟರ್',
      'file_claim': 'ಕ್ಲೈಮ್ ಸಲ್ಲಿಸಿ',
    },
  };
}

/// InheritedWidget for passing locale down the tree (used internally)
class _LocaleInherited extends InheritedWidget {
  final Locale locale;
  const _LocaleInherited({required this.locale, required super.child});

  @override
  bool updateShouldNotify(_LocaleInherited old) => locale != old.locale;
}
