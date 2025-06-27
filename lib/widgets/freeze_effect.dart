import 'package:flutter/material.dart';
import 'dart:math';

class FreezeEffect extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  const FreezeEffect({
    super.key,
    required this.duration,
    this.onComplete,
  });

  @override
  State<FreezeEffect> createState() => _FreezeEffectState();
}

class _FreezeEffectState extends State<FreezeEffect>
    with TickerProviderStateMixin {
  late AnimationController iceController;
  late AnimationController textController;
  late Animation<double> iceAnimation;
  late Animation<double> textAnimation;

  @override
  void initState() {
    super.initState();
    
    iceController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    iceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: iceController,
      curve: Curves.easeInOut,
    ));
    
    textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: textController,
      curve: Curves.elasticOut,
    ));
    
    _startFreeze();
  }
  
  void _startFreeze() async {
    // テキストアニメーション開始
    textController.forward();
    
    // 氷エフェクト開始
    iceController.forward();
    
    // 指定時間待機
    await Future.delayed(widget.duration);
    
    // テキスト消去
    await textController.reverse();
    
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    iceController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: iceController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue.withValues(alpha: 0.3 * iceAnimation.value),
                  Colors.white.withValues(alpha: 0.2 * iceAnimation.value),
                  Colors.lightBlue.withValues(alpha: 0.3 * iceAnimation.value),
                ],
              ),
            ),
            child: Stack(
              children: [
                // 氷の結晶エフェクト
                ...List.generate(15, (index) {
                  final random = Random(index);
                  final x = random.nextDouble();
                  final y = random.nextDouble();
                  final size = 10 + random.nextDouble() * 20;
                  
                  return Positioned(
                    left: MediaQuery.of(context).size.width * x,
                    top: MediaQuery.of(context).size.height * y,
                    child: AnimatedBuilder(
                      animation: iceController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: iceAnimation.value * 2 * pi,
                          child: Opacity(
                            opacity: iceAnimation.value,
                            child: Icon(
                              Icons.ac_unit,
                              size: size,
                              color: Colors.lightBlue[200],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                
                // フリーズテキスト
                Center(
                  child: AnimatedBuilder(
                    animation: textController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: textAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.lightBlue,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.lightBlue.withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'フリーズ！',
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}