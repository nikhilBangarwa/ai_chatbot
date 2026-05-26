import 'package:flutter/material.dart';

/// Groups settings controls with a title — useful on a settings / profile screen.
class SettingsSectionWidget extends StatelessWidget {
  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
