import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_page.dart';
import '../../features/auth/login_page.dart';
import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  
  // Fica escutando as mudanças na sessão e força a barra do GoRouter a reagir
  final authState = ref.watch(authStateProvider);
  final user = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    // Cada vez que o Riverpod notifica que auth mudou, o GoRouter checa a lógica de redirect
    redirect: (context, state) {
      final isAuth = user != null;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isAuth && !isGoingToLogin) {
        return '/login'; // Deslogado tentando entrar em local protegido -> vai pro Login
      }
      
      if (isAuth && isGoingToLogin) {
        return '/'; // Logado tentando ir pra tela de login -> volta pra Home
      }

      return null; // Nenhuma intervenção
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // Adicionar rotas para membros e despesas posteriormente
    ],
  );
});
