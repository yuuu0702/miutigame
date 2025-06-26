import 'package:flutter/material.dart';

class PreEffectWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const PreEffectWidget({
    super.key,
    this.onComplete,
  });

  @override
  State<PreEffectWidget> createState() => _PreEffectWidgetState();
}

class _PreEffectWidgetState extends State<PreEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController flashController;
  late AnimationController textController;
  late Animation<double> flashAnimation;
  late Animation<double> textAnimation;

  @override
  void initState() {
    super.initState();
    
    flashController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: flashController,
      curve: Curves.easeInOut,
    ));
    
    textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: textController,
      curve: Curves.elasticOut,
    ));
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    // フラッシュとテキストを同時開始
    flashController.repeat(reverse: true);
    await textController.forward();
    
    // 少し待機
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 終了
    flashController.stop();
    await textController.reverse();
    
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    flashController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: flashController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.yellow.withValues(alpha: 0.3 * flashAnimation.value),
                  Colors.orange.withValues(alpha: 0.2 * flashAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: textController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: textAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.yellow,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}