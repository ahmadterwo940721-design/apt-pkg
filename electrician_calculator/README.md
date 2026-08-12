# Electrician Calculator (Flutter)

Flutter/Dart port of the original Kivy "Professional Electrician Calculator"
app. Same two-screen flow (Input → Results), same calculation logic
(ampacity tables, temperature/bundling derating, voltage-drop sizing,
breaker sizing), same Dark/Light theme system.

## Project layout

```
lib/
  main.dart                     App entry point, top-level theme state
  theme_colors.dart             Dark/Light color palettes + AppTheme InheritedWidget
  calculator.dart                Ported calculation engine (pure Dart, no UI)
  widgets/shared_widgets.dart    Reusable styled panel/dropdown/textfield/button
  screens/input_screen.dart      Mode & Supply / Load & Environment form
  screens/results_screen.dart    Summary, snapshot, breakdown, notes
pubspec.yaml
```

## How to run

This is only the `lib/` source + `pubspec.yaml` — it doesn't include the
generated native `android/`, `ios/`, `web/` platform folders, since those
are normally scaffolded by the Flutter CLI itself. To run it:

1. Install the Flutter SDK: https://docs.flutter.dev/get-started/install
2. Create a fresh project and drop this `lib/` folder and `pubspec.yaml`
   in, overwriting the generated ones:
   ```bash
   flutter create electrician_calculator
   cd electrician_calculator
   # copy this lib/ folder and pubspec.yaml into place, replacing the defaults
   flutter pub get
   flutter run
   ```

## Notes on the port

- All hardcoded reference tables (75°C copper ampacity, copper Ω/1000ft,
  temperature factors, bundling factors, standard breaker sizes, gauge
  order) are copied over exactly.
- Aluminum ampacity/resistance modeling (0.8× / 1.64× copper) is unchanged.
- Voltage-drop pass/fail thresholds (3% branch, 5% feeder) are unchanged.
- The Kivy popup on invalid input becomes a Material `AlertDialog` with
  the same "Please enter valid numeric values" message.
- The Kivy `Spinner` widgets become Flutter `DropdownButton`s; the
  `Slider` for power factor still live-syncs the power factor text field.
- Screen navigation uses Flutter's `Navigator` (`push`/`pop`) in place of
  Kivy's `ScreenManager.current`.
