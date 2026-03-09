import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ─── TODO ────────────────────────────────────────────────────────────────────
class Todo {
  final String id;
  String text;
  String cat;
  String priority;
  bool done;
  DateTime createdAt;

  Todo({
    String? id,
    required this.text,
    this.cat = 'gunluk',
    this.priority = 'normal',
    this.done = false,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'cat': cat,
        'priority': priority,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Todo.fromJson(Map<String, dynamic> j) => Todo(
        id: j['id'],
        text: j['text'],
        cat: j['cat'] ?? 'gunluk',
        priority: j['priority'] ?? 'normal',
        done: j['done'] ?? false,
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      );
}

// ─── GOAL (HABİT CHAİN) ──────────────────────────────────────────────────────
class Goal {
  final String id;
  String name;
  String cat;
  int targetDays;
  List<String> doneDates; // 'yyyy-MM-dd'

  Goal({
    String? id,
    required this.name,
    required this.cat,
    this.targetDays = 66,
    List<String>? doneDates,
  })  : id = id ?? _uuid.v4(),
        doneDates = doneDates ?? [];

  int get streak {
    if (doneDates.isEmpty) return 0;
    final sorted = List<String>.from(doneDates)..sort();
    int s = 0;
    DateTime day = DateTime.now();
    while (true) {
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      if (sorted.contains(key)) {
        s++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return s;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cat': cat,
        'targetDays': targetDays,
        'doneDates': doneDates,
      };

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
        id: j['id'],
        name: j['name'],
        cat: j['cat'],
        targetDays: j['targetDays'] ?? 66,
        doneDates: List<String>.from(j['doneDates'] ?? []),
      );
}

// ─── EXPENSE ─────────────────────────────────────────────────────────────────
class Expense {
  final String id;
  String name;
  double amount;
  String cat;
  DateTime date;

  Expense({
    String? id,
    required this.name,
    required this.amount,
    this.cat = 'diger',
    DateTime? date,
  })  : id = id ?? _uuid.v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'cat': cat,
        'date': date.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'],
        name: j['name'],
        amount: (j['amount'] as num).toDouble(),
        cat: j['cat'] ?? 'diger',
        date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
      );
}

// ─── SAVING ──────────────────────────────────────────────────────────────────
class Saving {
  final String id;
  String name;
  double target;
  double current;
  String emoji;

  Saving({
    String? id,
    required this.name,
    required this.target,
    this.current = 0,
    this.emoji = '🎁',
  }) : id = id ?? _uuid.v4();

  double get progress => target > 0 ? (current / target).clamp(0, 1) : 0;

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'target': target, 'current': current, 'emoji': emoji};

  factory Saving.fromJson(Map<String, dynamic> j) => Saving(
        id: j['id'],
        name: j['name'],
        target: (j['target'] as num).toDouble(),
        current: (j['current'] as num).toDouble(),
        emoji: j['emoji'] ?? '🎁',
      );
}

// ─── JOURNAL ─────────────────────────────────────────────────────────────────
class JournalEntry {
  final String id;
  String title;
  String text;
  String mood;
  String date;

  JournalEntry({
    String? id,
    this.title = '',
    required this.text,
    this.mood = '😊',
    String? date,
  })  : id = id ?? _uuid.v4(),
        date = date ?? _todayStr();

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'text': text, 'mood': mood, 'date': date};

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
        id: j['id'],
        title: j['title'] ?? '',
        text: j['text'],
        mood: j['mood'] ?? '😊',
        date: j['date'],
      );
}

// ─── GRATITUDE ───────────────────────────────────────────────────────────────
class Gratitude {
  final String id;
  String text;
  String date;

  Gratitude({String? id, required this.text, String? date})
      : id = id ?? _uuid.v4(),
        date = date ?? _todayStr();

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'date': date};
  factory Gratitude.fromJson(Map<String, dynamic> j) =>
      Gratitude(id: j['id'], text: j['text'], date: j['date']);
}

// ─── SUGGESTION ──────────────────────────────────────────────────────────────
class Suggestion {
  final String id;
  String title;
  String type;
  String note;
  String date;

  Suggestion({
    String? id,
    required this.title,
    required this.type,
    this.note = '',
    String? date,
  })  : id = id ?? _uuid.v4(),
        date = date ?? _todayStr();

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'type': type, 'note': note, 'date': date};

  factory Suggestion.fromJson(Map<String, dynamic> j) => Suggestion(
        id: j['id'],
        title: j['title'],
        type: j['type'],
        note: j['note'] ?? '',
        date: j['date'],
      );
}

