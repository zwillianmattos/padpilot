import 'package:flutter/material.dart';

/// Airy device-centric look: a plain canvas, products as the hero, small
/// uppercase actions and a single violet accent. Light and dark variants
/// follow the system appearance.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const light = AppPalette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F5F7),
    border: Color(0xFFE7E7EC),
    text: Color(0xFF141418),
    muted: Color(0xFF7C7C88),
    accent: Color(0xFF7B4DFF),
    accentSoft: Color(0xFFEEE8FF),
    success: Color(0xFF34B36B),
    warning: Color(0xFFE5A23A),
    danger: Color(0xFFE5484D),
  );

  static const dark = AppPalette(
    background: Color(0xFF131316),
    surface: Color(0xFF1D1D22),
    border: Color(0xFF2D2D35),
    text: Color(0xFFF2F2F5),
    muted: Color(0xFF9C9CA8),
    accent: Color(0xFF9B78FF),
    accentSoft: Color(0xFF2B2244),
    success: Color(0xFF46C47D),
    warning: Color(0xFFF0B04F),
    danger: Color(0xFFF0656A),
  );

  final Color background;
  final Color surface;
  final Color border;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color warning;
  final Color danger;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? border,
    Color? text,
    Color? muted,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? warning,
    Color? danger,
  }) => AppPalette(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    border: border ?? this.border,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    accent: accent ?? this.accent,
    accentSoft: accentSoft ?? this.accentSoft,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
  );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

ThemeData buildAppTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: brightness,
    primary: p.accent,
    surface: p.background,
    onSurface: p.text,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
  );
  return base.copyWith(
    extensions: [p],
    textTheme: base.textTheme.apply(bodyColor: p.text, displayColor: p.text),
    iconTheme: base.iconTheme.copyWith(color: p.text),
    dividerTheme: DividerThemeData(color: p.border, space: 1),
    popupMenuTheme: PopupMenuThemeData(color: p.surface, surfaceTintColor: Colors.transparent),
    dialogTheme: DialogThemeData(backgroundColor: p.surface, surfaceTintColor: Colors.transparent),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.text,
      contentTextStyle: TextStyle(color: p.background),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 3,
      inactiveTrackColor: p.border,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.text,
        foregroundColor: p.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: p.text)),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: p.accentSoft,
        selectedForegroundColor: p.accent,
        foregroundColor: p.text,
        side: BorderSide(color: p.border),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        visualDensity: VisualDensity.compact,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(backgroundColor: p.background),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? p.accent : p.border,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: p.text, borderRadius: BorderRadius.circular(6)),
      textStyle: TextStyle(color: p.background, fontSize: 12),
    ),
  );
}
