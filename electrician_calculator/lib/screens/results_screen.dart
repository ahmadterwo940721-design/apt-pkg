import 'package:flutter/material.dart';
import '../calculator.dart';
import '../theme_colors.dart';
import '../widgets/shared_widgets.dart';

class ResultsScreen extends StatelessWidget {
  final CalculationResult result;
  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final fails = result.exceedsVoltageDropLimit;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Text(
                    'Detailed Results',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.inputs.circuitType} sizing report for ${result.inputs.phase} at ${result.inputs.voltage.toStringAsFixed(0)} V',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.mutedText, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Panel(
                children: [
                  const SectionTitle('Summary'),
                  ValueLabel(
                      'Calculated Load Current: ${result.nominalCurrent.toStringAsFixed(2)} Amps'),
                  ValueLabel('Selected Wire Gauge: ${result.finalGauge} AWG'),
                  ValueLabel(
                      'Adjusted Ampacity (Derated): ${result.finalAdjustedAmpacity.toStringAsFixed(2)} Amps'),
                  ValueLabel(
                      'Voltage Drop: ${result.finalVoltageDrop.toStringAsFixed(2)} Volts (${result.finalVoltageDropPercent.toStringAsFixed(2)} %)'),
                  ValueLabel('Recommended Breaker: ${result.breakerSize} A'),
                  const SizedBox(height: 4),
                  Text(
                    fails
                        ? 'Status: WARNING: Voltage Drop Exceeds ${result.limitPercent.toStringAsFixed(1)}%!'
                        : 'Status: PASS: Compliant.',
                    style: TextStyle(
                      color: fails ? AppColors.warn : AppColors.pass,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              Panel(
                children: [
                  const SectionTitle('Input Snapshot'),
                  ValueLabel(result.inputSnapshot),
                ],
              ),

              Panel(
                children: [
                  const SectionTitle('Calculation Breakdown'),
                  ValueLabel(result.calculationBreakdown),
                ],
              ),

              Panel(
                children: [
                  const SectionTitle('Regulation Notes'),
                  ValueLabel(result.regulationNotes),
                ],
              ),

              SizedBox(
                height: 54,
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'BACK',
                        background: colors.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        text: 'RESET DEFAULTS',
                        background: colors.accent,
                        onPressed: () {
                          // Pop back to the input screen; the input
                          // screen owns field state and can be reset
                          // there via its own CLEAR button.
                          Navigator.of(context).pop();
                        },
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
