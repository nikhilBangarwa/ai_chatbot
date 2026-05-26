import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

/// App logo (A + robot) — use on login, signup, and headers.
class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({
    super.key,
    this.size = 88,
    this.showShadow = true,
  });

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppAssets.appLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showShadow) return image;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            blurRadius: size * 0.35,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: image,
    );
  }
}
