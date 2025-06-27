import 'package:flutter/material.dart';
import 'dart:math';

class SymbolShineEffect extends StatefulWidget {
  final Widget child;
  final bool isShining;
  final Color shineColor;

  const SymbolShineEffect({
    super.key,
    required this.child,
    this.isShining = false,
    this.shineColor = Colors.white,
  });

  @override
  State<SymbolShineEffect> createState() => _SymbolShineEffectState();
}

class _SymbolShineEffectState extends State<SymbolShineEffect>
    with TickerProviderStateMixin {
  late AnimationController _shineController;
  late AnimationController _rotateController;
  late Animation<double> _shineAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shineController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    if (widget.isShining) {
      _startShining();
    }
  }

  void _startShining() {
    _shineController.repeat();
    _rotateController.repeat();
  }

  void _stopShining() {
    _shineController.stop();
    _rotateController.stop();
  }

  @override
  void didUpdateWidget(SymbolShineEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShining && !oldWidget.isShining) {
      _startShining();
    } else if (!widget.isShining && oldWidget.isShining) {
      _stopShining();
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isShining) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_shineController, _rotateController]),
      builder: (context, child) {
        return Stack(
          children: [
            // 元のシンボル
            widget.child,
            // 回転する光のリング
            Positioned.fill(
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.shineColor.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // 流れる光エフェクト
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(
                  painter: ShinePainter(
                    progress: _shineAnimation.value,
                    color: widget.shineColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ShinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ShinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        color.withOpacity(0.3),
        color.withOpacity(0.8),
        color.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(
          size.width * progress - size.width * 0.5,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(ShinePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}