import 'package:supabase_flutter/supabase_flutter.dart';

class Member {
  final String id;
  final String nomeCompleto;
  final String cargo;
  final String role;

  Member({
    required this.id,
    required this.nomeCompleto,
    required this.cargo,
    required this.role,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      nomeCompleto: json['nome_completo'] as String,
      cargo: json['cargo'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_completo': nomeCompleto,
      'cargo': cargo,
      'role': role,
    };
  }
}

class MembersService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obter todos os membros ordenados por nome completo
  Future<List<Member>> getMembers() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .order('nome_completo', ascending: true);

      return (data as List<dynamic>)
          .map((json) => Member.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar membros: $e');
    }
  }

  // Atualizar dados de um membro existente (Requer Auth Admin pela RLS)
  Future<void> updateMember(Member member) async {
    try {
      await _supabase
          .from('profiles')
          .update(member.toJson())
          .eq('id', member.id);
    } catch (e) {
      throw Exception('Erro ao atualizar membro: $e');
    }
  }

  // Deletar usuário (Requer que ele seja removido de `auth.users` via RPC ou função backend se for Full Delete)
  // No Supabase, o DELETE em 'profiles' falha se tentar pelo cliente se não tivermos 
  // um trigger correspondente em auth. Apenas excluiremos o perfil para fins deste fluxo 
  // (Nota: para exclusao total com DB real precisa ser feito via Supabase Admin API/Function).
  Future<void> deleteMember(String id) async {
    try {
      await _supabase.from('profiles').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao remover membro: $e');
    }
  }
}
