import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://mowjepjrduhwjotbvowd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vd2plcGpyZHVod2pvdGJ2b3dkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzODM5NjIsImV4cCI6MjA4Nzk1OTk2Mn0.FVmxsR8KRTHCFHjvjQIsnZDHe9KPsEbo6oE-7skeBFo',
  );

  runApp(
    const ProviderScope(
      child: EkklesiaApp(),
    ),
  );
}

class EkklesiaApp extends ConsumerWidget {
  const EkklesiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Ekklesia Gestão',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
