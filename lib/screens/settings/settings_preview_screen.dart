import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

/// Demo screen showing theme & color widgets. Reuse widgets on any settings page.
class SettingsPreviewScreen extends StatelessWidget {
  const SettingsPreviewScreen({
    super.key,
    required this.themeMode,
    required this.accentColor,
    required this.onThemeModeChanged,
    required this.onAccentColorChanged,
  });

  final ThemeMode themeMode;
  final Color accentColor;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Color> onAccentColorChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SettingsSectionWidget(
            title: 'Theme',
            children: [
              ThemeDropdownWidget(
                value: themeMode,
                onChanged: onThemeModeChanged,
              ),
            ],
          ),
          SettingsSectionWidget(
            title: 'Accent color',
            children: [
              ColorPickerWidget(
                label: 'Choose accent',
                selectedColor: accentColor,
                onColorChanged: onAccentColorChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
