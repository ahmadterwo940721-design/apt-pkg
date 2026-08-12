import 'package:flutter/material.dart';

/// Holds the semantic color palette for a single theme (dark or light),
/// mirroring the `app.colors` dictionary from the original Kivy app.
class AppColors {
  final Color bg;
  final Color panelBg;
  final Color panelBorder;
  final Color inputBg;
  final Color text;
  final Color mutedText;
  final Color accent;
  final Color secondary;

  const AppColors({
    required this.bg,
    required this.panelBg,
    required this.panelBorder,
    required this.inputBg,
    required this.text,
    required this.mutedText,
    required this.accent,
    required this.secondary,
  });

  static const AppColors dark = AppColors(
    bg: Color.fromRGBO(18, 20, 26, 1),
    panelBg: Color.fromRGBO(36, 41, 51, 1),
    panelBorder: Color.fromRGBO(66, 77, 92, 1),
    inputBg: Color.fromRGBO(46, 54, 69, 1),
    text: Color.fromRGBO(245, 247, 252, 1),
    mutedText: Color.fromRGBO(196, 207, 224, 1),
    accent: Color.fromRGBO(43, 133, 217, 1),
    secondary: Color.fromRGBO(94, 105, 125, 1),
  );

  static const AppColors light = AppColors(
    bg: Color.fromRGBO(242, 245, 250, 1),
    panelBg: Color.fromRGBO(255, 255, 255, 1),
    panelBorder: Color.fromRGBO(201, 209, 224, 1),
    inputBg: Color.fromRGBO(237, 242, 250, 1),
    text: Color.fromRGBO(26, 33, 46, 1),
    mutedText: Color.fromRGBO(87, 99, 120, 1),
    accent: Color.fromRGBO(41, 115, 209, 1),
    secondary: Color.fromRGBO(133, 143, 163, 1),
  );

  static const Color pass = Color.fromRGBO(77, 255, 136, 1);
  static const Color warn = Color.fromRGBO(255, 77, 77, 1);
}

/// InheritedWidget that exposes the current AppColors + theme toggle
/// to the whole widget tree, similar to `app.colors` being globally
/// reachable in the Kivy version.
class AppTheme extends InheritedWidget {
  final AppColors colors;
  final String themeName; // "Dark" or "Light"
  final void Function(String) setTheme;

  const AppTheme({
    super.key,
    required this.colors,
    required this.themeName,
    required this.setTheme,
    required super.child,
  });

  static AppTheme of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(result != null, 'No AppTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) {
    return oldWidget.themeName != themeName;
  }
}
