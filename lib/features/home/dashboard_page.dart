import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../members/members_provider.dart';
import '../expenses/expenses_provider.dart';
import '../incomes/incomes_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersListProvider);
    final expensesAsync = ref.watch(expensesListProvider);
    final incomesAsync = ref.watch(incomesListProvider);
    
    // We can compute the total members and total expenses
    int totalMembers = 0;
    double totalExpensesAmount = 0;
    double totalIncomesAmount = 0;

    membersAsync.whenData((members) {
      totalMembers = members.length;
    });

    expensesAsync.whenData((expenses) {
      totalExpensesAmount = expenses.fold(0.0, (sum, expense) => sum + expense.valor);
    });

    incomesAsync.whenData((incomes) {
      totalIncomesAmount = incomes.fold(0.0, (sum, income) => sum + income.valor);
    });

    double finalBalance = totalIncomesAmount - totalExpensesAmount;

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visão Geral',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final card1 = _buildSummaryCard(
                  context,
                  title: 'Total de Membros',
                  value: membersAsync.isLoading ? '...' : totalMembers.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                );
                final card2 = _buildSummaryCard(
                  context,
                  title: 'Total de Entradas',
                  value: incomesAsync.isLoading ? '...' : currencyFormat.format(totalIncomesAmount),
                  icon: Icons.download,
                  color: Colors.green,
                );
                final card3 = _buildSummaryCard(
                  context,
                  title: 'Despesas Totais',
                  value: expensesAsync.isLoading ? '...' : currencyFormat.format(totalExpensesAmount),
                  icon: Icons.upload,
                  color: Colors.red,
                );
                final card4 = _buildSummaryCard(
                  context,
                  title: 'Saldo Final',
                  value: (incomesAsync.isLoading || expensesAsync.isLoading) ? '...' : currencyFormat.format(finalBalance),
                  icon: Icons.account_balance_wallet,
                  color: finalBalance >= 0 ? Colors.teal : Colors.orange,
                );

                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      Expanded(child: card1),
                      const SizedBox(width: 16),
                      Expanded(child: card2),
                      const SizedBox(width: 16),
                      Expanded(child: card3),
                      const SizedBox(width: 16),
                      Expanded(child: card4),
                    ],
                  );
                } else if (constraints.maxWidth > 500) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: card1),
                          const SizedBox(width: 16),
                          Expanded(child: card2),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                           Expanded(child: card3),
                           const SizedBox(width: 16),
                           Expanded(child: card4),
                        ]
                      )
                    ]
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      card1,
                      const SizedBox(height: 16),
                      card2,
                      const SizedBox(height: 16),
                      card3,
                      const SizedBox(height: 16),
                      card4,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Atalhos Rápidos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildQuickAction(
                  context,
                  title: 'Atualizar Dados',
                  icon: Icons.refresh,
                  onTap: () {
                    ref.refresh(membersListProvider);
                    ref.refresh(expensesListProvider);
                    ref.refresh(incomesListProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dados atualizados com sucesso!'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
