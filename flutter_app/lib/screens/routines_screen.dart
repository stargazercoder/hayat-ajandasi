import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

const List<String> _gunler = ['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'];
const List<String> _gunEmoji = ['💪','🦵','🏃','🔥','✊','🌟','😴'];

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});
  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  String _tab = 'spor';

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final isDark = prov.isDark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: '🗒️ Rutin & Not Defteri',
            subtitle: 'Spor programı, cilt bakımı, notlar — hepsi burada.'),
        // Tab bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            ChipButton(label: '💪 Spor', active: _tab == 'spor', onTap: () => setState(() => _tab = 'spor')),
            const SizedBox(width: 4),
            ChipButton(label: '📓 Notlarım', active: _tab == 'not', onTap: () => setState(() => _tab = 'not')),
            const SizedBox(width: 4),
            ChipButton(label: '🍽️ Tarifler', active: _tab == 'tarif', onTap: () => setState(() => _tab = 'tarif')),
            const SizedBox(width: 4),
            ChipButton(label: '📌 Diğer', active: _tab == 'diger', onTap: () => setState(() => _tab = 'diger')),
          ]),
        ),
        const SizedBox(height: 14),
        if (_tab == 'spor') _SportTab(prov: prov)
        else _NotesTab(prov: prov, kategori: _tab),
      ]),
    );
  }
}

class _SportTab extends StatefulWidget {
  final AppProvider prov;
  const _SportTab({required this.prov});

  @override
  State<_SportTab> createState() => _SportTabState();
}

class _SportTabState extends State<_SportTab> {
  int _selDayIdx = (DateTime.now().weekday - 1) % 7;

