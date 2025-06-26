import 'package:flutter/material.dart';
import 'dart:math';

class CutinEffect extends StatefulWidget {
  final String imagePath;
  final Duration duration;
  final VoidCallback? onComplete;

  const CutinEffect({
    super.key,
    required this.imagePath,
    this.duration = const Duration(seconds: 3),
    this.onComplete,
  });

  @override
  State<CutinEffect> createState() => _CutinEffectState();
}

class _CutinEffectState extends State<CutinEffect>
    with TickerProviderStateMixin {
  late AnimationController slideController;
  late AnimationController fadeController;
  late AnimationController scaleController;
  
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    slideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.elasticOut,
    ));
    
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeIn,
    ));
    
    scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.elasticOut,
    ));
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    // スライドインアニメーション
    await slideController.forward();
    
    // フェードインとスケールアニメーション（同時実行）
    await Future.wait([
      fadeController.forward(),
      scaleController.forward(),
    ]);
    
    // 表示時間を待つ
    await Future.delayed(widget.duration);
    
    // フェードアウト
    await fadeController.reverse();
    
    // 完了コールバック
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    slideController.dispose();
    fadeController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Stack(
          children: [
            // 背景エフェクト
            _buildBackgroundEffect(),
            
            // メイン画像
            Center(
              child: SlideTransition(
                position: slideAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 光のエフェクト
            _buildLightEffect(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBackgroundEffect() {
    return AnimatedBuilder(
      animation: scaleController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: scaleAnimation.value,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLightEffect() {
    return AnimatedBuilder(
      animation: fadeController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: LightRayPainter(
              progress: fadeAnimation.value,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class LightRayPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  LightRayPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 * progress)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // 放射状の光線を描画
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + (progress * pi / 4);
      final endX = center.dx + cos(angle) * size.width * progress;
      final endY = center.dy + sin(angle) * size.height * progress;
      
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(endX, endY)
        ..lineTo(endX + 10, endY)
        ..lineTo(center.dx + 5, center.dy)
        ..close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}