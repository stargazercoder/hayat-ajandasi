import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

// ════════════════════════════════════════════════════════════
// SALARY SCREEN
// ════════════════════════════════════════════════════════════
class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final accent = prov.accentColor;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final total = prov.totalExpenses;
    final progress = prov.salary > 0 ? (total / prov.salary).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        SectionHeader(title: '💰 Maaş & Giderler'),
        // Budget card
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(title: '💳 Bütçe Özeti'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: StatCard(label: 'MAAŞ', value: prov.salary > 0 ? '₺${prov.salary.toStringAsFixed(0)}' : '—')),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'HARCANAN', value: '₺${total.toStringAsFixed(0)}', valueColor: AppTheme.accent2)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'KALAN', value: prov.salary > 0 ? '₺${prov.remainingBudget.toStringAsFixed(0)}' : '—', valueColor: accent)),
          ]),
          const SizedBox(height: 10),
          AppProgressBar(value: progress, color: progress > 0.9 ? AppTheme.accent2 : accent),
        ])),
        // Expenses
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(title: '📊 Giderler', action: ElevatedButton(
            onPressed: () => _addExpenseModal(context, prov),
            child: const Text('+ Gider'),
          )),
          const SizedBox(height: 10),
          if (prov.expenses.isEmpty)
            Center(child: Text('Henüz gider yok.', style: TextStyle(color: muted, fontSize: 13)))
          else
            ...prov.expenses.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(child: Text(e.name, style: const TextStyle(fontSize: 13))),
                Text('₺${e.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.spaceMono(fontSize: 13, color: AppTheme.accent2, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => prov.deleteExpense(e.id),
                  child: Text('✕', style: TextStyle(color: muted)),
                ),
              ]),
            )),
        ])),
        // Savings
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(title: '🎁 Birikim Hedefleri', action: ElevatedButton(
            onPressed: () => _addSavingModal(context, prov),
            child: const Text('+ Ekle'),
          )),
          const SizedBox(height: 10),
          if (prov.savings.isEmpty)
            Center(child: Text('Henüz birikim hedefi yok.', style: TextStyle(color: muted, fontSize: 13)))
          else
            ...prov.savings.map((s) => _savingTile(s, prov, accent, muted)),
        ])),
      ]),
    );
  }

  Widget _savingTile(Saving s, AppProvider prov, Color accent, Color muted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(s.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            Text('₺${s.current.toStringAsFixed(0)} / ₺${s.target.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 11, color: muted)),
          ])),
          GestureDetector(
            onTap: () => prov.deleteSaving(s.id),
            child: Text('✕', style: TextStyle(color: muted)),
          ),
        ]),
        const SizedBox(height: 6),
        AppProgressBar(value: s.progress),
      ]),
    );
  }

  void _addExpenseModal(BuildContext ctx, AppProvider prov) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String cat = 'diger';
    showAppModal(ctx, child: StatefulBuilder(builder: (ctx, ss) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('📊 Gider Ekle', size: 20),
        const SizedBox(height: 16),
        const Text('Ad', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Market, kira...')),
        const SizedBox(height: 12),
        const Text('Tutar ₺', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '0')),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              final a = double.tryParse(amountCtrl.text) ?? 0;
              if (n.isEmpty || a == 0) return;
              prov.addExpense(Expense(name: n, amount: a, cat: cat));
              Navigator.pop(ctx);
            },
            child: const Text('Ekle'),
          )),
        ]),
      ],
    )));
  }

  void _addSavingModal(BuildContext ctx, AppProvider prov) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    String emoji = '🎁';
    showAppModal(ctx, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('🎁 Birikim Hedefi', size: 20),
        const SizedBox(height: 16),
        const Text('Hedef Adı', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Tatil, Bilgisayar...')),
        const SizedBox(height: 12),
        const Text('Hedef Tutar ₺', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: '10000')),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              final t = double.tryParse(targetCtrl.text) ?? 0;
              if (n.isEmpty || t == 0) return;
              prov.addSaving(Saving(name: n, target: t, emoji: emoji));
              Navigator.pop(ctx);
            },
            child: const Text('Ekle'),
          )),
        ]),
      ],
    ));
  }
}

