import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

const List<String> _questions = [
  "Bu hafta kendine ne öğrettin?",
  "Bugün hangi küçük mutlulukları yaşadın?",
  "5 yıl sonra bugünü nasıl hatırlayacaksın?",
  "Seni en çok ne motive ediyor?",
  "Hangi alışkanlığından en çok gurur duyuyorsun?",
  "Bu ay öğrendiğin en değerli şey?",
  "Bugün için en çok neye şükrediyorsun?",
  "Gelecekteki sen sana ne söylerdi?",
  "Vazgeçmek üzere olduğun ama devam ettiğin bir şey var mı?",
  "Bu yıl en çok nerede büyüdün?",
  "Seni gülümsetecek bir anı hatırla — ne?",
  "Bugün kendinle barışık mısın?",
  "En büyük hayalin ne?",
  "Bugün birine yardım ettin mi?",
  "Olmak istediğin insan nasıl biri?",
];

const Map<String, String> _catIcon = {
  'gunluk': '🌅', 'alisveris': '🛒', 'egitim': '📚',
  'is': '💼', 'kisisel': '🌟', 'diger': '📌',
};

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _qaCtrl = TextEditingController();

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Günaydın ☀️';
    if (h < 18) return 'İyi günler 🌤️';
    return 'İyi akşamlar 🌙';
  }

  String get _todayFormatted {
    final days = ['Pazar','Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi'];
    final months = ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];
    final n = DateTime.now();
    return '${days[n.weekday % 7]}, ${n.day} ${months[n.month - 1]} ${n.year}';
  }

  String get _dailyQuestion {
    final day = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _questions[day % _questions.length];
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final accent = prov.accentColor;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;

    final pendingTodos = prov.todos.where((t) => !t.done && t.cat == 'gunluk').take(5).toList();
    final topChains = [...prov.goals]..sort((a, b) => b.streak - a.streak);
    final chains = topChains.take(4).toList();

    // Prefill daily answer
    final saved = prov.dailyAnswers[prov.todayStr];
    if (saved != null && _qaCtrl.text.isEmpty) _qaCtrl.text = saved;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Greeting + mood
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$_greeting, ${prov.userName}!',
                style: GoogleFonts.fraunces(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(_todayFormatted, style: TextStyle(color: muted, fontSize: 13)),
          ])),
          GestureDetector(
            onTap: () => _pickMood(context, prov),
            child: Text(prov.todayMood ?? '😊', style: const TextStyle(fontSize: 44)),
          ),
        ]),
        const SizedBox(height: 14),

        // Daily question card
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('💭 $_dailyQuestion',
                style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _qaCtrl,
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Cevabını yaz...'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                prov.saveDailyAnswer(_qaCtrl.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cevap kaydedildi! 💭')));
              },
              child: const Text('Kaydet'),
            ),
          ]),
        ),

        // Stats row
        Row(children: [
          Expanded(child: StatCard(
              label: 'KALAN BÜTÇE',
              value: prov.salary > 0
                  ? '₺${prov.remainingBudget.toStringAsFixed(0)}'
                  : '—')),
          const SizedBox(width: 10),
          Expanded(child: StatCard(
              label: 'AKTİF ZİNCİR',
              value: '${prov.goals.length}')),
          const SizedBox(width: 10),
          Expanded(child: StatCard(
              label: 'BEKLEYEN GÖREV',
              value: '${pendingTodos.length}')),
        ]),
        const SizedBox(height: 12),

        // Mood week
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CardTitle(title: '😊 Haftalık Ruh Hali'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final d = DateTime.now().subtract(Duration(days: 6 - i));
                final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                final log = prov.moodLogs.where((m) => m.date == key).isNotEmpty
                    ? prov.moodLogs.firstWhere((m) => m.date == key) : null;
                return Column(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(log?.emoji ?? '·', style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 3),
                  Text('${d.day}', style: TextStyle(fontSize: 9, color: muted)),
                ]);
              }),
            ),
          ]),
        ),

        // Today's todos
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CardTitle(title: '✅ Bugünkü Görevler'),
            const SizedBox(height: 10),
            if (pendingTodos.isEmpty)
              Center(child: Text('Görev yok! 🎉', style: TextStyle(color: muted, fontSize: 13)))
            else
              ...pendingTodos.map((t) => _todoRow(t, prov, accent)),
          ]),
        ),

        // Top chains
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CardTitle(title: '🔗 En İyi Zincirler'),
            const SizedBox(height: 10),
            if (chains.isEmpty)
              Center(child: Text('Hedef ekle!', style: TextStyle(color: muted, fontSize: 13)))
            else
              ...chains.map((g) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(child: Text('${g.cat} ${g.name}', style: const TextStyle(fontSize: 13))),
                  Text('${g.streak} 🔥',
                      style: GoogleFonts.spaceMono(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.gold)),
                ]),
              )),
          ]),
        ),
      ]),
    );
  }

  Widget _todoRow(todo, AppProvider prov, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        GestureDetector(
          onTap: () => prov.toggleTodo(todo.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: todo.done ? accent : Colors.transparent,
              border: Border.all(
                  color: todo.done ? accent : AppTheme.borderDark, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: todo.done ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(
          '${_catIcon[todo.cat] ?? '📌'} ${todo.text}',
          style: TextStyle(
            fontSize: 13,
            decoration: todo.done ? TextDecoration.lineThrough : null,
            color: todo.done ? AppTheme.mutedDark : null,
          ),
        )),
      ]),
    );
  }

  void _pickMood(BuildContext ctx, AppProvider prov) {
    final moods = [
      {'e': '😄', 'l': 'Harika'}, {'e': '🙂', 'l': 'İyi'},
      {'e': '😐', 'l': 'Normal'}, {'e': '😔', 'l': 'Yorgun'}, {'e': '😤', 'l': 'Stresli'},
    ];
    showAppModal(ctx, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('Nasıl hissediyorsun?', size: 20),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: moods.map((m) => GestureDetector(
            onTap: () { prov.logMood(m['e']!); Navigator.pop(ctx); },
            child: Column(children: [
              Text(m['e']!, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(m['l']!, style: const TextStyle(fontSize: 10, color: AppTheme.mutedDark)),
            ]),
          )).toList(),
        ),
      ],
    ));
  }
}
