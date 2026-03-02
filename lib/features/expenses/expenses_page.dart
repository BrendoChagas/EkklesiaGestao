import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import 'expenses_provider.dart';
import 'expenses_service.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta nível de acesso para bloquear Inserir/Editar Despesas p/ Membros comuns
    final profileAsync = ref.watch(userProfileProvider);
    final bool isAdmin = profileAsync.value?['role'] == 'admin';

    final expensesAsyncValue = ref.watch(expensesListProvider);
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final totalAmmount = ref.watch(totalExpensesProvider);

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: Column(
        children: [
          // Header com Resumo Financeiro
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Despesas Totais (Filtro Atual)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(totalAmmount),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),

          // Filtro / Busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => ref
                        .read(expenseSearchQueryProvider.notifier)
                        .updateQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Buscar despesa por descrição...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recarregar Despesas',
                  onPressed: () => ref.refresh(expensesListProvider),
                ),
              ],
            ),
          ),

          // Lista Principal
          Expanded(
            child: expensesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Erro: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (_) {
                if (filteredExpenses.isEmpty) {
                  return const Center(child: Text('Nenhuma despesa encontrada.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.money_off, color: Colors.red),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.descricao,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(expense.data),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(expense.valor),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isAdmin)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                    onPressed: () => _showDespesaDialog(context, ref, expense: expense),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _confirmDeleteExpense(context, ref, expense),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showDespesaDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Nova Despesa'),
            )
          : null,
    );
  }

  // --- Modal Criar/Editar Despesa ---
  void _showDespesaDialog(BuildContext context, WidgetRef ref, {Expense? expense}) {
    final bool isEdit = expense != null;
    final descricaoController = TextEditingController(text: isEdit ? expense.descricao : '');
    final valorController = TextEditingController(text: isEdit ? expense.valor.toString() : '');
    
    // Fica a data atual por padrao no cadastro
    DateTime selectedDate = isEdit ? expense.data : DateTime.now(); 

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder( // StatefulBuilder para atualizar data selecionada
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(isEdit ? 'Editar Despesa' : 'Nova Despesa'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição / Motivo'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valorController,
                      decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Data da Despesa:'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setStateModal(() => selectedDate = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (descricaoController.text.isEmpty || valorController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preencha os campos de descrição e valor.')),
                      );
                      return;
                    }

                    final service = ref.read(expensesServiceProvider);
                    
                    try {
                      final newExpense = Expense(
                        id: isEdit ? expense.id : '',
                        descricao: descricaoController.text,
                        valor: double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0,
                        data: selectedDate,
                      );

                      if (isEdit) {
                        await service.updateExpense(newExpense);
                      } else {
                        await service.addExpense(newExpense);
                      }

                      ref.refresh(expensesListProvider);
                      
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Despesa salva com sucesso!')),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // --- Função: Abrir Alerta de Exclusão ---
  void _confirmDeleteExpense(BuildContext context, WidgetRef ref, Expense expense) {
    showDialog(
      context: context,
      builder: (ctx) {
        final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
        return AlertDialog(
          title: const Text('Apagar Despesa'),
          content: Text('Excluir permanentemente "${expense.descricao}" no valor de ${currencyFormat.format(expense.valor)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  await ref.read(expensesServiceProvider).deleteExpense(expense.id);
                  ref.refresh(expensesListProvider);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Sim, Apagar'),
            ),
          ],
        );
      },
    );
  }
}
