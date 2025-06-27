import 'package:flutter/material.dart';
import 'dart:math';

class SlotReel extends StatelessWidget {
  final AnimationController controller;
  final String symbol;
  final List<String> symbols;

  const SlotReel({
    super.key,
    required this.controller,
    required this.symbol,
    required this.symbols,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          if (controller.isAnimating) {
            // 回転中は高速でシンボルを切り替え
            final index = (controller.value * symbols.length * 10).floor() % symbols.length;
            return Center(
              child: Transform.translate(
                offset: Offset(0, sin(controller.value * 2 * pi) * 5),
                child: Text(
                  symbols[index],
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            );
          } else {
            // 停止時は固定シンボル
            return Center(
              child: Text(
                symbol,
                style: const TextStyle(fontSize: 36),
              ),
            );
          }
        },
      ),
    );
  }
}