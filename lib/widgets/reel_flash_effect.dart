import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ReelFlashEffect extends StatefulWidget {
  final int reelIndex;
  final VoidCallback? onComplete;

  const ReelFlashEffect({
    super.key,
    required this.reelIndex,
    this.onComplete,
  });

  @override
  State<ReelFlashEffect> createState() => _ReelFlashEffectState();
}

class _ReelFlashEffectState extends State<ReelFlashEffect>
    with TickerProviderStateMixin {
  late AnimationController flashController;
  late Animation<double> flashAnimation;

  @override
  void initState() {
    super.initState();
    
    flashController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: flashController,
      curve: Curves.easeInOut,
    ));
    
    _startFlash();
  }
  
  void _startFlash() async {
    for (int i = 0; i < 3; i++) {
      await flashController.forward();
      await flashController.reverse();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flashController,
      builder: (context, child) {
        return Positioned(
          left: 50 + (widget.reelIndex * 90.0), // リールの位置に合わせて調整
          top: 100,
          child: Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: flashAnimation.value),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.8 * flashAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}