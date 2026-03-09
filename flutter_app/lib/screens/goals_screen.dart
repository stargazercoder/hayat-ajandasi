import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

const List<String> _catOptions = [
  '💪 Spor','🌍 Dil Öğrenme','📚 Okuma','🧘 Meditasyon','💧 Su',
  '🌅 Erken Kalkma','💻 Kod','🎸 Müzik','✍️ Yazma','🎨 Yaratıcılık',
  '🧠 Zihinsel','🍎 Beslenme','🚶 Yürüyüş','😴 Uyku Düzeni','Özel',
];

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        SectionHeader(
          title: '🔗 Alışkanlık Zinciri',
          subtitle: 'Her gün işaretle, zinciri kırma!',
          action: ElevatedButton(
            onPressed: () => _addModal(context, prov),
            child: const Text('+ Ekle'),
          ),
        ),
        if (prov.goals.isEmpty)
          AppCard(child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Text('🎯', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text('Henüz hedef yok.', style: TextStyle(color: AppTheme.mutedDark)),
              ]),
            ),
          ))
        else
          ...prov.goals.map((g) => _GoalCard(goal: g)),
      ]),
    );
  }

  void _addModal(BuildContext ctx, AppProvider prov) {
    final nameCtrl = TextEditingController();
    String cat = _catOptions.first;
    int days = 66;
    showAppModal(ctx, child: StatefulBuilder(builder: (ctx, ss) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('🎯 Yeni Hedef Zinciri', size: 20),
        const SizedBox(height: 16),
        const Text('Hedef Adı', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Her gün spor yap...')),
        const SizedBox(height: 12),
        const Text('Kategori', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: cat,
          items: _catOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => ss(() => cat = v!),
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 12),
        const Text('Hedef Gün Sayısı', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        Slider(
          value: days.toDouble(),
          min: 7, max: 365, divisions: 50,
          label: '$days gün',
          onChanged: (v) => ss(() => days = v.round()),
        ),
        Text('$days gün', style: GoogleFonts.spaceMono(color: AppTheme.accent)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              if (n.isEmpty) return;
              prov.addGoal(Goal(name: n, cat: cat, targetDays: days));
              Navigator.pop(ctx);
            },
            child: const Text('Oluştur'),
          )),
        ]),
      ],
    )));
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final accent = prov.accentColor;
    final streak = goal.streak;
    final progress = (streak / goal.targetDays).clamp(0.0, 1.0);
    final today = prov.todayStr;
    final doneToday = goal.doneDates.contains(today);

    // Build last 66 days grid
    final days = List.generate(66, (i) {
      final d = DateTime.now().subtract(Duration(days: 65 - i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final isToday = key == today;
      final isDone = goal.doneDates.contains(key);
      return _DayDot(isDone: isDone, isToday: isToday, accent: accent, isDark: isDark);
    });

    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(goal.cat, style: const TextStyle(fontSize: 13)),
            Text(goal.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ])),
          Text('$streak', style: GoogleFonts.spaceMono(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.gold)),
          const Text(' 🔥', style: TextStyle(fontSize: 20)),
        ]),
        const SizedBox(height: 8),
        AppProgressBar(value: progress),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 10),
          child: Text('$streak / ${goal.targetDays} gün',
              style: TextStyle(fontSize: 11, color: isDark ? AppTheme.mutedDark : AppTheme.mutedLight)),
        ),
        Wrap(spacing: 3, runSpacing: 3, children: days),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: doneToday ? AppTheme.accent3 : accent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => prov.toggleGoalDay(goal.id),
            child: Text(doneToday ? '✓ Bugün Yapıldı' : 'Bugün Yaptım!'),
          )),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.accent2),
            onPressed: () => prov.deleteGoal(goal.id),
          ),
        ]),
      ]),
    );
  }
}

class _DayDot extends StatelessWidget {
  final bool isDone, isToday, isDark;
  final Color accent;
  const _DayDot({required this.isDone, required this.isToday, required this.accent, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: 18, height: 18,
    decoration: BoxDecoration(
      color: isDone ? accent : (isDark ? AppTheme.surface2Dark : AppTheme.surface2Light),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: isToday ? AppTheme.accent3 : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
        width: isToday ? 2 : 1,
      ),
    ),
    child: isDone ? const Center(child: Text('✓', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.black))) : null,
  );
}
