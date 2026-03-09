import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AppProvider extends ChangeNotifier {
  static const _localKey = 'haj_flutter_1';
  static const _table    = 'user_data';

  SupabaseClient get _sb => Supabase.instance.client;

  bool _syncing = false;
  bool get syncing => _syncing;
  String? syncError;

  // User
  String userName = '';
  String agendaName = 'Hayat Ajandası';
  double salary = 0;
  bool isDark = true;
  Color accentColor = AppTheme.accent;

  // Data
  List<Todo> todos = [];
  List<Goal> goals = [];
  List<Expense> expenses = [];
  List<Saving> savings = [];
  List<JournalEntry> journal = [];
  List<Gratitude> gratitude = [];
  List<Suggestion> suggestions = [];
  List<SleepLog> sleepLogs = [];
  List<MoodLog> moodLogs = [];
  List<AppNote> notes = [];
  List<BodyMeasurement> measurements = [];
  List<SportProgram> sportPrograms = [];
  FutureLetter? letter;
  Map<String, dynamic> bingoData = {};
  Map<String, String> dailyAnswers = {};
  List<Map<String, dynamic>> sharedGoals = [];

  bool _loaded = false;
  bool get loaded => _loaded;

  String get todayStr {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  // ─── LOAD/SAVE ───────────────────────────────────────────────────────────

  // Tüm veriyi map'e çevirir (hem local hem cloud için)
  Map<String, dynamic> _toMap() => {
    'userName': userName,
    'agendaName': agendaName,
    'salary': salary,
    'isDark': isDark,
    'accentColor': accentColor.value,
    'todos': todos.map((e) => e.toJson()).toList(),
    'goals': goals.map((e) => e.toJson()).toList(),
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'savings': savings.map((e) => e.toJson()).toList(),
    'journal': journal.map((e) => e.toJson()).toList(),
    'gratitude': gratitude.map((e) => e.toJson()).toList(),
    'suggestions': suggestions.map((e) => e.toJson()).toList(),
    'sleepLogs': sleepLogs.map((e) => e.toJson()).toList(),
    'moodLogs': moodLogs.map((e) => e.toJson()).toList(),
    'notes': notes.map((e) => e.toJson()).toList(),
    'measurements': measurements.map((e) => e.toJson()).toList(),
    'sportPrograms': sportPrograms.map((e) => e.toJson()).toList(),
    'bingoData': bingoData,
    'dailyAnswers': dailyAnswers,
    'sharedGoals': sharedGoals,
    'letter': letter?.toJson(),
  };

  void _fromMap(Map<String, dynamic> d) {
    userName    = d['userName']  ?? '';
    agendaName  = d['agendaName'] ?? 'Hayat Ajandası';
    salary      = (d['salary'] as num?)?.toDouble() ?? 0;
    isDark      = d['isDark']   ?? true;
    final ac    = d['accentColor'];
    if (ac != null) accentColor = Color(ac as int);
    todos         = (d['todos']         as List? ?? []).map((e) => Todo.fromJson(e)).toList();
    goals         = (d['goals']         as List? ?? []).map((e) => Goal.fromJson(e)).toList();
    expenses      = (d['expenses']      as List? ?? []).map((e) => Expense.fromJson(e)).toList();
    savings       = (d['savings']       as List? ?? []).map((e) => Saving.fromJson(e)).toList();
    journal       = (d['journal']       as List? ?? []).map((e) => JournalEntry.fromJson(e)).toList();
    gratitude     = (d['gratitude']     as List? ?? []).map((e) => Gratitude.fromJson(e)).toList();
    suggestions   = (d['suggestions']   as List? ?? []).map((e) => Suggestion.fromJson(e)).toList();
    sleepLogs     = (d['sleepLogs']     as List? ?? []).map((e) => SleepLog.fromJson(e)).toList();
    moodLogs      = (d['moodLogs']      as List? ?? []).map((e) => MoodLog.fromJson(e)).toList();
    notes         = (d['notes']         as List? ?? []).map((e) => AppNote.fromJson(e)).toList();
    measurements  = (d['measurements']  as List? ?? []).map((e) => BodyMeasurement.fromJson(e)).toList();
    sportPrograms = (d['sportPrograms'] as List? ?? []).map((e) => SportProgram.fromJson(e)).toList();
    bingoData     = Map<String, dynamic>.from(d['bingoData']   ?? {});
    dailyAnswers  = Map<String, String>.from(d['dailyAnswers'] ?? {});
    sharedGoals   = List<Map<String, dynamic>>.from(d['sharedGoals'] ?? []);
    if (d['letter'] != null) letter = FutureLetter.fromJson(d['letter']);
  }

  Future<void> load() async {
    // 1) Önce anonim giriş yap / mevcut oturumu al
    final session = _sb.auth.currentSession;
    if (session == null) {
      try {
        await _sb.auth.signInAnonymously();
      } catch (_) {}
    }

    // 2) Supabase'den çek (önce cloud)
    try {
      final uid = _sb.auth.currentUser?.id;
      if (uid != null) {
        final row = await _sb
            .from(_table)
            .select('data')
            .eq('user_id', uid)
            .maybeSingle();
        if (row != null && row['data'] != null) {
          _fromMap(Map<String, dynamic>.from(row['data'] as Map));
          // Cloud'u lokale yedekle
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_localKey, jsonEncode(row['data']));
          _loaded = true;
          notifyListeners();
          return;
        }
      }
    } catch (_) {}

    // 3) Cloud yoksa / hata varsa lokalden yükle
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw != null) {
      try { _fromMap(jsonDecode(raw) as Map<String, dynamic>); } catch (_) {}
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> save() async {
    final map = _toMap();

    // 1) Lokale hemen yaz (offline-first)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(map));

    // 2) Supabase'e arka planda gönder
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;

    _syncing = true;
    syncError = null;
    notifyListeners();

    try {
      await _sb.from(_table).upsert({
        'user_id': uid,
        'data': map,
      });
      syncError = null;
    } catch (e) {
      syncError = e.toString();
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  // ─── USER ────────────────────────────────────────────────────────────────
  void setupUser(String name, String aname, double sal, bool dark, Color accent) {
    userName = name;
    agendaName = aname.isNotEmpty ? aname : "$name'nın Ajandası";
    salary = sal;
    isDark = dark;
    accentColor = accent;
    save();
    notifyListeners();
  }

  void toggleTheme() { isDark = !isDark; save(); notifyListeners(); }
  void setAccent(Color c) { accentColor = c; save(); notifyListeners(); }

  // ─── MOOD ────────────────────────────────────────────────────────────────
  void logMood(String emoji) {
    moodLogs.removeWhere((m) => m.date == todayStr);
    moodLogs.add(MoodLog(date: todayStr, emoji: emoji));
    save(); notifyListeners();
  }
  String? get todayMood => moodLogs.where((m) => m.date == todayStr).isNotEmpty
      ? moodLogs.firstWhere((m) => m.date == todayStr).emoji : null;

  // ─── TODOS ───────────────────────────────────────────────────────────────
  void addTodo(Todo t) { todos.add(t); save(); notifyListeners(); }
  void toggleTodo(String id) {
    final t = todos.firstWhere((t) => t.id == id);
    t.done = !t.done;
    save(); notifyListeners();
  }
  void deleteTodo(String id) { todos.removeWhere((t) => t.id == id); save(); notifyListeners(); }

  // ─── GOALS ───────────────────────────────────────────────────────────────
  void addGoal(Goal g) { goals.add(g); save(); notifyListeners(); }
  void deleteGoal(String id) { goals.removeWhere((g) => g.id == id); save(); notifyListeners(); }
  void toggleGoalDay(String id) {
    final g = goals.firstWhere((g) => g.id == id);
    if (g.doneDates.contains(todayStr)) {
      g.doneDates.remove(todayStr);
    } else {
      g.doneDates.add(todayStr);
    }
    save(); notifyListeners();
  }

  // ─── EXPENSES ────────────────────────────────────────────────────────────
  void addExpense(Expense e) { expenses.add(e); save(); notifyListeners(); }
  void deleteExpense(String id) { expenses.removeWhere((e) => e.id == id); save(); notifyListeners(); }
  double get totalExpenses => expenses.fold(0, (s, e) => s + e.amount);
  double get remainingBudget => salary - totalExpenses;

  // ─── SAVINGS ─────────────────────────────────────────────────────────────
  void addSaving(Saving s) { savings.add(s); save(); notifyListeners(); }
  void deleteSaving(String id) { savings.removeWhere((s) => s.id == id); save(); notifyListeners(); }
  void updateSaving(String id, double amount) {
    final s = savings.firstWhere((s) => s.id == id);
    s.current = (s.current + amount).clamp(0, s.target);
    save(); notifyListeners();
  }

  // ─── JOURNAL ─────────────────────────────────────────────────────────────
  void addJournal(JournalEntry e) { journal.insert(0, e); save(); notifyListeners(); }
  void deleteJournal(String id) { journal.removeWhere((e) => e.id == id); save(); notifyListeners(); }
  void addGratitude(Gratitude g) { gratitude.add(g); save(); notifyListeners(); }
  void deleteGratitude(String id) { gratitude.removeWhere((g) => g.id == id); save(); notifyListeners(); }
  List<Gratitude> get todayGratitude => gratitude.where((g) => g.date == todayStr).toList();

  // ─── SUGGESTIONS ─────────────────────────────────────────────────────────
  void addSuggestion(Suggestion s) { suggestions.insert(0, s); save(); notifyListeners(); }
  void deleteSuggestion(String id) { suggestions.removeWhere((s) => s.id == id); save(); notifyListeners(); }

  // ─── SLEEP ───────────────────────────────────────────────────────────────
  void addSleep(SleepLog s) {
    sleepLogs.removeWhere((l) => l.date == s.date);
    sleepLogs.add(s);
    save(); notifyListeners();
  }
  List<SleepLog> get last7Sleep {
    final result = <SleepLog>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final log = sleepLogs.where((s) => s.date == key).isNotEmpty
          ? sleepLogs.firstWhere((s) => s.date == key) : null;
      if (log != null) result.add(log);
    }
    return result;
  }

  // ─── NOTES ───────────────────────────────────────────────────────────────
  void addNote(AppNote n) {
    notes.insert(0, n);
    notes.sort((a, b) => (b.pin ? 1 : 0) - (a.pin ? 1 : 0));
    save(); notifyListeners();
  }
  void deleteNote(String id) { notes.removeWhere((n) => n.id == id); save(); notifyListeners(); }

  // ─── SPORT ───────────────────────────────────────────────────────────────
  void addSportProgram(SportProgram p) { sportPrograms.add(p); save(); notifyListeners(); }
  void deleteSportProgram(String id) { sportPrograms.removeWhere((p) => p.id == id); save(); notifyListeners(); }
  List<SportProgram> getSportForDay(String gun) => sportPrograms.where((p) => p.gun == gun).toList();

  // ─── MEASUREMENTS ────────────────────────────────────────────────────────
  void addMeasurement(BodyMeasurement m) { measurements.insert(0, m); save(); notifyListeners(); }
  void deleteMeasurement(String id) { measurements.removeWhere((m) => m.id == id); save(); notifyListeners(); }

  // ─── BINGO ───────────────────────────────────────────────────────────────
  List<String> getBingoTargets(int year, int month) {
    final key = '$year-$month';
    final data = bingoData[key] as Map<String, dynamic>?;
    if (data == null) return List<String>.from(_defaultBingo);
    return List<String>.from(data['targets'] ?? _defaultBingo);
  }

  List<String> getBingoDone(int year, int month) {
    final key = '$year-$month';
    final data = bingoData[key] as Map<String, dynamic>?;
    return List<String>.from(data?['done'] ?? []);
  }

  void toggleBingo(int year, int month, int index) {
    final key = '$year-$month';
    if (!bingoData.containsKey(key)) {
      bingoData[key] = {'targets': _defaultBingo, 'done': []};
    }
    final done = List<String>.from(bingoData[key]['done'] ?? []);
    final str = index.toString();
    if (done.contains(str)) done.remove(str); else done.add(str);
    bingoData[key]['done'] = done;
    save(); notifyListeners();
  }

  void saveBingoTargets(int year, int month, List<String> targets) {
    final key = '$year-$month';
    if (!bingoData.containsKey(key)) bingoData[key] = {'targets': targets, 'done': []};
    else bingoData[key]['targets'] = targets;
    save(); notifyListeners();
  }

  // ─── LETTER ──────────────────────────────────────────────────────────────
  void saveLetter(String text) {
    final unlock = DateTime.now().add(const Duration(days: 365));
    final unlockStr = '${unlock.year}-${unlock.month.toString().padLeft(2, '0')}-${unlock.day.toString().padLeft(2, '0')}';
    letter = FutureLetter(text: text, writtenAt: todayStr, unlockAt: unlockStr);
    save(); notifyListeners();
  }

  // ─── DAILY ANSWER ────────────────────────────────────────────────────────
  void saveDailyAnswer(String answer) {
    dailyAnswers[todayStr] = answer;
    save(); notifyListeners();
  }

  // ─── UPDATE PROFILE ──────────────────────────────────────────────────────
  void updateProfile({required String name, required String aname, required double salary}) {
    userName = name;
    agendaName = aname.isNotEmpty ? aname : "$name'nın Ajandası";
    this.salary = salary;
    save();
    notifyListeners();
  }

  // ─── IMPORT FROM JSON ────────────────────────────────────────────────────
  Future<void> importFromJson(Map<String, dynamic> d) async {
    userName    = d['userName']  ?? userName;
    agendaName  = d['agendaName'] ?? agendaName;
    salary      = (d['salary'] as num?)?.toDouble() ?? salary;
    isDark      = d['isDark']   ?? isDark;
    final ac    = d['accentColor'];
    if (ac != null) accentColor = Color(ac as int);
    if (d['todos']         != null) todos         = (d['todos'] as List).map((e) => Todo.fromJson(e)).toList();
    if (d['goals']         != null) goals         = (d['goals'] as List).map((e) => Goal.fromJson(e)).toList();
    if (d['expenses']      != null) expenses      = (d['expenses'] as List).map((e) => Expense.fromJson(e)).toList();
    if (d['savings']       != null) savings       = (d['savings'] as List).map((e) => Saving.fromJson(e)).toList();
    if (d['journal']       != null) journal       = (d['journal'] as List).map((e) => JournalEntry.fromJson(e)).toList();
    if (d['gratitude']     != null) gratitude     = (d['gratitude'] as List).map((e) => Gratitude.fromJson(e)).toList();
    if (d['suggestions']   != null) suggestions   = (d['suggestions'] as List).map((e) => Suggestion.fromJson(e)).toList();
    if (d['sleepLogs']     != null) sleepLogs     = (d['sleepLogs'] as List).map((e) => SleepLog.fromJson(e)).toList();
    if (d['moodLogs']      != null) moodLogs      = (d['moodLogs'] as List).map((e) => MoodLog.fromJson(e)).toList();
    if (d['notes']         != null) notes         = (d['notes'] as List).map((e) => AppNote.fromJson(e)).toList();
    if (d['measurements']  != null) measurements  = (d['measurements'] as List).map((e) => BodyMeasurement.fromJson(e)).toList();
    if (d['sportPrograms'] != null) sportPrograms = (d['sportPrograms'] as List).map((e) => SportProgram.fromJson(e)).toList();
    if (d['bingoData']     != null) bingoData     = Map<String, dynamic>.from(d['bingoData']);
    if (d['letter']        != null) letter        = FutureLetter.fromJson(d['letter']);
    await save();
    notifyListeners();
  }

  // ─── SHARED GOALS ────────────────────────────────────────────────────────
  void shareGoal(String goalName, String friendName) {
    sharedGoals.insert(0, {
      'goalName': goalName,
      'friendName': friendName,
      'date': todayStr,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    });
    save(); notifyListeners();
  }

  static const List<String> _defaultBingo = [
    "Festival biletine git","Ev bitkisi al","Doğa yürüyüşü","Yeni spor rutini","Dengeli beslenme",
    "Yeni hobi edin","Alışveriş listesi yap","Pikniğe git","Bisiklete bin","Sabah rutini oluştur",
    "Olumlamalar başla","Eski kıyafetleri bağışla","Evi düzenle","Cilt bakımı yap","Rüya günlüğü tut",
    "Her gece şükret","2 belgesel izle","Gezilecekler listesi","Her gün 2L su","Gülümseyerek başla",
    "Haftalık yemek listesi","Yeni şey öğren","Borsa öğren","Playlist hazırla","Arkadaşlarla buluş",
  ];
}
