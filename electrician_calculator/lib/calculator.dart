import 'dart:math';

/// Raised for any invalid/incomplete input, mirroring the Python
/// ValueError / ZeroDivisionError paths that trigger "Please enter
/// valid numeric values".
class CalculationException implements Exception {
  final String message;
  CalculationException(this.message);
  @override
  String toString() => message;
}

/// All the user-entered values, snapshot at calculate() time.
class CalculationInputs {
  final String theme;
  final String inputMode; // "Power (kW)" or "Current (Amps)"
  final double powerKw;
  final double currentAmps;
  final double voltage;
  final String phase; // "DC", "Single-Phase", "Three-Phase"
  final String circuitType; // "Branch Circuit" or "Feeder"
  final String material; // "Copper" or "Aluminum"
  final double powerFactor;
  final double distance;
  final String distanceUnit; // "Feet" or "Meters"
  final String tempBand;
  final String bundleBand;
  final double continuousLoad;

  CalculationInputs({
    required this.theme,
    required this.inputMode,
    required this.powerKw,
    required this.currentAmps,
    required this.voltage,
    required this.phase,
    required this.circuitType,
    required this.material,
    required this.powerFactor,
    required this.distance,
    required this.distanceUnit,
    required this.tempBand,
    required this.bundleBand,
    required this.continuousLoad,
  });
}

/// Full computed report, mirroring the `result` dict built inside
/// ElectricianApp.calculate() in the original Kivy app.
class CalculationResult {
  final CalculationInputs inputs;
  final double distanceFt;
  final double tempFactor;
  final double bundleFactor;
  final double combinedFactor;

  final double nominalCurrent;
  final String nominalFormula;

  final String initialGauge;
  final double initialBaseAmpacity;

  final String deratingGauge;
  final double deratingBaseAmpacity;
  final double deratingAdjustedAmpacity;

  final double limitPercent;

  final String finalGauge;
  final double finalBaseAmpacity;
  final double finalAdjustedAmpacity;
  final double finalVoltageDrop;
  final double finalVoltageDropPercent;

  final int breakerSize;
  final double breaker125;
  final double breakerMinimum;

  final String vdFormula;

  CalculationResult({
    required this.inputs,
    required this.distanceFt,
    required this.tempFactor,
    required this.bundleFactor,
    required this.combinedFactor,
    required this.nominalCurrent,
    required this.nominalFormula,
    required this.initialGauge,
    required this.initialBaseAmpacity,
    required this.deratingGauge,
    required this.deratingBaseAmpacity,
    required this.deratingAdjustedAmpacity,
    required this.limitPercent,
    required this.finalGauge,
    required this.finalBaseAmpacity,
    required this.finalAdjustedAmpacity,
    required this.finalVoltageDrop,
    required this.finalVoltageDropPercent,
    required this.breakerSize,
    required this.breaker125,
    required this.breakerMinimum,
    required this.vdFormula,
  });

  bool get exceedsVoltageDropLimit => finalVoltageDropPercent > limitPercent;

  String get inputSnapshot {
    final v = inputs;
    return [
      'Theme: ${v.theme} | Input Mode: ${v.inputMode} | Circuit Type: ${v.circuitType}',
      'Power: ${v.powerKw.toStringAsFixed(2)} kW | Current Input: ${v.currentAmps.toStringAsFixed(2)} A | Voltage: ${v.voltage.toStringAsFixed(0)} V',
      'Phase: ${v.phase} | Power Factor: ${v.powerFactor.toStringAsFixed(2)} | Material: ${v.material}',
      'Distance: ${v.distance.toStringAsFixed(2)} ${v.distanceUnit} (${distanceFt.toStringAsFixed(2)} ft effective)',
      'Ambient Temp: ${v.tempBand} | Bundled Conductors: ${v.bundleBand} | Continuous Load: ${v.continuousLoad.toStringAsFixed(2)} A',
    ].join('\n');
  }