// ════════════════════════════════════════════════════════════
// JOURNAL SCREEN
// ════════════════════════════════════════════════════════════
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final gratCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        SectionHeader(
          title: '📝 Günlük & Şükür',
          subtitle: 'Düşün, yaz, büyü.',
          action: ElevatedButton(
            onPressed: () => _addJournalModal(context, prov),
            child: const Text('+ Yaz'),
          ),
        ),
        // Gratitude card
        AppCard(
          borderColor: AppTheme.purple.withOpacity(0.4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CardTitle(title: '🌸 Bugünün Şükrü'),
            const SizedBox(height: 10),
            ...prov.todayGratitude.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Text('🌸', style: TextStyle(color: AppTheme.purple)),
                const SizedBox(width: 8),
                Expanded(child: Text(g.text, style: const TextStyle(fontSize: 13))),
                GestureDetector(
                  onTap: () => prov.deleteGratitude(g.id),
                  child: Text('✕', style: TextStyle(color: muted, fontSize: 12)),
                ),
              ]),
            )),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(
                controller: gratCtrl,
                decoration: const InputDecoration(hintText: 'Bugün neye şükrediyorsun?'),
              )),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final t = gratCtrl.text.trim();
                  if (t.isNotEmpty) { prov.addGratitude(Gratitude(text: t)); gratCtrl.clear(); }
                },
                child: const Text('+'),
              ),
            ]),
          ]),
        ),
        // Journal entries
        if (prov.journal.isEmpty)
          AppCard(child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const Text('📖', style: TextStyle(fontSize: 38)),
                const SizedBox(height: 8),
                Text('Günlük yazıların burada.', style: TextStyle(color: muted)),
              ]),
            ),
          ))
        else
          ...prov.journal.take(20).map((j) => AppCard(
            borderColor: AppTheme.purple,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(j.mood, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(child: Text(j.date,
                    style: GoogleFonts.spaceMono(fontSize: 10, color: muted))),
                GestureDetector(
                  onTap: () => prov.deleteJournal(j.id),
                  child: Text('✕', style: TextStyle(color: muted)),
                ),
              ]),
              if (j.title.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(j.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ],
              const SizedBox(height: 6),
              Text(j.text.length > 280 ? '${j.text.substring(0, 280)}...' : j.text,
                  style: const TextStyle(fontSize: 13, height: 1.7)),
            ]),
          )),
      ]),
    );
  }

  void _addJournalModal(BuildContext ctx, AppProvider prov) {
    final titleCtrl = TextEditingController();
    final textCtrl = TextEditingController();
    String mood = '😊';
    showAppModal(ctx, child: StatefulBuilder(builder: (ctx, ss) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('📝 Günlük Yaz', size: 20),
        const SizedBox(height: 16),
        const Text('Başlık (opsiyonel)', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Başlık...')),
        const SizedBox(height: 12),
        const Text('Ruh Hali', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        Row(children: ['😄','🙂','😐','😔','😤','🎉','😴','🤔'].map((e) => GestureDetector(
          onTap: () => ss(() => mood = e),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(e, style: TextStyle(fontSize: mood == e ? 28 : 20)),
          ),
        )).toList()),
        const SizedBox(height: 12),
        const Text('Yazı', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: textCtrl, maxLines: 6, decoration: const InputDecoration(hintText: 'Bugün nasıldı?')),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final t = textCtrl.text.trim();
              if (t.isEmpty) return;
              prov.addJournal(JournalEntry(title: titleCtrl.text.trim(), text: t, mood: mood));
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          )),
        ]),
      ],
    )));
  }
}

