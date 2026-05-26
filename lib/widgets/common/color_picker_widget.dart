import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'color_swatch_widget.dart';

/// Horizontal accent color picker. Use [onColorChanged] to update app theme.
class ColorPickerWidget extends StatelessWidget {
  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    this.colors = AppAccentColor.values,
    this.label,
    this.spacing = 12,
    this.swatchSize = 40,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  final List<AppAccentColor> colors;
  final String? label;
  final double spacing;
  final double swatchSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final preset in colors)
              ColorSwatchWidget(
                color: preset.color,
                selected:
                    preset.color.toARGB32() == selectedColor.toARGB32(),
                size: swatchSize,
                onTap: () => onColorChanged(preset.color),
              ),
          ],
        ),
      ],
    );
  }
}
