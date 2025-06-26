import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ExplosionEffect extends StatelessWidget {
  final Animation<double> animation;

  const ExplosionEffect({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: animation.value,
                colors: [
                  AppColors.gold.withValues(alpha: 0.8),
                  Colors.orange.withValues(alpha: 0.6),
                  Colors.red.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}