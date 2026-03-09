import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboard_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
