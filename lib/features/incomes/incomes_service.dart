import 'package:supabase_flutter/supabase_flutter.dart';

class Income {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String? criadoPor;

  Income({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    this.criadoPor,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'] as String,
      descricao: json['descricao'] as String,
      valor: double.parse(json['valor'].toString()),
      data: DateTime.parse(json['data'] as String),
      criadoPor: json['criado_por'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String().split('T').first, // Formata para DATE
      // 'criado_por' não é necessário enviar no insert/update a menos que se queira forçar
    };
  }
}

class IncomesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obter todas as ofertas ordenadas por data descrescente (mais recentes primeiro)
  Future<List<Income>> getIncomes() async {
    try {
      final data = await _supabase
          .from('incomes')
          .select()
          .order('data', ascending: false);

      return (data as List<dynamic>)
          .map((json) => Income.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar ofertas: $e');
    }
  }

  // Adicionar uma nova oferta
  Future<void> addIncome(Income income) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final incomeData = income.toJson();
      incomeData['criado_por'] = user.id;

      await _supabase.from('incomes').insert(incomeData);
    } catch (e) {
      throw Exception('Erro ao adicionar oferta: $e');
    }
  }

  // Atualizar uma oferta existente
  Future<void> updateIncome(Income income) async {
    try {
      await _supabase
          .from('incomes')
          .update(income.toJson())
          .eq('id', income.id);
    } catch (e) {
      throw Exception('Erro ao atualizar oferta: $e');
    }
  }

  // Deletar uma oferta
  Future<void> deleteIncome(String id) async {
    try {
      await _supabase.from('incomes').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar oferta: $e');
    }
  }
}
