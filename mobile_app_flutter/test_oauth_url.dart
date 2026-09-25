import 'package:supabase/supabase.dart';

void main() async {
  final supabaseUrl = 'https://rjdxlenzwffgwujxbzpb.supabase.co';
  final redirectUrl = Uri.encodeComponent('http://localhost:5000/');
  
  final url = '$supabaseUrl/auth/v1/authorize?provider=google&redirect_to=$redirectUrl';
  
  print('\n======================================================');
  print('CLICK THIS URL TO SIGN IN WITH GOOGLE:');
  print(url);
  print('======================================================\n');
}
