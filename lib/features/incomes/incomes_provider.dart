import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'incomes_service.dart';

// Service Provider
final incomesServiceProvider = Provider<IncomesService>((ref) {
  return IncomesService();
});

// FutureProvider para carregar a Lista de Ofertas
final incomesListProvider = FutureProvider<List<Income>>((ref) async {
  final service = ref.watch(incomesServiceProvider);
  return await service.getIncomes();
});

// Provider p/ controle de filtro (Search pela descrição/motivo)
class IncomeSearchQueryNotifier extends StateNotifier<String> {
  IncomeSearchQueryNotifier() : super('');

  void updateQuery(String newQuery) {
    state = newQuery.toLowerCase();
  }
}

final incomeSearchQueryProvider =
    StateNotifierProvider<IncomeSearchQueryNotifier, String>((ref) {
  return IncomeSearchQueryNotifier();
});

// Lista combinada e filtrada
final filteredIncomesProvider = Provider<List<Income>>((ref) {
  final incomesAsyncValue = ref.watch(incomesListProvider);
  final searchQuery = ref.watch(incomeSearchQueryProvider);

  return incomesAsyncValue.when(
    data: (incomes) {
      if (searchQuery.isEmpty) return incomes;
      
      return incomes
          .where((e) => e.descricao.toLowerCase().contains(searchQuery))
          .toList();
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});

// Provider Opcional para Soma Total das ofertas do Mês Atual ou Total.
final totalIncomesProvider = Provider<double>((ref) {
  final filteredIncomes = ref.watch(filteredIncomesProvider);
  return filteredIncomes.fold(0.0, (sum, income) => sum + income.valor);
});
