import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/members/members_service.dart';

// Service Provider
final membersServiceProvider = Provider<MembersService>((ref) {
  return MembersService();
});

// FutureProvider para carregar a Tabela inicial de Membros
final membersListProvider = FutureProvider<List<Member>>((ref) async {
  final service = ref.watch(membersServiceProvider);
  return await service.getMembers();
});

// Filtro de Busca da View (Riverpod Notifier para gerenciar a Query de Pesquisa em tempo real)
class MemberSearchQueryNotifier extends StateNotifier<String> {
  MemberSearchQueryNotifier() : super('');

  void updateQuery(String newQuery) {
    state = newQuery.toLowerCase();
  }
}

final memberSearchQueryProvider =
    StateNotifierProvider<MemberSearchQueryNotifier, String>((ref) {
  return MemberSearchQueryNotifier();
});

// Lista final exibida ao Usuário (Membros filtrados caso tenha algo digitado)
final filteredMembersProvider = Provider<List<Member>>((ref) {
  final membersAsyncValue = ref.watch(membersListProvider);
  final searchQuery = ref.watch(memberSearchQueryProvider);

  // Retorna vazio enquanto não carega os dados principais
  return membersAsyncValue.when(
    data: (members) {
      if (searchQuery.isEmpty) {
        return members;
      }
      return members
          .where((member) =>
              member.nomeCompleto.toLowerCase().contains(searchQuery))
          .toList();
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});