  String get calculationBreakdown {
    final lines = <String>[
      'Nominal current calculation: $nominalFormula = ${nominalCurrent.toStringAsFixed(2)} A',
      'Base ampacity selection: smallest gauge with base ampacity >= load is $initialGauge AWG (${initialBaseAmpacity.toStringAsFixed(2)} A).',
      'Derating factors: temperature ${tempFactor.toStringAsFixed(2)} x bundling ${bundleFactor.toStringAsFixed(2)} = combined factor ${combinedFactor.toStringAsFixed(3)}.',
      'Derated ampacity check: $deratingGauge AWG gives ${deratingBaseAmpacity.toStringAsFixed(2)} A base and ${deratingAdjustedAmpacity.toStringAsFixed(2)} A adjusted.',
      'Voltage-drop limit: ${limitPercent.toStringAsFixed(1)}% for ${inputs.circuitType.toLowerCase()}s.',
      'Voltage-drop formula used: $vdFormula',
      'Voltage drop result with final gauge: ${finalVoltageDrop.toStringAsFixed(2)} V, which is ${finalVoltageDropPercent.toStringAsFixed(2)}% of system voltage.',
      'Breaker sizing: max(load x 1.25 = ${breaker125.toStringAsFixed(2)} A, continuous load = ${inputs.continuousLoad.toStringAsFixed(2)} A) = ${breakerMinimum.toStringAsFixed(2)} A, next standard breaker = $breakerSize A.',
      'Final wire choice: $finalGauge AWG with adjusted ampacity ${finalAdjustedAmpacity.toStringAsFixed(2)} A.',
    ];
    if (finalVoltageDropPercent > limitPercent) {
      lines.add(
          'Warning: even the largest available hardcoded gauge still exceeds the voltage-drop limit.');
    }
    return lines.join('\n');
  }

  String get regulationNotes {
    final lines = <String>[
      'Reference tables are hardcoded exactly to the requested 75C copper ampacity values, copper ohms per 1000 ft, temperature factors, bundling factors, and standard breaker list.',
      'Aluminum ampacity is modeled as 0.8 x copper ampacity, and aluminum resistance is modeled as 1.64 x copper resistance, matching the requested simplification.',
      'Voltage-drop pass/fail uses 3% for branch circuits and 5% for feeders.',
      'Distance is entered one-way; meter values are converted internally to feet for the voltage-drop table.',
      'This tool is a strong field calculator for the requested scope, but site conditions, insulation type, terminal ratings, conduit fill, grounding, and special NEC exceptions still require electrician judgment.',
    ];
    if (inputs.phase == 'DC') {
      lines.add('Power factor is ignored for DC mode.');
    }
    return lines.join('\n');
  }
}

/// Small tuple-like holder for the (gauge, base, adjusted) triple
/// returned by the derating / voltage-drop search functions.
class _GaugeStep {
  final String gauge;
  final double baseAmpacity;
  final double adjustedAmpacity;
  final double? voltageDrop;
  final double? voltageDropPercent;
  _GaugeStep(this.gauge, this.baseAmpacity, this.adjustedAmpacity,
      [this.voltageDrop, this.voltageDropPercent]);
}

class ElectricianCalculator {
  static const Map<String, double> ampacity75cCopper = {
    '14': 20,
    '12': 25,
    '10': 35,
    '8': 50,
    '6': 65,
    '4': 85,
    '3': 100,
    '2': 115,
    '1': 130,
    '1/0': 150,
    '2/0': 175,
    '3/0': 200,
    '4/0': 230,
  };

  static const Map<String, double> ohmsPer1000ftCopper = {
    '14': 3.14,
    '12': 1.588,
    '10': 0.999,
    '8': 0.628,
    '6': 0.395,
    '4': 0.248,
    '3': 0.197,
    '2': 0.156,
    '1': 0.124,
    '1/0': 0.098,
    '2/0': 0.077,
    '3/0': 0.061,
    '4/0': 0.049,
  };

  static const Map<String, double> tempFactors = {
    '21-25': 1.0,
    '26-30': 0.96,
    '31-35': 0.91,
    '36-40': 0.82,
    '41-45': 0.71,
    '46-50': 0.58,
  };

  static const Map<String, double> bundleFactors = {
    '1-3': 1.0,
    '4-6': 0.8,
    '7-9': 0.7,
    '10-20': 0.5,
    '21-30': 0.45,
    '31-40': 0.4,
    '41+': 0.35,
  };

  static const List<int> stdBreakers = [
    15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100, 110, 125, 150, 175,
    200, 225, 250, 300
  ];

  static const List<String> gaugeOrder = [
    '14', '12', '10', '8', '6', '4', '3', '2', '1', '1/0', '2/0', '3/0', '4/0'
  ];

