import 'package:flutter/material.dart';

class ReelGlowEffect extends StatefulWidget {
  final int reelIndex;
  final Color glowColor;
  final Duration duration;
  final VoidCallback? onComplete;

  const ReelGlowEffect({
    super.key,
    required this.reelIndex,
    this.glowColor = Colors.yellow,
    this.duration = const Duration(milliseconds: 1000),
    this.onComplete,
  });

  @override
  State<ReelGlowEffect> createState() => _ReelGlowEffectState();
}

class _ReelGlowEffectState extends State<ReelGlowEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));

    _startEffect();
  }

  void _startEffect() {
    _controller.repeat(reverse: true).then((_) {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: 30 + (widget.reelIndex * 110.0), // リール位置に合わせる
          top: 200,
          child: Container(
            width: 90,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.glowColor.withOpacity(_glowAnimation.value),
                width: 3 * _pulseAnimation.value,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(_glowAnimation.value * 0.6),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                ),
                BoxShadow(
                  color: widget.glowColor.withOpacity(_glowAnimation.value * 0.3),
                  blurRadius: 40 * _pulseAnimation.value,
                  spreadRadius: 10 * _pulseAnimation.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}