  @override
  Widget build(BuildContext context) {
    final prov = widget.prov;
    final isDark = prov.isDark;
    final accent = prov.accentColor;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final programs = prov.getSportForDay(_gunler[_selDayIdx]);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppCard(
        borderColor: AppTheme.accent2,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(
            title: '💪 Spor Programı',
            action: ElevatedButton(
              onPressed: () => _addSportModal(context, prov),
              child: const Text('+ Ekle'),
            ),
          ),
          const SizedBox(height: 12),
          // Day tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_gunler.length, (i) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _selDayIdx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selDayIdx == i ? accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: _selDayIdx == i ? accent : (isDark ? AppTheme.borderDark : AppTheme.borderLight)),
                    ),
                    child: Text(
                      '${_gunEmoji[i]} ${_gunler[i].substring(0, 3)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _selDayIdx == i ? FontWeight.w700 : FontWeight.normal,
                        color: _selDayIdx == i ? Colors.black : null,
                      ),
                    ),
                  ),
                ),
              )),
            ),
          ),
          const SizedBox(height: 12),
          if (programs.isEmpty)
            Center(child: Text('${_gunler[_selDayIdx]} için program yok.', style: TextStyle(color: muted, fontSize: 13)))
          else
            ...programs.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.ad, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  if (p.icerik.isNotEmpty)
                    Text(p.icerik, style: TextStyle(fontSize: 12, color: muted, height: 1.5)),
                ])),
                GestureDetector(
                  onTap: () => prov.deleteSportProgram(p.id),
                  child: Text('✕', style: TextStyle(color: muted)),
                ),
              ]),
            )),
        ]),
      ),
      // Body measurements
      AppCard(
        borderColor: AppTheme.accent3,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CardTitle(
            title: '📏 Vücut Ölçümleri',
            action: ElevatedButton(
              onPressed: () => _addMeasurementModal(context, prov),
              child: const Text('+ Ekle'),
            ),
          ),
          const SizedBox(height: 10),
          if (prov.measurements.isEmpty)
            Text('Henüz ölçüm yok.', style: TextStyle(color: muted, fontSize: 13))
          else
            ...prov.measurements.take(3).map((m) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
                borderRadius: BorderRadius.circular(12),
                border: prov.measurements.first.id == m.id
                    ? Border.all(color: AppTheme.accent3) : null,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(prov.measurements.first.id == m.id ? '🔵 Son Ölçüm' : '⚪ Önceki',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text(m.date, style: TextStyle(fontSize: 11, color: muted, fontFamily: 'monospace')),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => prov.deleteMeasurement(m.id),
                    child: Text('✕', style: TextStyle(color: muted)),
                  ),
                ]),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12, runSpacing: 6,
                  children: m.values.entries.map((e) => Text(
                    '${_olcumEmoji[e.key] ?? ''} ${_olcumLabel[e.key] ?? e.key}: ${e.value} ${_olcumUnit[e.key] ?? ''}',
                    style: const TextStyle(fontSize: 12),
                  )).toList(),
                ),
              ]),
            )),
        ]),
      ),
    ]);
  }

  void _addSportModal(BuildContext ctx, AppProvider prov) {
    final adCtrl = TextEditingController();
    final icerikCtrl = TextEditingController();
    String gun = _gunler[_selDayIdx];
    String emoji = '💪';
    final emojis = ['💪','🏃','🦵','🔥','🧘','🏋️','⚽','🏊','🚴','✊'];
    showAppModal(ctx, child: StatefulBuilder(builder: (ctx, ss) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('💪 Program Ekle', size: 20),
        const SizedBox(height: 16),
        const Text('Gün', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: gun,
          items: _gunler.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => ss(() => gun = v!),
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 12),
        const Text('Emoji', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: emojis.map((e) => GestureDetector(
            onTap: () => ss(() => emoji = e),
            child: Text(e, style: TextStyle(fontSize: emoji == e ? 30 : 20)),
          )).toList(),
        ),
        const SizedBox(height: 12),
        const Text('Antrenman Adı', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: adCtrl, decoration: const InputDecoration(hintText: 'Bacak Günü, Göğüs...')),
        const SizedBox(height: 12),
        const Text('İçerik', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: icerikCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Squat 4x10\nDeadlift 3x8\n...')),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final ad = adCtrl.text.trim();
              if (ad.isEmpty) return;
              prov.addSportProgram(SportProgram(gun: gun, ad: ad, icerik: icerikCtrl.text.trim(), emoji: emoji));
              setState(() => _selDayIdx = _gunler.indexOf(gun));
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          )),
        ]),
      ],
    )));
  }

  void _addMeasurementModal(BuildContext ctx, AppProvider prov) {
    final ctrls = {for (final k in _olcumKeys) k: TextEditingController()};
    final noteCtrl = TextEditingController();
    showAppModal(ctx, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('📏 Ölçüm Ekle', size: 20),
        const SizedBox(height: 16),
        ...List.generate((_olcumKeys.length / 2).ceil(), (row) {
          final i = row * 2;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Expanded(child: _olcumField(ctrls[_olcumKeys[i]]!, _olcumKeys[i])),
              if (i + 1 < _olcumKeys.length) ...[
                const SizedBox(width: 10),
                Expanded(child: _olcumField(ctrls[_olcumKeys[i + 1]]!, _olcumKeys[i + 1])),
              ],
            ]),
          );
        }),
        const SizedBox(height: 6),
        const Text('Not', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: noteCtrl, decoration: const InputDecoration(hintText: 'Opsiyonel not...')),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              final values = <String, double>{};
              ctrls.forEach((k, c) {
                final v = double.tryParse(c.text);
                if (v != null) values[k] = v;
              });
              if (values.isEmpty) return;
              prov.addMeasurement(BodyMeasurement(
                date: prov.todayStr, values: values, note: noteCtrl.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          )),
        ]),
      ],
    ));
  }

  Widget _olcumField(TextEditingController ctrl, String key) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('${_olcumEmoji[key] ?? ''} ${_olcumLabel[key] ?? key}',
          style: const TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
      const SizedBox(height: 4),
      TextField(controller: ctrl, keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: _olcumUnit[key] ?? '')),
    ],
  );
}

const List<String> _olcumKeys = ['kilo','boy','bel','kalca','gogus','omuz','biceps','uyluk'];
const Map<String, String> _olcumLabel = {
  'kilo': 'Kilo','boy': 'Boy','bel': 'Bel','kalca': 'Kalça',
  'gogus': 'Göğüs','omuz': 'Omuz','biceps': 'Biceps','uyluk': 'Uyluk',
};
const Map<String, String> _olcumUnit = {
  'kilo': 'kg','boy': 'cm','bel': 'cm','kalca': 'cm',
  'gogus': 'cm','omuz': 'cm','biceps': 'cm','uyluk': 'cm',
};
const Map<String, String> _olcumEmoji = {
  'kilo': '⚖️','boy': '📐','bel': '👗','kalca': '🩳',
  'gogus': '💪','omuz': '🦾','biceps': '💪','uyluk': '🦵',
};

