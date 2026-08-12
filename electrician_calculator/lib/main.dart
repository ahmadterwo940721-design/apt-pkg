import 'package:flutter/material.dart';
import 'theme_colors.dart';
import 'screens/input_screen.dart';

void main() {
  runApp(const ElectricianApp());
}

class ElectricianApp extends StatefulWidget {
  const ElectricianApp({super.key});

  @override
  State<ElectricianApp> createState() => _ElectricianAppState();
}

class _ElectricianAppState extends State<ElectricianApp> {
  String themeName = 'Dark';

  void _setTheme(String name) {
    setState(() => themeName = name);
  }

  @override
  Widget build(BuildContext context) {
    final colors = themeName == 'Light' ? AppColors.light : AppColors.dark;

    return AppTheme(
      colors: colors,
      themeName: themeName,
      setTheme: _setTheme,
      child: MaterialApp(
        title: 'Electrician Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: themeName == 'Light' ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: colors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: colors.accent,
            brightness: themeName == 'Light' ? Brightness.light : Brightness.dark,
          ),
        ),
        home: const InputScreen(),
      ),
    );
  }
}
