// ═══════════════════════════════════════════════════════════
// BINGO SCREEN
// ═══════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class BingoScreen extends StatefulWidget {
  const BingoScreen({super.key});
  @override
  State<BingoScreen> createState() => _BingoScreenState();
}

class _BingoScreenState extends State<BingoScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _year = n.year;
    _month = n.month;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final accent = prov.accentColor;
    final isDark = prov.isDark;
    final targets = prov.getBingoTargets(_year, _month);
    final done = prov.getBingoDone(_year, _month);
    final doneCount = done.length;
    final months = ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        SectionHeader(
          title: '🎯 Bingo',
          subtitle: 'Aylık hedef bingonu tamamla!',
          action: ElevatedButton(
            onPressed: () => _editModal(context, prov, targets),
            child: const Text('Düzenle'),
          ),
        ),
        // Month nav
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {
            setState(() {
              if (_month == 1) { _month = 12; _year--; } else _month--;
            });
          }),
          Text('${months[_month - 1]} $_year',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.w700, fontSize: 15)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {
            setState(() {
              if (_month == 12) { _month = 1; _year++; } else _month++;
            });
          }),
        ]),
        // Score
        Text('$doneCount / 25',
            style: GoogleFonts.spaceMono(fontSize: 28, fontWeight: FontWeight.w700, color: accent)),
        AppProgressBar(value: doneCount / 25),
        const SizedBox(height: 16),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, crossAxisSpacing: 5, mainAxisSpacing: 5, childAspectRatio: 1),
          itemCount: 25,
          itemBuilder: (_, i) {
            final isDone = done.contains(i.toString());
            return GestureDetector(
              onTap: () => prov.toggleBingo(_year, _month, i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isDone ? accent : (isDark ? AppTheme.surface2Dark : AppTheme.surface2Light),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isDone ? accent : (isDark ? AppTheme.borderDark : AppTheme.borderLight)),
                ),
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Center(
                      child: Text(
                        i < targets.length ? targets[i] : '',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: isDone ? Colors.black : null,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isDone)
                    const Positioned(top: 2, right: 4,
                        child: Text('✓', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black))),
                ]),
              ),
            );
          },
        ),
      ]),
    );
  }

  void _editModal(BuildContext ctx, AppProvider prov, List<String> current) {
    final ctrl = TextEditingController(text: current.join('\n'));
    showAppModal(ctx, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        frauncesText('✏️ Bingo Hedefleri', size: 20),
        const SizedBox(height: 6),
        const Text('25 hedef (her satıra bir tane)', style: TextStyle(fontSize: 12, color: AppTheme.mutedDark)),
        const SizedBox(height: 12),
        TextField(controller: ctrl, maxLines: 12, decoration: const InputDecoration(hintText: 'Spor yap\nKitap oku\n...')),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: () {
              var lines = ctrl.text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
              while (lines.length < 25) lines.add('Hedef ${lines.length + 1}');
              prov.saveBingoTargets(_year, _month, lines.take(25).toList());
              Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          )),
        ]),
      ],
    ));
  }
}
