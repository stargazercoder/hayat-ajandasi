import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

const Map<String, String> catIcon = {
  'gunluk': '🌅', 'alisveris': '🛒', 'egitim': '📚',
  'is': '💼', 'kisisel': '🌟', 'diger': '📌',
};
const List<Map<String, String>> _cats = [
  {'v': 'all', 'l': 'Tümü'},
  {'v': 'gunluk', 'l': '🌅 Günlük'},
  {'v': 'egitim', 'l': '📚 Eğitim'},
  {'v': 'alisveris', 'l': '🛒 Alışveriş'},
  {'v': 'is', 'l': '💼 İş'},
  {'v': 'kisisel', 'l': '🌟 Kişisel'},
  {'v': 'diger', 'l': '📌 Diğer'},
];

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final accent = prov.accentColor;
    final filtered = _filter == 'all'
        ? prov.todos
        : prov.todos.where((t) => t.cat == _filter).toList();
    final done = prov.todos.where((t) => t.done).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: '✅ Görevler',
          action: ElevatedButton(
            onPressed: () => _addTodoModal(context, prov),
            child: const Text('+ Ekle'),
          ),
        ),
        // Stats
        Row(children: [
          Expanded(child: StatCard(label: 'TOPLAM', value: '${prov.todos.length}')),
          const SizedBox(width: 10),
          Expanded(child: StatCard(label: 'TAMAMLANDI', value: '$done', valueColor: AppTheme.accent3)),
          const SizedBox(width: 10),
          Expanded(child: StatCard(label: 'BEKLEYEN', value: '${prov.todos.length - done}', valueColor: AppTheme.accent2)),
        ]),
        const SizedBox(height: 12),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _cats.map((c) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ChipButton(
                label: c['l']!,
                active: _filter == c['v'],
                onTap: () => setState(() => _filter = c['v']!),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // List
        AppCard(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Görev yok! 🎉', style: TextStyle(color: muted)),
                  ))
              : Column(
                  children: filtered.map((t) => _todoTile(t, prov, accent, isDark)).toList(),
                ),
        ),
      ]),
    );
  }

  Widget _todoTile(Todo t, AppProvider prov, Color accent, bool isDark) {
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final priColor = {
      'yuksek': AppTheme.accent2,
      'normal': isDark ? AppTheme.borderDark : AppTheme.borderLight,
      'dusuk': AppTheme.accent3,
    }[t.priority]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        GestureDetector(
          onTap: () => prov.toggleTodo(t.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: t.done ? accent : Colors.transparent,
              border: Border.all(color: t.done ? accent : priColor, width: 2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: t.done ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(
          '${catIcon[t.cat] ?? '📌'} ${t.text}',
          style: TextStyle(
            fontSize: 13,
            decoration: t.done ? TextDecoration.lineThrough : null,
            color: t.done ? muted : null,
          ),
        )),
        IconButton(
          icon: Text('✕', style: TextStyle(color: muted, fontSize: 13)),
          onPressed: () => prov.deleteTodo(t.id),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      ]),
    );
  }

  void _addTodoModal(BuildContext ctx, AppProvider prov) {
    final textCtrl = TextEditingController();
    String cat = 'gunluk';
    String priority = 'normal';
    showAppModal(ctx, child: StatefulBuilder(builder: (ctx, ss) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('✅ Görev Ekle', size: 20),
        const SizedBox(height: 16),
        const Text('Görev', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: textCtrl, decoration: const InputDecoration(hintText: 'Ne yapacaksın?')),
        const SizedBox(height: 12),
        const Text('Kategori', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: cat,
          items: [
            {'v': 'gunluk', 'l': '🌅 Günlük'},
            {'v': 'egitim', 'l': '📚 Eğitim & Gelişim'},
            {'v': 'alisveris', 'l': '🛒 Alışveriş'},
            {'v': 'is', 'l': '💼 İş'},
            {'v': 'kisisel', 'l': '🌟 Kişisel'},
            {'v': 'diger', 'l': '📌 Diğer'},
          ].map((e) => DropdownMenuItem(value: e['v'], child: Text(e['l']!))).toList(),
          onChanged: (v) => ss(() => cat = v!),
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 12),
        const Text('Öncelik', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: priority,
          items: [
            {'v': 'normal', 'l': 'Normal'},
            {'v': 'yuksek', 'l': '🔴 Yüksek'},
            {'v': 'dusuk', 'l': '🟢 Düşük'},
          ].map((e) => DropdownMenuItem(value: e['v'], child: Text(e['l']!))).toList(),
          onChanged: (v) => ss(() => priority = v!),
          decoration: const InputDecoration(),
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
              final t = textCtrl.text.trim();
              if (t.isEmpty) return;
              prov.addTodo(Todo(text: t, cat: cat, priority: priority));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Görev eklendi! ✅')));
            },
            child: const Text('Ekle'),
          )),
        ]),
      ],
    )));
  }
}
