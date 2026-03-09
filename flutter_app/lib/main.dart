import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboard_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wfuuclosqisnboshhobn.supabase.co',
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmdXVjbG9zcWlzbmJvc2hob2JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwNzk5ODQsImV4cCI6MjA4ODY1NTk4NH0.ipiFtSjOW2N_6rHHzjp1lxR96Wm0MPa4twEWU6uYIkI',
    ),
  );

  final provider = AppProvider();
  await provider.load();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const HayatAjandasiApp(),
    ),
  );
}

class HayatAjandasiApp extends StatelessWidget {
  const HayatAjandasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return MaterialApp(
      title: prov.agendaName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(prov.accentColor),
      darkTheme: AppTheme.dark(prov.accentColor),
      themeMode: prov.isDark ? ThemeMode.dark : ThemeMode.light,
      home: prov.userName.isEmpty ? const OnboardScreen() : const MainScreen(),
    );
  }
}
