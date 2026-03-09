import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'todo_screen.dart';
import 'bingo_screen.dart';
import 'goals_screen.dart';
import 'routines_screen.dart';
import 'salary_screen.dart';
import 'journal_screen.dart';
import 'suggestions_screen.dart';
import 'letter_screen.dart';
import 'sleep_screen.dart';
import 'social_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tab = 0;

  final List<_NavItem> _items = [
    _NavItem('🏠', 'Ana'),
    _NavItem('✅', 'Görevler'),
    _NavItem('🎯', 'Bingo'),
    _NavItem('🔗', 'Zincirler'),
    _NavItem('🗒️', 'Rutinler'),
    _NavItem('💰', 'Maaş'),
    _NavItem('📝', 'Günlük'),
    _NavItem('💡', 'Öneriler'),
    _NavItem('💌', 'Mektup'),
    _NavItem('😴', 'Uyku'),
    _NavItem('👥', 'Sosyal'),
  ];

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TodoScreen(),
    const BingoScreen(),
    const GoalsScreen(),
    const RoutinesScreen(),
    const SalaryScreen(),
    const JournalScreen(),
    const SuggestionsScreen(),
    const LetterScreen(),
    const SleepScreen(),
    const SocialScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final accent = prov.accentColor;
    final isDark = prov.isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? AppTheme.bgDark.withOpacity(0.94)
            : AppTheme.bgLight.withOpacity(0.94),
        elevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: prov.agendaName.split(' ').first,
                style: GoogleFonts.fraunces(
                    fontSize: 19, fontWeight: FontWeight.w900, color: accent),
              ),
              if (prov.agendaName.split(' ').length > 1)
                TextSpan(
                  text: ' ${prov.agendaName.split(' ').skip(1).join(' ')}',
                  style: GoogleFonts.fraunces(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppTheme.textDark : AppTheme.textLight),
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Text(isDark ? '☀️' : '🌙', style: const TextStyle(fontSize: 18)),
            onPressed: () => context.read<AppProvider>().toggleTheme(),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _NavBar(items: _items, selected: _tab, onTap: (i) => setState(() => _tab = i), accent: accent),
        ),
      ),
      body: IndexedStack(index: _tab, children: _screens),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _NavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int selected;
  final ValueChanged<int> onTap;
  final Color accent;

  const _NavBar({required this.items, required this.selected, required this.onTap, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().isDark;
    return SizedBox(
      height: 44,
      child: ScrollConfiguration(
        behavior: _DragScrollBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          separatorBuilder: (_, __) => const SizedBox(width: 2),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final active = i == selected;
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
                decoration: BoxDecoration(
                  color: active ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${items[i].icon} ${items[i].label}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? Colors.black
                        : (isDark ? AppTheme.mutedDark : AppTheme.mutedLight),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
