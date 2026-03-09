import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─── APP CARD ────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const AppCard({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? (isDark ? AppTheme.borderDark : AppTheme.borderLight)),
      ),
      child: child,
    );
  }
}

// ─── CARD TITLE ──────────────────────────────────────────────────────────────
class CardTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const CardTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ─── STAT CARD ───────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatCard({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppTheme.mutedDark : AppTheme.mutedLight,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.spaceMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? accent),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── PROGRESS BAR ────────────────────────────────────────────────────────────
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final Color? color;

  const AppProgressBar({super.key, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 5,
        backgroundColor: isDark ? AppTheme.surface2Dark : AppTheme.surface2Light,
        valueColor: AlwaysStoppedAnimation(color ?? accent),
      ),
    );
  }
}

// ─── CHIP BUTTON ─────────────────────────────────────────────────────────────
class ChipButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const ChipButton({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: active ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.black : (isDark ? AppTheme.mutedDark : AppTheme.mutedLight),
            )),
      ),
    );
  }
}

// ─── SECTION HEADER ──────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.fraunces(
                        fontSize: 24, fontWeight: FontWeight.w900)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.mutedDark
                                : AppTheme.mutedLight)),
                  ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ─── MODAL SHEET HELPER ──────────────────────────────────────────────────────
Future<T?> showAppModal<T>(BuildContext context, {required Widget child}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, ctrl) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: ctrl,
                  padding: EdgeInsets.fromLTRB(
                      20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

// ─── FRAUNCES HEADING ────────────────────────────────────────────────────────
Widget frauncesText(String text, {double size = 18, FontWeight weight = FontWeight.w700, Color? color}) {
  return Text(text,
      style: GoogleFonts.fraunces(fontSize: size, fontWeight: weight, color: color));
}
