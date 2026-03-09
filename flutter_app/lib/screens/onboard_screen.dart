import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  String _mood = '😊';
  String _name = '';
  String _aname = '';
  double _salary = 0;
  bool _isDark = true;
  Color _accent = AppTheme.accent;

  final _nameCtrl = TextEditingController();
  final _anameCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  final _moods = [
    {'e': '😄', 'l': 'Harika'},
    {'e': '🙂', 'l': 'İyi'},
    {'e': '😐', 'l': 'Normal'},
    {'e': '😔', 'l': 'Yorgun'},
    {'e': '😤', 'l': 'Stresli'},
  ];

  void _next() {
    if (_page == 1) {
      if (_nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İsmin olmadan olmaz! 😊')));
        return;
      }
      _name = _nameCtrl.text.trim();
      _aname = _anameCtrl.text.trim();
      _salary = double.tryParse(_salaryCtrl.text) ?? 0;
    }
    if (_page < 3) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      setState(() => _page++);
    }
  }

  void _start() {
    final prov = context.read<AppProvider>();
    prov.setupUser(_name, _aname, _salary, _isDark, _accent);
    prov.logMood(_mood);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: List.generate(4, (i) => Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _page ? _accent : AppTheme.borderDark,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                )),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [_page0(), _page1(), _page2(), _page3()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page0() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('👋', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 14),
      frauncesHero('Bugün nasıl\nhissediyorsun?'),
      const SizedBox(height: 8),
      Text('Ajandana başlamadan önce bana söyle.',
          style: TextStyle(color: AppTheme.mutedDark, fontSize: 15)),
      const SizedBox(height: 24),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: _moods.map((m) {
          final sel = _mood == m['e'];
          return GestureDetector(
            onTap: () {
              setState(() => _mood = m['e']!);
              Future.delayed(const Duration(milliseconds: 300), _next);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? _accent : AppTheme.borderDark, width: 2),
                color: sel ? AppTheme.surface2Dark : AppTheme.surfaceDark,
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(m['e']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(m['l']!, style: const TextStyle(fontSize: 9, color: AppTheme.mutedDark)),
              ]),
            ),
          );
        }).toList(),
      ),
    ]),
  );

  Widget _page1() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('✨', style: TextStyle(fontSize: 42)),
      const SizedBox(height: 14),
      frauncesHero('Ajandanı\nkişiselleştir'),
      Text('Senin ajandan, senin kuralların.',
          style: TextStyle(color: AppTheme.mutedDark, fontSize: 15)),
      const SizedBox(height: 28),
      _label('Adın'),
      _input(_nameCtrl, 'Adın...'),
      const SizedBox(height: 12),
      _label('Ajandanın adı'),
      _input(_anameCtrl, 'örn: Zeynep\'in Ajandası'),
      const SizedBox(height: 12),
      _label('Aylık Maaş ₺ (opsiyonel)'),
      _input(_salaryCtrl, '25000', keyType: TextInputType.number),
      const SizedBox(height: 24),
      _nextBtn('Devam →'),
    ]),
  );

  Widget _page2() => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('🎨', style: TextStyle(fontSize: 42)),
      const SizedBox(height: 14),
      frauncesHero('Görünüm\nseç'),
      Text('İstediğin zaman değiştirebilirsin.',
          style: TextStyle(color: AppTheme.mutedDark, fontSize: 15)),
      const SizedBox(height: 20),
      Row(children: [
        _themeBtn('🌙', 'Koyu', !_isDark == false),
        const SizedBox(width: 12),
        _themeBtn('☀️', 'Açık', _isDark == false),
      ]),
      const SizedBox(height: 16),
      Text('Vurgu rengi:', style: TextStyle(fontSize: 12, color: AppTheme.mutedDark)),
      const SizedBox(height: 10),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8,
        children: AppTheme.accentOptions.map((c) => GestureDetector(
          onTap: () => setState(() => _accent = c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _accent == c ? Colors.white : Colors.transparent, width: 3),
            ),
            child: _accent == c
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        )).toList(),
      ),
      const SizedBox(height: 24),
      _nextBtn('Devam →'),
    ]),
  );

  Widget _page3() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🎉', style: TextStyle(fontSize: 72)),
      const SizedBox(height: 16),
      frauncesHero('Ajandan\nhazır!', center: true),
      const SizedBox(height: 8),
      Text('Her şey senin için kuruldu. Hadi başlayalım!',
          style: TextStyle(color: AppTheme.mutedDark, fontSize: 15),
          textAlign: TextAlign.center),
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _start,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Ajandamı Aç 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    ]),
  );

  Widget frauncesHero(String text, {bool center = false}) => Text(text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: GoogleFonts.fraunces(
          fontSize: 40, fontWeight: FontWeight.w900,
          color: Colors.white, height: 1.1));

  Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.mutedDark)));

  Widget _input(TextEditingController ctrl, String hint, {TextInputType keyType = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: TextField(
          controller: ctrl,
          keyboardType: keyType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.surface2Dark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppTheme.borderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppTheme.borderDark),
            ),
          ),
        ),
      );

  Widget _nextBtn(String label) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _next,
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );

  Widget _themeBtn(String icon, String label, bool active) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _isDark = label == 'Koyu'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? _accent : AppTheme.borderDark, width: 2),
          color: AppTheme.surfaceDark,
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    ),
  );
}
