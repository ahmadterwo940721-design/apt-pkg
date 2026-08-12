import 'package:flutter/material.dart';
import '../theme_colors.dart';

/// A rounded, bordered panel used to group related fields —
/// equivalent to the bordered BoxLayout panels in the Kivy KV.
class Panel extends StatelessWidget {
  final List<Widget> children;
  const Panel({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.panelBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.panelBorder, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(color: colors.mutedText, fontSize: 14)),
    );
  }
}

class ValueLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const ValueLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: TextStyle(color: color ?? colors.text, fontSize: 15)),
    );
  }
}

/// A labeled field slot: label above, control below — mirrors the
/// vertical BoxLayout wrapper used around every input in the KV grid.
class FieldSlot extends StatelessWidget {
  final String label;
  final Widget child;
  const FieldSlot({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        child,
      ],
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool numeric;
  const AppTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.numeric = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true, signed: false)
            : TextInputType.text,
        style: TextStyle(color: colors.text, fontSize: 15),
        cursorColor: colors.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: colors.inputBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.panelBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.panelBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.accent, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.panelBorder),
          ),
        ),
      ),
    );
  }
}

/// Dropdown styled like the Kivy `AppSpinner`.
class AppDropdown extends StatelessWidget {
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;
  const AppDropdown({
    super.key,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.inputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.panelBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: colors.panelBg,
          iconEnabledColor: colors.mutedText,
          style: TextStyle(color: colors.text, fontSize: 15),
          items: values
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final Color background;
  final VoidCallback onPressed;
  const AppButton({
    super.key,
    required this.text,
    required this.background,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

/// A 2-column responsive grid, replacing the Kivy `GridLayout: cols: 2`.
class TwoColumnGrid extends StatelessWidget {
  final List<Widget> children;
  const TwoColumnGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 420;
        if (!isWide) {
          return Column(
            children: [
              for (final c in children) ...[
                c,
                const SizedBox(height: 12),
              ],
            ],
          );
        }
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          final second = i + 1 < children.length ? children[i + 1] : null;
          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[i]),
                  const SizedBox(width: 10),
                  Expanded(child: second ?? const SizedBox()),
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}
