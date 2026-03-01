import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import 'members_provider.dart';
import 'members_service.dart';

class MembersPage extends ConsumerWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutamos o Estado do usuário atual (para saber se ele pode ver o Editar/Remover)
    final profileAsync = ref.watch(userProfileProvider);
    final bool isAdmin = profileAsync.value?['role'] == 'admin';

    // Lista de membros completa ou vazia esperando loading
    final membersAsyncValue = ref.watch(membersListProvider);
    final filteredMembers = ref.watch(filteredMembersProvider);

    return Scaffold(
      body: Column(
        children: [
          // Barra de Pesquisa / Filto (RF06)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => ref
                        .read(memberSearchQueryProvider.notifier)
                        .updateQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Buscar membro por nome...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Botão Recarregar
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.refresh(membersListProvider),
                  tooltip: 'Atualizar Lista',
                ),
              ],
            ),
          ),
          
          // Lista Principal
          Expanded(
            child: membersAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text(
                  'Erro ao carregar os membros: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (allMembers) {
                if (filteredMembers.isEmpty) {
                  return const Center(
                    child: Text('Nenhum membro encontrado com este nome.'),
                  );
                }

                // Layout de Cartões ou Lista tradicional para usar o espaço
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            member.nomeCompleto[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          member.nomeCompleto,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                        ),
                        subtitle: Text(
                          member.cargo,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        trailing: isAdmin 
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _showEditDialog(context, ref, member);
                                    },
                                    tooltip: 'Editar Membro',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _confirmDelete(context, ref, member);
                                    },
                                    tooltip: 'Remover Membro',
                                  ),
                                ],
                              )
                            : null, // Se não for admin, não exibe botões
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // FAB Só aparece se for ADMIN (NOTA: Novos cadastros demandam Auth real)
      floatingActionButton: isAdmin
          ? null // No Supabase, o ideal é o app usar uma Server Function para gerar novos *Auth Users*.
          : null, // Manteremos o FAB removido por enquanto devido as limitações do "Adicionar membro novo na tabela auth.users pelo client". 
    );
  }

  // --- Função: Abrir Modal de Edição ---
  void _showEditDialog(BuildContext context, WidgetRef ref, Member member) {
    final nomeController = TextEditingController(text: member.nomeCompleto);
    final cargoController = TextEditingController(text: member.cargo);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Membro'),
          content:Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome Completo'),
                  validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cargoController,
                  decoration: const InputDecoration(labelText: 'Cargo na Igreja'),
                  validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final updatedMember = Member(
                      id: member.id,
                      nomeCompleto: nomeController.text,
                      cargo: cargoController.text,
                      role: member.role, // Não deixamos alterar role na view basica
                    );

                    await ref.read(membersServiceProvider).updateMember(updatedMember);
                    ref.refresh(membersListProvider); // Recarrega a lista
                    
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Membro atualizado com sucesso!')),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao atualizar.'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // --- Função: Abrir Alerta de Exclusão ---
  void _confirmDelete(BuildContext context, WidgetRef ref, Member member) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Remover Membro'),
          content: Text('Tem certeza que deseja remover ${member.nomeCompleto} dos registros? \nAtenção: Em uma aplicação real baseada em Supabase Auth, convém desativar o usuário para não quebrar a integridade referencial.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  await ref.read(membersServiceProvider).deleteMember(member.id);
                  ref.refresh(membersListProvider); // Recarrega a lista
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Membro removido.'), backgroundColor: Colors.redAccent),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Você não pode excluir a si mesmo/ou falha no RLS.'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Sim, Remover'),
            ),
          ],
        );
      },
    );
  }
}
