import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://kiqgnfilifuqskmgkyaa.supabase.co';
  final supabaseAnonKey = 'sb_publishable_Hmmhp4FJYoARgEx_pmFHsA_jf0PYqbW';
  
  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  final url = await client.auth.getOAuthSignInUrl(
    provider: OAuthProvider.google,
    redirectTo: 'http://localhost:5000/',
  );
  print(url);
}