class _NotesTab extends StatelessWidget {
  final AppProvider prov;
  final String kategori;
  const _NotesTab({required this.prov, required this.kategori});

  @override
  Widget build(BuildContext context) {
    final isDark = prov.isDark;
    final muted = isDark ? AppTheme.mutedDark : AppTheme.mutedLight;
    final notes = prov.notes.where((n) => n.kategori == kategori).toList();
    final titles = {'not': '📓 Notlarım', 'tarif': '🍽️ Tarifler', 'diger': '📌 Diğer'};

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        ElevatedButton(
          onPressed: () => _addNoteModal(context, prov, kategori),
          child: Text('+ ${kategori == "tarif" ? "Tarif Ekle" : "Yeni Not"}'),
        ),
      ]),
      const SizedBox(height: 10),
      if (notes.isEmpty)
        AppCard(child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Text(kategori == 'tarif' ? '🍽️' : '📓', style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text('Henüz ${kategori == "tarif" ? "tarif" : "not"} yok.',
                  style: TextStyle(color: muted)),
            ]),
          ),
        ))
      else
        ...notes.map((n) => _noteCard(n, prov, muted)),
    ]);
  }

  Widget _noteCard(AppNote n, AppProvider prov, Color muted) {
    Color borderColor;
    try {
      borderColor = Color(int.parse(n.renk.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      borderColor = AppTheme.accent;
    }

    return AppCard(
      borderColor: borderColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (n.pin) const Text('📌', style: TextStyle(fontSize: 13)),
          if (n.baslik.isNotEmpty) Expanded(
            child: Text(n.baslik, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ) else const Spacer(),
          GestureDetector(
            onTap: () => prov.deleteNote(n.id),
            child: Text('✕', style: TextStyle(color: muted, fontSize: 13)),
          ),
        ]),
        if (n.icerik.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(n.icerik.length > 400 ? '${n.icerik.substring(0, 400)}...' : n.icerik,
              style: const TextStyle(fontSize: 13, height: 1.65)),
        ],
        const SizedBox(height: 6),
        Text(n.tarih, style: TextStyle(fontSize: 10, color: muted, fontFamily: 'monospace')),
      ]),
    );
  }

  void _addNoteModal(BuildContext ctx, AppProvider prov, String kat) {
    final baslikCtrl = TextEditingController();
    final icerikCtrl = TextEditingController();
    String renk = '#C8F04A';
    bool pin = false;
    final renkler = {
      '#C8F04A': '🟢', '#A78BFA': '🟣', '#FF6B6B': '🔴',
      '#F0A84A': '🟠', '#4AF0C8': '🔵', '#FFD700': '🟡',
    };
    showAppModal(ctx, child: StatefulBuilder(builder: (ctx, ss) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText(kat == 'tarif' ? '🍽️ Tarif/Reçete' : '📓 Not Ekle', size: 20),
        const SizedBox(height: 16),
        const Text('Başlık', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: baslikCtrl, decoration: const InputDecoration(hintText: 'Not başlığı...')),
        const SizedBox(height: 12),
        const Text('İçerik', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        TextField(controller: icerikCtrl, maxLines: 6, decoration: const InputDecoration(hintText: 'Notunu yaz...')),
        const SizedBox(height: 12),
        const Text('Renk', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
        const SizedBox(height: 5),
        Row(children: renkler.entries.map((e) => GestureDetector(
          onTap: () => ss(() => renk = e.key),
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(e.value, style: TextStyle(fontSize: renk == e.key ? 28 : 20)),
          ),
        )).toList()),
        const SizedBox(height: 12),
        Row(children: [
          const Text('Sabitle', style: TextStyle(fontSize: 11, color: AppTheme.mutedDark)),
          const Spacer(),
          Switch(value: pin, onChanged: (v) => ss(() => pin = v)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              if (baslikCtrl.text.trim().isEmpty && icerikCtrl.text.trim().isEmpty) return;
              prov.addNote(AppNote(
                kategori: kat,
                baslik: baslikCtrl.text.trim(),
                icerik: icerikCtrl.text.trim(),
                renk: renk,
                pin: pin,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          )),
        ]),
      ],
    )));
  }
}
