import 'package:flutter/material.dart';
import 'dart:math';
import '../constants/app_colors.dart';

class GodCutinEffect extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onComplete;

  const GodCutinEffect({
    super.key,
    required this.imagePath,
    this.onComplete,
  });

  @override
  State<GodCutinEffect> createState() => _GodCutinEffectState();
}

class _GodCutinEffectState extends State<GodCutinEffect>
    with TickerProviderStateMixin {
  late AnimationController mainController;
  late AnimationController rotationController;
  late AnimationController pulseController;
  
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> rotationAnimation;
  late Animation<double> pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    mainController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: mainController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    ));
    
    rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: rotationController,
      curve: Curves.linear,
    ));
    
    pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: pulseController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    // パルス効果を繰り返し
    pulseController.repeat(reverse: true);
    
    // 回転効果を繰り返し
    rotationController.repeat();
    
    // メインアニメーション開始
    await mainController.forward();
    
    // 完了コールバック
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    mainController.dispose();
    rotationController.dispose();
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: mainController,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    AppColors.gold.withValues(alpha: 0.3),
                    Colors.orange.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // 回転する光のリング
                  _buildRotatingRings(),
                  
                  // 中央の画像
                  Center(
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      child: AnimatedBuilder(
                        animation: pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: pulseAnimation.value,
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.8),
                                    blurRadius: 50,
                                    spreadRadius: 20,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  widget.imagePath,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // GODテキスト
                  _buildGodText(),
                  
                  // 星のエフェクト
                  _buildStarEffect(),
                  
                  // 光のビーム
                  _buildLightBeams(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRotatingRings() {
    return AnimatedBuilder(
      animation: rotationController,
      builder: (context, child) {
        return Center(
          child: Transform.rotate(
            angle: rotationAnimation.value,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: CustomPaint(
                size: const Size(400, 400),
                painter: RingPainter(
                  color: AppColors.gold,
                  progress: scaleAnimation.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildGodText() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: pulseAnimation.value,
              child: Text(
                '⚡ GOD降臨 ⚡',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 0),
                      blurRadius: 20,
                      color: AppColors.gold.withValues(alpha: 0.8),
                    ),
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildStarEffect() {
    return AnimatedBuilder(
      animation: mainController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: StarEffectPainter(
            progress: scaleAnimation.value,
            color: AppColors.gold,
          ),
        );
      },
    );
  }
  
  Widget _buildLightBeams() {
    return AnimatedBuilder(
      animation: rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: -rotationAnimation.value * 0.5,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: CustomPaint(
              size: MediaQuery.of(context).size,
              painter: LightBeamPainter(
                color: AppColors.gold,
                progress: scaleAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class RingPainter extends CustomPainter {
  final Color color;
  final double progress;
  
  RingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    // 複数のリングを描画
    for (int i = 0; i < 3; i++) {
      final radius = (50 + i * 30) * progress;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StarEffectPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  StarEffectPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8 * progress)
      ..style = PaintingStyle.fill;
    
    final random = Random(12345); // 固定シードで一貫した位置
    
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = (2 + random.nextDouble() * 8) * progress;
      
      _drawStar(canvas, Offset(x, y), starSize, paint);
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const int points = 5;
    const double angle = 2 * pi / points;
    
    for (int i = 0; i < points; i++) {
      final outerAngle = i * angle - pi / 2;
      final innerAngle = (i + 0.5) * angle - pi / 2;
      
      final outerX = center.dx + cos(outerAngle) * size;
      final outerY = center.dy + sin(outerAngle) * size;
      final innerX = center.dx + cos(innerAngle) * size * 0.5;
      final innerY = center.dy + sin(innerAngle) * size * 0.5;
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LightBeamPainter extends CustomPainter {
  final Color color;
  final double progress;
  
  LightBeamPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final paint = Paint()
      ..color = color.withValues(alpha: 0.2 * progress)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // 十字の光のビーム
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final endX = center.dx + cos(angle) * size.width * progress;
      final endY = center.dy + sin(angle) * size.height * progress;
      
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(endX, endY)
        ..lineTo(endX + 20, endY)
        ..lineTo(center.dx + 10, center.dy)
        ..close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}