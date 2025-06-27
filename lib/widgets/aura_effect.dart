import 'package:flutter/material.dart';
import 'dart:math';

class AuraEffect extends StatefulWidget {
  final Color color;
  final Duration duration;
  final VoidCallback? onComplete;

  const AuraEffect({
    super.key,
    this.color = Colors.purple,
    this.duration = const Duration(milliseconds: 2000),
    this.onComplete,
  });

  @override
  State<AuraEffect> createState() => _AuraEffectState();
}

class _AuraEffectState extends State<AuraEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startEffect();
  }

  void _startEffect() {
    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete?.call();
      }
    });

    // パルス効果
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _pulseController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // メインオーラ
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value * _pulseAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.color.withOpacity(_opacityAnimation.value * 0.6),
                          widget.color.withOpacity(_opacityAnimation.value * 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 外側のリング
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value * 1.2,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withOpacity(_opacityAnimation.value * 0.8),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // 内側のリング
              Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value * 0.8,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.color.withOpacity(_opacityAnimation.value),
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}