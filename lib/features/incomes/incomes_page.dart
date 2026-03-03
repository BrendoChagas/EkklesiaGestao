import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import 'incomes_provider.dart';
import 'incomes_service.dart';

class IncomesPage extends ConsumerWidget {
  const IncomesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta nível de acesso para bloquear Inserir/Editar Ofertas p/ Membros comuns
    final profileAsync = ref.watch(userProfileProvider);
    final bool isAdmin = profileAsync.value?['role'] == 'admin';

    final incomesAsyncValue = ref.watch(incomesListProvider);
    final filteredIncomes = ref.watch(filteredIncomesProvider);
    final totalAmmount = ref.watch(totalIncomesProvider);

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
                  'Ofertas Totais (Filtro Atual)',
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
                        .read(incomeSearchQueryProvider.notifier)
                        .updateQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Buscar oferta por descrição...',
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
                  tooltip: 'Recarregar Ofertas',
                  onPressed: () => ref.refresh(incomesListProvider),
                ),
              ],
            ),
          ),

          // Lista Principal
          Expanded(
            child: incomesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Erro: $err', style: const TextStyle(color: Colors.red)),
              ),
              data: (_) {
                if (filteredIncomes.isEmpty) {
                  return const Center(child: Text('Nenhuma oferta encontrada.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredIncomes.length,
                  itemBuilder: (context, index) {
                    final income = filteredIncomes[index];

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
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: Colors.green),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    income.descricao,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateFormat.format(income.data),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(income.valor),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
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
                                    onPressed: () => _showOfertaDialog(context, ref, income: income),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _confirmDeleteIncome(context, ref, income),
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
              onPressed: () => _showOfertaDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Nova Oferta'),
            )
          : null,
    );
  }

  // --- Modal Criar/Editar Oferta ---
  void _showOfertaDialog(BuildContext context, WidgetRef ref, {Income? income}) {
    final bool isEdit = income != null;
    final descricaoController = TextEditingController(text: isEdit ? income.descricao : '');
    final valorController = TextEditingController(text: isEdit ? income.valor.toString() : '');
    
    // Fica a data atual por padrao no cadastro
    DateTime selectedDate = isEdit ? income.data : DateTime.now(); 

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder( // StatefulBuilder para atualizar data selecionada
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(isEdit ? 'Editar Oferta' : 'Nova Oferta'),
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
                      title: const Text('Data da Oferta:'),
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

                    final service = ref.read(incomesServiceProvider);
                    
                    try {
                      final newIncome = Income(
                        id: isEdit ? income.id : '',
                        descricao: descricaoController.text,
                        valor: double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0,
                        data: selectedDate,
                      );

                      if (isEdit) {
                        await service.updateIncome(newIncome);
                      } else {
                        await service.addIncome(newIncome);
                      }

                      ref.refresh(incomesListProvider);
                      
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Oferta salva com sucesso!')),
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
  void _confirmDeleteIncome(BuildContext context, WidgetRef ref, Income income) {
    showDialog(
      context: context,
      builder: (ctx) {
        final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
        return AlertDialog(
          title: const Text('Apagar Oferta'),
          content: Text('Excluir permanentemente "${income.descricao}" no valor de ${currencyFormat.format(income.valor)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  await ref.read(incomesServiceProvider).deleteIncome(income.id);
                  ref.refresh(incomesListProvider);
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
