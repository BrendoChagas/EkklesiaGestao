import 'package:supabase_flutter/supabase_flutter.dart';

class Expense {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String? criadoPor;

  Expense({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    this.criadoPor,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
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

class ExpensesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obter todas as despesas ordenadas por data descrescente (mais recentes primeiro)
  Future<List<Expense>> getExpenses() async {
    try {
      final data = await _supabase
          .from('expenses')
          .select()
          .order('data', ascending: false);

      return (data as List<dynamic>)
          .map((json) => Expense.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar despesas: $e');
    }
  }

  // Adicionar uma nova despesa
  Future<void> addExpense(Expense expense) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      final expenseData = expense.toJson();
      expenseData['criado_por'] = user.id;

      await _supabase.from('expenses').insert(expenseData);
    } catch (e) {
      throw Exception('Erro ao adicionar despesa: $e');
    }
  }

  // Atualizar uma despesa existente
  Future<void> updateExpense(Expense expense) async {
    try {
      await _supabase
          .from('expenses')
          .update(expense.toJson())
          .eq('id', expense.id);
    } catch (e) {
      throw Exception('Erro ao atualizar despesa: $e');
    }
  }

  // Deletar uma despesa
  Future<void> deleteExpense(String id) async {
    try {
      await _supabase.from('expenses').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar despesa: $e');
    }
  }
}
