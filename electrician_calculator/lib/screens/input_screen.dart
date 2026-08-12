import 'package:flutter/material.dart';
import '../calculator.dart';
import '../theme_colors.dart';
import '../widgets/shared_widgets.dart';
import 'results_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // Dropdown / mode state
  String inputMode = 'Power (kW)';
  String voltage = '240';
  String phase = 'Single-Phase';
  String circuitType = 'Branch Circuit';
  String material = 'Copper';
  String distanceUnit = 'Feet';
  String tempBand = '21-25';
  String bundleBand = '1-3';

  double pfSlider = 0.85;

  // Text controllers
  late TextEditingController powerCtrl;
  late TextEditingController currentCtrl;
  late TextEditingController pfCtrl;
  late TextEditingController distanceCtrl;
  late TextEditingController continuousLoadCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    powerCtrl = TextEditingController(text: '5.0');
    currentCtrl = TextEditingController(text: '20.0');
    pfCtrl = TextEditingController(text: '0.85');
    distanceCtrl = TextEditingController(text: '100');
    continuousLoadCtrl = TextEditingController(text: '0.0');
  }

  @override
  void dispose() {
    powerCtrl.dispose();
    currentCtrl.dispose();
    pfCtrl.dispose();
    distanceCtrl.dispose();
    continuousLoadCtrl.dispose();
    super.dispose();
  }

  void _syncPfFromSlider(double value) {
    setState(() {
      pfSlider = value;
      pfCtrl.text = value.toStringAsFixed(2);
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Input Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    setState(() {
      AppTheme.of(context).setTheme('Dark');
      inputMode = 'Power (kW)';
      powerCtrl.text = '5.0';
      currentCtrl.text = '20.0';
      voltage = '240';
      phase = 'Single-Phase';
      circuitType = 'Branch Circuit';
      material = 'Copper';
      pfCtrl.text = '0.85';
      pfSlider = 0.85;
      distanceCtrl.text = '100';
      distanceUnit = 'Feet';
      tempBand = '21-25';
      bundleBand = '1-3';
      continuousLoadCtrl.text = '0.0';
    });
  }

  void _calculate() {
    try {
      final theme = AppTheme.of(context).themeName;
      final powerKw = ElectricianCalculator.parseField(powerCtrl.text, 'Power');
      final currentAmps =
          ElectricianCalculator.parseField(currentCtrl.text, 'Current');
      final voltageValue =
          ElectricianCalculator.parseField(voltage, 'Voltage');
      final powerFactor =
          ElectricianCalculator.parseField(pfCtrl.text, 'Power Factor');
      final distanceValue =
          ElectricianCalculator.parseField(distanceCtrl.text, 'Distance');
      final continuousLoad = ElectricianCalculator.parseField(
          continuousLoadCtrl.text, 'Continuous Load');

      final inputs = CalculationInputs(
        theme: theme,
        inputMode: inputMode,
        powerKw: powerKw,
        currentAmps: currentAmps,
        voltage: voltageValue,
        phase: phase,
        circuitType: circuitType,
        material: material,
        powerFactor: powerFactor,
        distance: distanceValue,
        distanceUnit: distanceUnit,
        tempBand: tempBand,
        bundleBand: bundleBand,
        continuousLoad: continuousLoad,
      );

      final result = ElectricianCalculator.calculate(inputs);

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
      );
    } on CalculationException {
      _showError('Please enter valid numeric values');
    } catch (_) {
      _showError('Please enter valid numeric values');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final themeName = AppTheme.of(context).themeName;
    final powerMode = inputMode == 'Power (kW)';

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: [
                  Text(
                    'Professional Electrician Calculator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Complete branch and feeder cable sizing with default values kept ready.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.mutedText, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mode And Supply panel
              Panel(
                children: [
                  const SectionTitle('Mode And Supply'),
                  TwoColumnGrid(
                    children: [
                      FieldSlot(
                        label: 'Theme',
                        child: AppDropdown(
                          value: themeName,
                          values: const ['Dark', 'Light'],
                          onChanged: (v) => AppTheme.of(context).setTheme(v),
                        ),
                      ),
                      FieldSlot(
                        label: 'Input Mode',
                        child: AppDropdown(
                          value: inputMode,
                          values: const ['Power (kW)', 'Current (Amps)'],
                          onChanged: (v) => setState(() => inputMode = v),
                        ),
                      ),
                      FieldSlot(
                        label: 'Power (kW)',
                        child: AppTextField(
                          controller: powerCtrl,
                          enabled: powerMode,
                        ),
                      ),
                      FieldSlot(
                        label: 'Current (Amps)',
                        child: AppTextField(
                          controller: currentCtrl,
                          enabled: !powerMode,
                        ),
                      ),
                      FieldSlot(
                        label: 'Voltage',
                        child: AppDropdown(
                          value: voltage,
                          values: const ['120', '208', '240', '277', '480'],
                          onChanged: (v) => setState(() => voltage = v),
                        ),
                      ),
                      FieldSlot(
                        label: 'Phase',
                        child: AppDropdown(
                          value: phase,
                          values: const ['DC', 'Single-Phase', 'Three-Phase'],
                          onChanged: (v) => setState(() => phase = v),
                        ),
                      ),
                      FieldSlot(
                        label: 'Circuit Type',
                        child: AppDropdown(
                          value: circuitType,
                          values: const ['Branch Circuit', 'Feeder'],
                          onChanged: (v) => setState(() => circuitType = v),
                        ),
                      ),
                      FieldSlot(
                        label: 'Wire Material',
                        child: AppDropdown(
                          value: material,
                          values: const ['Copper', 'Aluminum'],
                          onChanged: (v) => setState(() => material = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Load And Environment panel
              Panel(
                children: [
                  const SectionTitle('Load And Environment'),
                  TwoColumnGrid(
                    children: [
                      FieldSlot(
                        label: 'Power Factor',
                        child: AppTextField(controller: pfCtrl),
                      ),
                      FieldSlot(
                        label: 'PF Slider',
                        child: Row(
                          children: [
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: colors.accent,
                                  thumbColor: colors.accent,
                                  inactiveTrackColor: colors.panelBorder,
                                ),
                                child: Slider(
                                  value: pfSlider,
                                  min: 0.7,
                                  max: 1.0,
                                  divisions: 30,
                                  onChanged: _syncPfFromSlider,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 48,
                              child: Text(
                                pfSlider.toStringAsFixed(2),
                                style: TextStyle(color: colors.text),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FieldSlot(
                        label: 'Distance',
                        child: AppTextField(controller: distanceCtrl),
                      ),
                      FieldSlot(
                        label: 'Distance Unit',
                        child: AppDropdown(
                          value: distanceUnit,
                          values: const ['Feet', 'Meters'],
                          onChanged: (v) => setState(() => distanceUnit = v),
                        ),
                      ),
                      FieldSlot(
                        label: 'Ambient Temp (°C)',
                        child: AppDropdown(
                          value: tempBand,
                          values: const [
                            '21-25',
                            '26-30',
                            '31-35',
                            '36-40',
                            '41-45',
                            '46-50',
                          ],
                          onChanged: (v) => setState(() => tempBand = v),
                        ),
                      ),
                      FieldSlot(
                        label: 'Bundled Conductors',
                        child: AppDropdown(
                          value: bundleBand,
                          values: const [
                            '1-3',
                            '4-6',
                            '7-9',
                            '10-20',
                            '21-30',
                            '31-40',
                            '41+',
                          ],
                          onChanged: (v) => setState(() => bundleBand = v),
                        ),
                      ),
                      FieldSlot(
                        label: 'Continuous Load (Amps)',
                        child: AppTextField(controller: continuousLoadCtrl),
                      ),
                      FieldSlot(
                        label: 'Result Detail Page',
                        child: ValueLabel(
                          'Detailed breakdown opens on the next screen after Calculate.',
                          color: colors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(
                height: 54,
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'CALCULATE',
                        background: colors.accent,
                        onPressed: _calculate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        text: 'CLEAR',
                        background: colors.secondary,
                        onPressed: _clearFields,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
