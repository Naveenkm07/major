import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://rjdxlenzwffgwujxbzpb.supabase.co';
  final supabaseAnonKey = 'sb_publishable_vEYUuw1cnpY8BGfgdNy1Jw_WEhRxTOP';
  
  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  final url = await client.auth.getOAuthSignInUrl(
    provider: OAuthProvider.google,
    redirectTo: 'http://localhost:5000/',
  );
  print(url);
}