// ─── SLEEP LOG ───────────────────────────────────────────────────────────────
class SleepLog {
  final String id;
  String date;
  String bedTime;
  String wakeTime;
  int quality;

  SleepLog({
    String? id,
    required this.date,
    required this.bedTime,
    required this.wakeTime,
    required this.quality,
  }) : id = id ?? _uuid.v4();

  double get hours {
    try {
      final bed = _parseTime(bedTime);
      final wake = _parseTime(wakeTime);
      var diff = wake.difference(bed).inMinutes;
      if (diff < 0) diff += 24 * 60;
      return diff / 60;
    } catch (_) {
      return 0;
    }
  }

  DateTime _parseTime(String t) {
    final p = t.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(p[0]), int.parse(p[1]));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'bedTime': bedTime,
        'wakeTime': wakeTime,
        'quality': quality,
      };

  factory SleepLog.fromJson(Map<String, dynamic> j) => SleepLog(
        id: j['id'],
        date: j['date'],
        bedTime: j['bedTime'] ?? '23:00',
        wakeTime: j['wakeTime'] ?? '07:00',
        quality: j['quality'] ?? 3,
      );
}

// ─── MOOD LOG ────────────────────────────────────────────────────────────────
class MoodLog {
  String date;
  String emoji;

  MoodLog({required this.date, required this.emoji});

  Map<String, dynamic> toJson() => {'date': date, 'emoji': emoji};
  factory MoodLog.fromJson(Map<String, dynamic> j) =>
      MoodLog(date: j['date'], emoji: j['emoji']);
}

// ─── NOTE ────────────────────────────────────────────────────────────────────
class AppNote {
  final String id;
  String kategori;
  String baslik;
  String icerik;
  String renk;
  bool pin;
  String tarih;

  AppNote({
    String? id,
    required this.kategori,
    this.baslik = '',
    this.icerik = '',
    this.renk = '#C8F04A',
    this.pin = false,
    String? tarih,
  })  : id = id ?? _uuid.v4(),
        tarih = tarih ?? _todayStr();

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kategori': kategori,
        'baslik': baslik,
        'icerik': icerik,
        'renk': renk,
        'pin': pin,
        'tarih': tarih,
      };

  factory AppNote.fromJson(Map<String, dynamic> j) => AppNote(
        id: j['id'],
        kategori: j['kategori'],
        baslik: j['baslik'] ?? '',
        icerik: j['icerik'] ?? '',
        renk: j['renk'] ?? '#C8F04A',
        pin: j['pin'] ?? false,
        tarih: j['tarih'],
      );
}

// ─── BODY MEASUREMENT ────────────────────────────────────────────────────────
class BodyMeasurement {
  final String id;
  String date;
  Map<String, double> values;
  String note;

  BodyMeasurement({
    String? id,
    required this.date,
    required this.values,
    this.note = '',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'values': values,
        'note': note,
      };

  factory BodyMeasurement.fromJson(Map<String, dynamic> j) => BodyMeasurement(
        id: j['id'],
        date: j['date'],
        values: Map<String, double>.from(
            (j['values'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble()))),
        note: j['note'] ?? '',
      );
}

// ─── SPORT PROGRAM ───────────────────────────────────────────────────────────
class SportProgram {
  final String id;
  String gun;
  String ad;
  String icerik;
  String emoji;

  SportProgram({
    String? id,
    required this.gun,
    required this.ad,
    this.icerik = '',
    this.emoji = '💪',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toJson() =>
      {'id': id, 'gun': gun, 'ad': ad, 'icerik': icerik, 'emoji': emoji};

  factory SportProgram.fromJson(Map<String, dynamic> j) => SportProgram(
        id: j['id'],
        gun: j['gun'],
        ad: j['ad'],
        icerik: j['icerik'] ?? '',
        emoji: j['emoji'] ?? '💪',
      );
}

// ─── LETTER ──────────────────────────────────────────────────────────────────
class FutureLetter {
  String text;
  String writtenAt;
  String unlockAt;

  FutureLetter({required this.text, required this.writtenAt, required this.unlockAt});

  bool get isUnlocked {
    final now = DateTime.now();
    final unlock = DateTime.tryParse(unlockAt);
    if (unlock == null) return false;
    return !now.isBefore(unlock);
  }

  Map<String, dynamic> toJson() =>
      {'text': text, 'writtenAt': writtenAt, 'unlockAt': unlockAt};

  factory FutureLetter.fromJson(Map<String, dynamic> j) =>
      FutureLetter(text: j['text'], writtenAt: j['writtenAt'], unlockAt: j['unlockAt']);
}
