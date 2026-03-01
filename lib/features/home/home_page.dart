import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../members/members_page.dart'; // Add o import novo
import '../expenses/expenses_page.dart'; // Adicondo import das dispesas

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Dashboard Analytics / Visão Geral', style: TextStyle(fontSize: 24))),
    MembersPage(), // Inserir a classe importável MembersPage no lugar do texto cru
    ExpensesPage(), // Abas de Despesa conectada
  ];

  @override
  Widget build(BuildContext context) {
    // Buscando os dados do perfil atual via Riverpod
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekklesia Gestão'),
        actions: [
          profileAsync.when(
            data: (profile) {
              if (profile == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Chip(
                  avatar: const Icon(Icons.person, size: 18),
                  label: Text('${profile['nome_completo']} (${profile['role']})'),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da Conta',
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Visão Geral'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Membros'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.attach_money_outlined),
                selectedIcon: Icon(Icons.attach_money),
                label: Text('Despesas'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