// ════════════════════════════════════════════════════════════
// SUGGESTIONS SCREEN
// ════════════════════════════════════════════════════════════
const Map<String, String> _suggIcons = {
  'kitap': '📚', 'film': '🎬', 'muzik': '🎵', 'spor': '💪', 'podcast': '🎙️',
};
const Map<String, List<String>> _suggDB = {
  'kitap': ["Atomik Alışkanlıklar - James Clear","Küçük Prens","1984 - George Orwell","Sapiens","Simyacı - Paulo Coelho"],
  'film': ["Everything Everywhere All at Once","The Pursuit of Happyness","Soul (Pixar)","Whiplash","A Beautiful Mind"],
  'muzik': ["Lo-fi chill beats","Klasik müzik çalışma modu","Jazz sabah playlist","Bossa Nova öğleden sonra"],
  'spor': ["Sabah 10 dk yoga","30 günlük plank challenge","Akşam yürüyüşü","Evde HIIT","Pilates başlangıç"],
  'podcast': ["Huberman Lab","Lex Fridman Podcast","Tim Ferriss Show","Türkçe: Şunu Bi Düşün"],
};

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});
  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  String _filter = 'all';
  Suggestion? _aiSugg;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final filtered = _filter == 'all'
        ? prov.suggestions
        : prov.suggestions.where((s) => s.type == _filter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(
          title: '💡 Öneri Kutusu',
          subtitle: 'Kitap, film, müzik, spor — keşfet!',
        ),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            ChipButton(label: 'Tümü', active: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
            ..._suggIcons.entries.map((e) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: ChipButton(
                label: '${e.value} ${e.key[0].toUpperCase()}${e.key.substring(1)}',
                active: _filter == e.key,
                onTap: () => setState(() => _filter = e.key),
              ),
            )),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          ElevatedButton(
            onPressed: () => _addModal(context, prov),
            child: const Text('+ Öneri Ekle'),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: _genSugg,
            child: const Text('✨ Bana Öner'),
          ),
        ]),
        const SizedBox(height: 12),
        // AI Suggestion
        if (_aiSugg != null)
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(_suggIcons[_aiSugg!.type] ?? '💡', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(_aiSugg!.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text('${_aiSugg!.type} önerisi', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                onPressed: () {
                  prov.addSuggestion(_aiSugg!);
                  setState(() { _filter = 'all'; _aiSugg = null; });
                },
                child: const Text('Listeye Ekle'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => setState(() => _aiSugg = null),
                child: const Text('Kapat'),
              ),
            ]),
          ])),
        // List
        if (filtered.isEmpty)
          AppCard(child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Öneri yok. Ekle veya ✨ "Bana Öner"e tıkla!',
                  style: TextStyle(color: muted, fontSize: 13), textAlign: TextAlign.center),
            ),
          ))
        else
          ...filtered.map((s) => AppCard(
            child: Row(children: [
              Text(_suggIcons[s.type] ?? '💡', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                if (s.note.isNotEmpty) Text(s.note, style: TextStyle(fontSize: 12, color: muted)),
              ])),
              GestureDetector(
                onTap: () => prov.deleteSuggestion(s.id),
                child: Text('✕', style: TextStyle(color: muted)),
              ),
            ]),
          )),
      ]),
    );
  }

  void _genSugg() {
    final types = _filter != 'all' && _suggDB.containsKey(_filter)
        ? [_filter]
        : _suggDB.keys.toList();
    final type = types[DateTime.now().millisecond % types.length];
    final list = _suggDB[type]!;
    final pick = list[DateTime.now().microsecond % list.length];
    setState(() => _aiSugg = Suggestion(title: pick, type: type, note: '✨ Öneri kutusu'));
  }

  void _addModal(BuildContext ctx, AppProvider prov) {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String type = _filter != 'all' ? _filter : 'kitap';
    showAppModal(ctx, child: StatefulBuilder(builder: (ctx, ss) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('💡 Öneri Ekle', size: 20),
        const SizedBox(height: 16),
        const Text('Başlık', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Kitap/Film adı...')),
        const SizedBox(height: 12),
        const Text('Tür', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: type,
          items: _suggIcons.entries.map((e) =>
              DropdownMenuItem(value: e.key, child: Text('${e.value} ${e.key}'))).toList(),
          onChanged: (v) => ss(() => type = v!),
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 12),
        const Text('Not', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Neden öneriyorsun?')),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              if (t.isEmpty) return;
              prov.addSuggestion(Suggestion(title: t, type: type, note: noteCtrl.text.trim()));
              setState(() => _filter = 'all');
              Navigator.pop(ctx);
            },
            child: const Text('Ekle'),
          )),
        ]),
      ],
    )));
  }
}

// ════════════════════════════════════════════════════════════
// LETTER SCREEN
// ════════════════════════════════════════════════════════════
class LetterScreen extends StatelessWidget {
  const LetterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final letter = prov.letter;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const SectionHeader(title: '💌 Geleceğe Mektup', subtitle: '1 yıl sonraki kendinle konuş.'),
        if (letter == null || (!letter.isUnlocked))
          AppCard(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Center(child: Text('🔒', style: TextStyle(fontSize: 44))),
            const SizedBox(height: 10),
            Center(child: frauncesText('Mektup Kilitli', size: 18)),
            const SizedBox(height: 6),
            Center(child: Text(
              letter == null ? 'Henüz mektup yazılmamış.' :
                  'Mektup ${letter.unlockAt} tarihinde açılacak.',
              style: const TextStyle(color: AppTheme.mutedDark, fontSize: 13),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _writeModal(context, prov),
              child: const Text('Mektup Yaz ✍️'),
            ),
          ]))
        else
          AppCard(
            borderColor: AppTheme.gold,
            child: Column(children: [
              const Text('💌', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              frauncesText('Mektubun Açıldı!', size: 18),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface2Dark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Text(letter.text,
                    style: const TextStyle(fontStyle: FontStyle.italic, height: 1.8, fontSize: 13)),
              ),
              const SizedBox(height: 8),
              Text('Yazıldı: ${letter.writtenAt}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _writeModal(context, prov),
                child: const Text('Yeni Mektup'),
              ),
            ]),
          ),
      ]),
    );
  }

  void _writeModal(BuildContext ctx, AppProvider prov) {
    final ctrl = TextEditingController();
    showAppModal(ctx, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('💌 Geleceğe Mektup', size: 20),
        const SizedBox(height: 6),
        const Text('Bu mektup tam 1 yıl sonra açılacak.', style: TextStyle(fontSize: 12, color: AppTheme.mutedDark)),
        const SizedBox(height: 12),
        TextField(controller: ctrl, maxLines: 10, decoration: const InputDecoration(hintText: 'Sevgili ben,\n\nBu yıl...')),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) return;
              prov.saveLetter(t);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Mektup mühürlendi! 💌')));
            },
            child: const Text('Mühürle 💌'),
          )),
        ]),
      ],
    ));
  }
}