  static double parseField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      throw CalculationException('$fieldName is required');
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || !parsed.isFinite) {
      throw CalculationException('$fieldName is invalid');
    }
    return parsed;
  }

  static Map<String, double> getAmpacityTable(String material) {
    if (material == 'Copper') return Map.of(ampacity75cCopper);
    return ampacity75cCopper
        .map((gauge, value) => MapEntry(gauge, _round(value * 0.8, 2)));
  }

  static Map<String, double> getOhmsTable(String material) {
    if (material == 'Copper') return Map.of(ohmsPer1000ftCopper);
    return ohmsPer1000ftCopper
        .map((gauge, value) => MapEntry(gauge, _round(value * 1.64, 5)));
  }

  static double _round(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }

  static double feetDistance(double distanceValue, String unitName) {
    if (unitName == 'Meters') return distanceValue * 3.28084;
    return distanceValue;
  }

  static double nominalCurrent(
    String inputMode,
    double powerKw,
    double currentAmps,
    double voltage,
    String phase,
    double powerFactor,
  ) {
    if (inputMode == 'Current (Amps)') return currentAmps;
    final base = (powerKw * 1000.0) / voltage;
    if (phase == 'Single-Phase') return base / powerFactor;
    if (phase == 'Three-Phase') return base / (powerFactor * 1.732);
    return base;
  }

  static String findInitialGauge(
      double current, Map<String, double> ampacityTable) {
    for (final gauge in gaugeOrder) {
      if (ampacityTable[gauge]! >= current) return gauge;
    }
    return gaugeOrder.last;
  }

  static _GaugeStep findGaugeForDerating(
    double current,
    Map<String, double> ampacityTable,
    double tempFactor,
    double bundleFactor, {
    int startIndex = 0,
  }) {
    for (var i = startIndex; i < gaugeOrder.length; i++) {
      final gauge = gaugeOrder[i];
      final baseAmpacity = ampacityTable[gauge]!;
      final adjustedAmpacity = baseAmpacity * tempFactor * bundleFactor;
      if (baseAmpacity >= current && adjustedAmpacity >= current) {
        return _GaugeStep(gauge, baseAmpacity, adjustedAmpacity);
      }
    }
    final largest = gaugeOrder.last;
    final base = ampacityTable[largest]!;
    return _GaugeStep(largest, base, base * tempFactor * bundleFactor);
  }

  static double computeVoltageDrop(
    String phase,
    double ohmsPer1000ft,
    double current,
    double distanceFt,
  ) {
    if (phase == 'DC' || phase == 'Single-Phase') {
      return (2 * ohmsPer1000ft * current * distanceFt) / 1000.0;
    }
    return (1.732 * ohmsPer1000ft * current * distanceFt) / 1000.0;
  }

  static _GaugeStep? findGaugeForVoltageDrop(
    String startGauge,
    double current,
    double voltage,
    String phase,
    double distanceFt,
    double limitPercent,
    Map<String, double> ampacityTable,
    Map<String, double> ohmsTable,
    double tempFactor,
    double bundleFactor,
  ) {
    final startIndex = gaugeOrder.indexOf(startGauge);
    _GaugeStep? lastResult;
    for (var i = startIndex; i < gaugeOrder.length; i++) {
      final gauge = gaugeOrder[i];
      final baseAmpacity = ampacityTable[gauge]!;
      final adjustedAmpacity = baseAmpacity * tempFactor * bundleFactor;
      if (adjustedAmpacity < current) continue;
      final voltageDrop =
          computeVoltageDrop(phase, ohmsTable[gauge]!, current, distanceFt);
      final voltageDropPercent = (voltageDrop / voltage) * 100.0;
      lastResult = _GaugeStep(
          gauge, baseAmpacity, adjustedAmpacity, voltageDrop, voltageDropPercent);
      if (voltageDropPercent <= limitPercent) return lastResult;
    }
    return lastResult;
  }

  static ({int size, double minimum}) findBreakerSize(
      double current, double continuousLoad) {
    final breakerMinimum = max(current * 1.25, continuousLoad);
    for (final breaker in stdBreakers) {
      if (breaker >= breakerMinimum) {
        return (size: breaker, minimum: breakerMinimum);
      }
    }
    return (size: stdBreakers.last, minimum: breakerMinimum);
  }

  /// Runs the full sizing pipeline. Throws [CalculationException] on
  /// any invalid input, matching the original app's "Please enter
  /// valid numeric values" popup behavior.
  static CalculationResult calculate(CalculationInputs v) {
    if (v.voltage <= 0) {
      throw CalculationException('Voltage must be greater than zero');
    }
    if (v.powerKw < 0 ||
        v.currentAmps < 0 ||
        v.distance < 0 ||
        v.continuousLoad < 0) {
      throw CalculationException('Values cannot be negative');
    }
    if ((v.phase == 'Single-Phase' || v.phase == 'Three-Phase') &&
        !(v.powerFactor >= 0.7 && v.powerFactor <= 1.0)) {
      throw CalculationException('Power factor must be between 0.70 and 1.00');
    }

    final distanceFt = feetDistance(v.distance, v.distanceUnit);
    final ampacityTable = getAmpacityTable(v.material);
    final ohmsTable = getOhmsTable(v.material);
    final tempFactor = tempFactors[v.tempBand]!;
    final bundleFactor = bundleFactors[v.bundleBand]!;

    final current = nominalCurrent(
        v.inputMode, v.powerKw, v.currentAmps, v.voltage, v.phase, v.powerFactor);
    if (current <= 0) {
      throw CalculationException('Calculated current must be greater than zero');
    }

    String nominalFormula;
    if (v.inputMode == 'Power (kW)') {
      if (v.phase == 'Single-Phase') {
        nominalFormula =
            '(${v.powerKw.toStringAsFixed(2)} x 1000) / ${v.voltage.toStringAsFixed(0)} / ${v.powerFactor.toStringAsFixed(2)}';
      } else if (v.phase == 'Three-Phase') {
        nominalFormula =
            '(${v.powerKw.toStringAsFixed(2)} x 1000) / ${v.voltage.toStringAsFixed(0)} / (${v.powerFactor.toStringAsFixed(2)} x 1.732)';
      } else {
        nominalFormula =
            '(${v.powerKw.toStringAsFixed(2)} x 1000) / ${v.voltage.toStringAsFixed(0)}';
      }
    } else {
      nominalFormula = 'Direct current input = ${v.currentAmps.toStringAsFixed(2)} A';
    }

    final initialGauge = findInitialGauge(current, ampacityTable);
    final initialBaseAmpacity = ampacityTable[initialGauge]!;

    final derating = findGaugeForDerating(
      current,
      ampacityTable,
      tempFactor,
      bundleFactor,
      startIndex: gaugeOrder.indexOf(initialGauge),
    );

    final limitPercent = v.circuitType == 'Feeder' ? 5.0 : 3.0;
    final vdResult = findGaugeForVoltageDrop(
      derating.gauge,
      current,
      v.voltage,
      v.phase,
      distanceFt,
      limitPercent,
      ampacityTable,
      ohmsTable,
      tempFactor,
      bundleFactor,
    );
    if (vdResult == null) {
      throw CalculationException(
          'Unable to size conductor with the available gauge table');
    }

    final breaker = findBreakerSize(current, v.continuousLoad);
    final breaker125 = current * 1.25;

    String vdFormula;
    if (v.phase == 'DC' || v.phase == 'Single-Phase') {
      vdFormula =
          '(2 x ${ohmsTable[vdResult.gauge]!.toStringAsFixed(5)} x ${current.toStringAsFixed(2)} x ${distanceFt.toStringAsFixed(2)}) / 1000';
    } else {
      vdFormula =
          '(1.732 x ${ohmsTable[vdResult.gauge]!.toStringAsFixed(5)} x ${current.toStringAsFixed(2)} x ${distanceFt.toStringAsFixed(2)}) / 1000';
    }

    return CalculationResult(
      inputs: v,
      distanceFt: distanceFt,
      tempFactor: tempFactor,
      bundleFactor: bundleFactor,
      combinedFactor: tempFactor * bundleFactor,
      nominalCurrent: current,
      nominalFormula: nominalFormula,
      initialGauge: initialGauge,
      initialBaseAmpacity: initialBaseAmpacity,
      deratingGauge: derating.gauge,
      deratingBaseAmpacity: derating.baseAmpacity,
      deratingAdjustedAmpacity: derating.adjustedAmpacity,
      limitPercent: limitPercent,
      finalGauge: vdResult.gauge,
      finalBaseAmpacity: vdResult.baseAmpacity,
      finalAdjustedAmpacity: vdResult.adjustedAmpacity,
      finalVoltageDrop: vdResult.voltageDrop!,
      finalVoltageDropPercent: vdResult.voltageDropPercent!,
      breakerSize: breaker.size,
      breaker125: breaker125,
      breakerMinimum: breaker.minimum,
      vdFormula: vdFormula,
    );
  }
}
