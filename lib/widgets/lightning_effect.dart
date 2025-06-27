import 'package:flutter/material.dart';
import 'dart:math';

class LightningEffect extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  const LightningEffect({
    super.key,
    this.duration = const Duration(milliseconds: 1500),
    this.onComplete,
  });

  @override
  State<LightningEffect> createState() => _LightningEffectState();
}

class _LightningEffectState extends State<LightningEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _flashController;
  late Animation<double> _lightningAnimation;
  late Animation<double> _flashAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _lightningAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));

    _startLightning();
  }

  void _startLightning() {
    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete?.call();
      }
    });

    // ランダムなタイミングでフラッシュ
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: _random.nextInt(1500)), () {
        if (mounted) {
          _flashController.forward().then((_) {
            _flashController.reverse();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_lightningAnimation, _flashAnimation]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: LightningPainter(
              progress: _lightningAnimation.value,
              flashIntensity: _flashAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class LightningPainter extends CustomPainter {
  final double progress;
  final double flashIntensity;
  final Random _random = Random();

  LightningPainter({
    required this.progress,
    required this.flashIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.8 + flashIntensity * 0.2)
      ..strokeWidth = 3.0 + flashIntensity * 2.0
      ..style = PaintingStyle.stroke;

    // 複数の稲妻を描画
    for (int i = 0; i < 3; i++) {
      _drawLightning(canvas, size, paint, i);
    }

    // フラッシュエフェクト
    if (flashIntensity > 0) {
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity(flashIntensity * 0.3);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  void _drawLightning(Canvas canvas, Size size, Paint paint, int index) {
    final path = Path();
    final startX = size.width * (0.2 + index * 0.3);
    final endX = startX + (_random.nextDouble() - 0.5) * 100;
    
    path.moveTo(startX, 0);
    
    double currentY = 0;
    double currentX = startX;
    
    while (currentY < size.height * progress) {
      currentY += 20 + _random.nextDouble() * 40;
      currentX += (_random.nextDouble() - 0.5) * 60;
      path.lineTo(currentX, currentY);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LightningPainter oldDelegate) {
    return progress != oldDelegate.progress || 
           flashIntensity != oldDelegate.flashIntensity;
  }
}