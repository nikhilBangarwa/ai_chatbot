import 'package:flutter/material.dart';

/// A single circular color swatch with optional selection ring.
class ColorSwatchWidget extends StatelessWidget {
  const ColorSwatchWidget({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
    this.size = 40,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.dividerColor.withValues(alpha: 0.4),
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  size: size * 0.45,
                  color: _contrastIconColor(color),
                )
              : null,
        ),
      ),
    );
  }

  Color _contrastIconColor(Color background) {
    return background.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }
}
