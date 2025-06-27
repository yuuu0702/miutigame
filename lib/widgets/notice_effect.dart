import 'package:flutter/material.dart';
import 'dart:math';

enum NoticeLevel {
  weak,    // 弱予告（青）
  medium,  // 中予告（黄）
  strong,  // 強予告（赤）
  super_,  // 激アツ（虹）
}

class NoticeEffect extends StatefulWidget {
  final NoticeLevel level;
  final Duration duration;
  final VoidCallback? onComplete;

  const NoticeEffect({
    super.key,
    required this.level,
    this.duration = const Duration(milliseconds: 3000),
    this.onComplete,
  });

  @override
  State<NoticeEffect> createState() => _NoticeEffectState();
}

class _NoticeEffectState extends State<NoticeEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;
  
  List<Particle> particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.5, curve: Curves.bounceOut),
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);

    _generateParticles();
    _startEffect();
  }

  void _generateParticles() {
    particles.clear();
    int particleCount = _getParticleCount();
    
    for (int i = 0; i < particleCount; i++) {
      particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 6 + 2,
        speed: _random.nextDouble() * 2 + 1,
        color: _getParticleColor(),
      ));
    }
  }

  int _getParticleCount() {
    switch (widget.level) {
      case NoticeLevel.weak: return 10;
      case NoticeLevel.medium: return 20;
      case NoticeLevel.strong: return 30;
      case NoticeLevel.super_: return 50;
    }
  }

  Color _getParticleColor() {
    switch (widget.level) {
      case NoticeLevel.weak: return Colors.lightBlue;
      case NoticeLevel.medium: return Colors.yellow;
      case NoticeLevel.strong: return Colors.red;
      case NoticeLevel.super_: return Colors.purple;
    }
  }

  Color _getBackgroundColor() {
    switch (widget.level) {
      case NoticeLevel.weak: return Colors.blue.withOpacity(0.3);
      case NoticeLevel.medium: return Colors.orange.withOpacity(0.4);
      case NoticeLevel.strong: return Colors.red.withOpacity(0.5);
      case NoticeLevel.super_: return Colors.purple.withOpacity(0.6);
    }
  }

  String _getNoticeText() {
    switch (widget.level) {
      case NoticeLevel.weak: return '予告';
      case NoticeLevel.medium: return 'チャンス！';
      case NoticeLevel.strong: return '激アツ！';
      case NoticeLevel.super_: return '超激アツ！！';
    }
  }

  void _startEffect() {
    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete?.call();
      }
    });

    _particleController.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _particleController]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // 背景エフェクト
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      _getBackgroundColor(),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // パーティクル
              CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(
                  particles: particles,
                  progress: _particleAnimation.value,
                ),
              ),
              // メイン予告テキスト
              Positioned(
                left: MediaQuery.of(context).size.width * _slideAnimation.value,
                top: MediaQuery.of(context).size.height * 0.3,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _getParticleColor(),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getParticleColor().withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      _getNoticeText(),
                      style: TextStyle(
                        color: _getParticleColor(),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
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

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(0.8)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = (particle.y + progress * particle.speed) % 1.0 * size.height;

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}