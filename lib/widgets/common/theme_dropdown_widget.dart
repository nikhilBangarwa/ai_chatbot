import 'package:flutter/material.dart';

/// Dropdown to switch between light, dark, and system theme.
class ThemeDropdownWidget extends StatelessWidget {
  const ThemeDropdownWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Theme',
    this.expanded = true,
    this.enabled = true,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode>? onChanged;
  final String label;
  final bool expanded;
  final bool enabled;

  static const Map<ThemeMode, String> _labels = {
    ThemeMode.system: 'System default',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  static const Map<ThemeMode, IconData> _icons = {
    ThemeMode.system: Icons.brightness_auto,
    ThemeMode.light: Icons.light_mode_outlined,
    ThemeMode.dark: Icons.dark_mode_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dropdown = InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ThemeMode>(
          isExpanded: expanded,
          value: value,
          onChanged: enabled
              ? (ThemeMode? mode) {
                  if (mode != null) onChanged?.call(mode);
                }
              : null,
          items: ThemeMode.values
              .map(
                (mode) => DropdownMenuItem(
                  value: mode,
                  child: Row(
                    children: [
                      Icon(
                        _icons[mode],
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(_labels[mode]!),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (!expanded) return dropdown;

    return SizedBox(width: double.infinity, child: dropdown);
  }
}
