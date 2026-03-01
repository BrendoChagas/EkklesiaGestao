import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obter o usuário atual
  User? get currentUser => _supabase.auth.currentUser;

  // Stream de mudanças de estado de autenticação
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Fazer login com E-mail e Senha
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Ocorreu um erro inesperado ao fazer login.');
    }
  }

  // Fazer logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Erro ao sair da conta: $e');
    }
  }

  // Obter o perfil (Profile) do usuário atual (para saber se é admin ou membro)
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return data;
    } catch (e) {
      print('Erro ao buscar perfil do usuário: $e');
      return null;
    }
  }
}
