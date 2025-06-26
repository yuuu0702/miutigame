import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GodEffect extends StatelessWidget {
  final Animation<double> animation;

  const GodEffect({
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFD700).withValues(alpha: 0.3 * animation.value),
                  Colors.transparent,
                  Color(0xFFFFD700).withValues(alpha: 0.3 * animation.value),
                ],
              ),
            ),
            child: Center(
              child: Transform.scale(
                scale: 1.0 + (animation.value * 0.1),
                child: const Text(
                  '⚡ GOD MODE ⚡',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}