// ════════════════════════════════════════════════════════════
// SLEEP SCREEN
// ════════════════════════════════════════════════════════════
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});
  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  TimeOfDay _wake = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _bed = const TimeOfDay(hour: 23, minute: 0);
  int _quality = 3;

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  double _calcHours() {
    var mins = (_wake.hour * 60 + _wake.minute) - (_bed.hour * 60 + _bed.minute);
    if (mins < 0) mins += 24 * 60;
    return mins / 60;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final accent = prov.accentColor;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final hours = _calcHours();
    final hist = prov.last7Sleep;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const SectionHeader(title: '😴 Uyku Takibi'),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(title: 'Bu Gece'),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Kalkma Saati', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: _wake);
                  if (t != null) setState(() => _wake = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  ),
                  child: Text(_fmtTime(_wake),
                      style: GoogleFonts.spaceMono(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Yatma Saati', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: _bed);
                  if (t != null) setState(() => _bed = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  ),
                  child: Text(_fmtTime(_bed),
                      style: GoogleFonts.spaceMono(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ])),
          ]),
          const SizedBox(height: 16),
          const Text('Kalite', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
          Row(children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _quality = i + 1),
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text('⭐', style: TextStyle(fontSize: i < _quality ? 24 : 16, color: i < _quality ? AppTheme.gold : muted)),
            ),
          ))),
          const SizedBox(height: 12),
          Center(child: Text('${hours.toStringAsFixed(1)} saat',
              style: GoogleFonts.spaceMono(fontSize: 28, fontWeight: FontWeight.w700, color: accent))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              final today = prov.todayStr;
              prov.addSleep(SleepLog(date: today, bedTime: _fmtTime(_bed), wakeTime: _fmtTime(_wake), quality: _quality));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Uyku kaydedildi! 😴')));
            },
            child: const Text('Kaydet'),
          )),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(title: 'Son 7 Gün'),
          const SizedBox(height: 10),
          if (hist.isEmpty)
            Text('Henüz kayıt yok.', style: TextStyle(color: muted, fontSize: 13))
          else
            ...hist.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.date, style: GoogleFonts.spaceMono(fontSize: 11, color: muted)),
                  Text('${s.hours.toStringAsFixed(1)} saat',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ])),
                Row(children: List.generate(s.quality, (_) => const Text('⭐', style: TextStyle(fontSize: 12)))),
              ]),
            )),
        ])),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SOCIAL SCREEN
// ════════════════════════════════════════════════════════════
class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    String? selGoal = prov.goals.isNotEmpty ? prov.goals.first.name : null;
    final friendCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        const SectionHeader(title: '👥 Sosyal Pano', subtitle: 'Hedeflerini paylaş, ilham ver!'),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(title: '📤 Hedef Paylaş'),
          const SizedBox(height: 12),
          if (prov.goals.isEmpty)
            Text('Önce hedef ekle!', style: TextStyle(color: muted))
          else
            StatefulBuilder(builder: (ctx, ss) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selGoal,
                  items: prov.goals.map((g) =>
                      DropdownMenuItem(value: g.name, child: Text(g.name))).toList(),
                  onChanged: (v) => ss(() => selGoal = v),
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: 10),
                TextField(controller: friendCtrl, decoration: const InputDecoration(hintText: 'Arkadaşın adı...')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (selGoal != null && friendCtrl.text.trim().isNotEmpty) {
                      prov.shareGoal(selGoal!, friendCtrl.text.trim());
                      friendCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hedef paylaşıldı! 📤')));
                    }
                  },
                  child: const Text('Paylaş 📤'),
                ),
              ],
            )),
        ])),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(title: '🌟 İlham Panosu'),
          const SizedBox(height: 10),
          if (prov.sharedGoals.isEmpty)
            Text('Henüz paylaşım yok.', style: TextStyle(color: muted, fontSize: 13))
          else
            ...prov.sharedGoals.map((g) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                const Text('🌟', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${g['friendName']} → ${g['goalName']}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(g['date'] ?? '', style: TextStyle(fontSize: 10, color: muted)),
                ])),
              ]),
            )),
        ])),
      ]),
    );
  }
}
