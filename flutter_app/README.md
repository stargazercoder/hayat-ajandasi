# 🌿 Hayat Ajandası — Flutter

HTML versiyonunun Flutter'a taşınmış halidir. Tüm özellikler korunmuştur.

## 📱 Özellikler

| Ekran | Açıklama |
|---|---|
| 🏠 Ana Panel | Günlük soru, ruh hali takibi, bütçe & zincir özeti |
| ✅ Görevler | Kategori & öncelikli yapılacaklar listesi |
| 🎯 Bingo | Aylık 25 hedeflik bingo kartı |
| 🔗 Zincirler | Alışkanlık takip zinciri (streak sistemi) |
| 🗒️ Rutinler | Spor programı, notlar, tarifler, vücut ölçümleri |
| 💰 Maaş | Gider yönetimi & birikim hedefleri |
| 📝 Günlük | Journal & günlük şükür listesi |
| 💡 Öneriler | Kitap, film, müzik, podcast önerileri |
| 💌 Mektup | 1 yıl kilitli geleceğe mektup |
| 😴 Uyku | Uyku saati & kalite kaydı |
| 👥 Sosyal | Hedef paylaşımı & ilham panosu |

## 🚀 Kurulum

```bash
cd flutter_app
flutter pub get
flutter run
```

## 🛠️ Teknik Stack

- **State Management:** Provider
- **Yerel Depolama:** SharedPreferences
- **Fontlar:** Google Fonts (Cabinet Grotesk + Fraunces + Space Mono)
- **Min SDK:** Flutter 3.0+, Dart 3.0+

## 📁 Proje Yapısı

```
lib/
├── main.dart               # Giriş noktası
├── theme/
│   └── app_theme.dart      # Koyu/açık tema & renkler
├── models/
│   └── models.dart         # Tüm veri modelleri
├── providers/
│   └── app_provider.dart   # Global state (Provider)
├── screens/
│   ├── onboard_screen.dart
│   ├── main_screen.dart
│   ├── dashboard_screen.dart
│   ├── todo_screen.dart
│   ├── bingo_screen.dart
│   ├── goals_screen.dart
│   ├── routines_screen.dart
│   └── misc_screens.dart   # Salary, Journal, Suggestions, Letter, Sleep, Social
└── widgets/
    └── common.dart         # AppCard, StatCard, ChipButton, vb.
```
