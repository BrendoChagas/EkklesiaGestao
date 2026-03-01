import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expenses_service.dart';

// Service Provider
final expensesServiceProvider = Provider<ExpensesService>((ref) {
  return ExpensesService();
});

// FutureProvider para carregar a Lista de Despesas
final expensesListProvider = FutureProvider<List<Expense>>((ref) async {
  final service = ref.watch(expensesServiceProvider);
  return await service.getExpenses();
});

// Provider p/ controle de filtro (Search pela descrição/motivo)
class ExpenseSearchQueryNotifier extends StateNotifier<String> {
  ExpenseSearchQueryNotifier() : super('');

  void updateQuery(String newQuery) {
    state = newQuery.toLowerCase();
  }
}

final expenseSearchQueryProvider =
    StateNotifierProvider<ExpenseSearchQueryNotifier, String>((ref) {
  return ExpenseSearchQueryNotifier();
});

// Lista combinada e filtrada
final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final expensesAsyncValue = ref.watch(expensesListProvider);
  final searchQuery = ref.watch(expenseSearchQueryProvider);

  return expensesAsyncValue.when(
    data: (expenses) {
      if (searchQuery.isEmpty) return expenses;
      
      return expenses
          .where((e) => e.descricao.toLowerCase().contains(searchQuery))
          .toList();
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});

// Provider Opcional para Soma Total das despesas do Mês Atual ou Total.
final totalExpensesProvider = Provider<double>((ref) {
  final filteredExpenses = ref.watch(filteredExpensesProvider);
  return filteredExpenses.fold(0.0, (sum, expense) => sum + expense.valor);
});
