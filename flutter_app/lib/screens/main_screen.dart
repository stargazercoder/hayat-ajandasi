import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
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

const String _appVersion = '1.0.0';

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
          text: TextSpan(children: [
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
          ]),
        ),
        actions: [
          IconButton(
            tooltip: 'Ayarlar',
            icon: const Icon(Icons.settings_outlined, size: 22),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _SettingsSheet(),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _NavBar(
              items: _items,
              selected: _tab,
              onTap: (i) => setState(() => _tab = i),
              accent: accent),
        ),
      ),
      body: IndexedStack(index: _tab, children: _screens),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet();
  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  String? _statusMsg;
  bool _statusOk = true;

  void _setStatus(String msg, {bool ok = true}) =>
      setState(() { _statusMsg = msg; _statusOk = ok; });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final accent = prov.accentColor;
    final bg = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final border = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final surf2 = isDark ? AppTheme.surface2Dark : AppTheme.surface2Light;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: border),
        ),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          Expanded(
            child: SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Başlık
                Row(children: [
                  frauncesText('⚙️ Ayarlar', size: 22),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: muted, size: 22),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── GÖRÜNÜM ──────────────────────────────────────
                _label('🎨 Görünüm', muted),
                _Tile(
                  icon: isDark ? '☀️' : '🌙',
                  title: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
                  subtitle: 'Şu an: ${isDark ? "Koyu" : "Açık"} Mod',
                  trailing: Switch(
                    value: isDark,
                    activeColor: accent,
                    onChanged: (_) => prov.toggleTheme(),
                  ),
                  onTap: () => prov.toggleTheme(),
                ),
                const SizedBox(height: 12),
                Text('Vurgu Rengi', style: TextStyle(fontSize: 12, color: muted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: AppTheme.accentOptions.map((c) {
                    final sel = prov.accentColor.value == c.value;
                    return GestureDetector(
                      onTap: () => prov.setAccent(c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: c, shape: BoxShape.circle,
                          border: Border.all(
                              color: sel ? Colors.white : Colors.transparent,
                              width: 3),
                          boxShadow: sel
                              ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)]
                              : [],
                        ),
                        child: sel
                            ? const Icon(Icons.check, color: Colors.black, size: 16)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── KULLANICI ────────────────────────────────────
                _label('👤 Hesap', muted),
                _Tile(
                  icon: '✏️',
                  title: 'Profili Düzenle',
                  subtitle: prov.userName.isNotEmpty ? prov.userName : '—',
                  onTap: () => _editProfile(context, prov),
                ),
                const SizedBox(height: 24),

                // ── VERİ YÖNETİMİ ────────────────────────────────
                _label('💾 Veri Yönetimi', muted),
                _Tile(
                  icon: '📤',
                  title: 'Yedek Al',
                  subtitle: 'Tüm veriyi JSON olarak panoya kopyala',
                  onTap: () => _exportBackup(prov),
                ),
                const SizedBox(height: 8),
                _Tile(
                  icon: '📥',
                  title: 'Yedek Yükle',
                  subtitle: 'JSON verisini yapıştırarak geri yükle',
                  onTap: () => _importBackup(context, prov),
                ),

                // Durum mesajı
                if (_statusMsg != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_statusOk ? accent : AppTheme.accent2).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: (_statusOk ? accent : AppTheme.accent2).withOpacity(0.3)),
                    ),
                    child: Text(_statusMsg!,
                        style: TextStyle(
                            fontSize: 12,
                            color: _statusOk ? accent : AppTheme.accent2)),
                  ),
                ],
                const SizedBox(height: 24),

                // ── HAKKINDA ─────────────────────────────────────
                _label('ℹ️ Hakkında', muted),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surf2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Column(children: [
                    Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text('📓', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        frauncesText('Hayat Ajandası', size: 17),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('v$_appVersion',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace')),
                        ),
                      ]),
                    ]),
                    const SizedBox(height: 14),
                    Divider(color: border),
                    const SizedBox(height: 12),
                    Text(
                      'Kişisel yaşam ajandanız. Görevler, alışkanlık zincirleri, '
                      'günlük, bütçe takibi ve daha fazlası tek bir yerde.\n\n'
                      '🔒 Tüm veriler yalnızca cihazınızda saklanır.',
                      style: TextStyle(fontSize: 13, color: muted, height: 1.65),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      _badge('Flutter', accent),
                      _badge('Provider', accent),
                      _badge('SharedPrefs', accent),
                      _badge('Web Ready', accent),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text, Color muted) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: muted, letterSpacing: 0.8)),
  );

  Widget _badge(String label, Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.12),
      borderRadius: BorderRadius.circular(100),
      border: Border.all(color: accent.withOpacity(0.25)),
    ),
    child: Text(label,
        style: TextStyle(
            fontSize: 11, color: accent, fontWeight: FontWeight.w600)),
  );

  // ── EXPORT ───────────────────────────────────────────────────────────────
  Future<void> _exportBackup(AppProvider prov) async {
    try {
      final data = jsonEncode({
        'exportedAt': DateTime.now().toIso8601String(),
        'version': _appVersion,
        'userName': prov.userName,
        'agendaName': prov.agendaName,
        'salary': prov.salary,
        'isDark': prov.isDark,
        'accentColor': prov.accentColor.value,
        'todos': prov.todos.map((e) => e.toJson()).toList(),
        'goals': prov.goals.map((e) => e.toJson()).toList(),
        'expenses': prov.expenses.map((e) => e.toJson()).toList(),
        'savings': prov.savings.map((e) => e.toJson()).toList(),
        'journal': prov.journal.map((e) => e.toJson()).toList(),
        'gratitude': prov.gratitude.map((e) => e.toJson()).toList(),
        'suggestions': prov.suggestions.map((e) => e.toJson()).toList(),
        'sleepLogs': prov.sleepLogs.map((e) => e.toJson()).toList(),
        'moodLogs': prov.moodLogs.map((e) => e.toJson()).toList(),
        'notes': prov.notes.map((e) => e.toJson()).toList(),
        'measurements': prov.measurements.map((e) => e.toJson()).toList(),
        'sportPrograms': prov.sportPrograms.map((e) => e.toJson()).toList(),
        'bingoData': prov.bingoData,
        'letter': prov.letter?.toJson(),
      });
      await Clipboard.setData(ClipboardData(text: data));
      _setStatus('✅ Yedek panoya kopyalandı! Bir metin dosyasına yapıştırıp .json olarak kaydet.');
    } catch (e) {
      _setStatus('❌ Hata oluştu: $e', ok: false);
    }
  }

  // ── IMPORT ───────────────────────────────────────────────────────────────
  void _importBackup(BuildContext ctx, AppProvider prov) {
    final ctrl = TextEditingController();
    showAppModal(ctx, child: StatefulBuilder(builder: (ctx, ss) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('📥 Yedek Yükle', size: 20),
        const SizedBox(height: 6),
        const Text('Daha önce aldığın JSON yedeğini yapıştır.',
            style: TextStyle(fontSize: 13, color: AppTheme.mutedDark)),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl,
          maxLines: 8,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          decoration: const InputDecoration(hintText: '{ "userName": "..." }'),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              try {
                final d = jsonDecode(text) as Map<String, dynamic>;
                await prov.importFromJson(d);
                Navigator.pop(ctx);
                _setStatus('✅ Veriler başarıyla geri yüklendi!');
              } catch (e) {
                Navigator.pop(ctx);
                _setStatus('❌ Geçersiz JSON: $e', ok: false);
              }
            },
            child: const Text('Yükle'),
          )),
        ]),
      ],
    )));
  }

  // ── EDIT PROFILE ─────────────────────────────────────────────────────────
  void _editProfile(BuildContext ctx, AppProvider prov) {
    final nameCtrl = TextEditingController(text: prov.userName);
    final anameCtrl = TextEditingController(text: prov.agendaName);
    final salaryCtrl = TextEditingController(
        text: prov.salary > 0 ? prov.salary.toStringAsFixed(0) : '');
    showAppModal(ctx, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('👤 Profili Düzenle', size: 20),
        const SizedBox(height: 16),
        const Text('Adın', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Adın...')),
        const SizedBox(height: 12),
        const Text('Ajanda Adı', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: anameCtrl, decoration: const InputDecoration(hintText: 'Ajandanın adı...')),
        const SizedBox(height: 12),
        const Text('Aylık Maaş ₺', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(
          controller: salaryCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '0'),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              if (n.isEmpty) return;
              prov.updateProfile(
                name: n,
                aname: anameCtrl.text.trim(),
                salary: double.tryParse(salaryCtrl.text) ?? 0,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          )),
        ]),
      ],
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TILE WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final String icon, title, subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.mutedDark
                          : AppTheme.mutedLight)),
            ],
          )),
          trailing ??
              Icon(Icons.chevron_right,
                  color: isDark ? AppTheme.mutedDark : AppTheme.mutedLight,
                  size: 20),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV BAR
// ─────────────────────────────────────────────────────────────────────────────
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

  const _NavBar({
    required this.items,
    required this.selected,
    required this.onTap,
    required this.accent,
  });

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
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
