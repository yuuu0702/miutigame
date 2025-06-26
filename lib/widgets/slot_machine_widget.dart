import 'package:flutter/material.dart';
import '../models/slot_game_state.dart';
import '../constants/app_colors.dart';

class SlotMachineWidget extends StatelessWidget {
  final SlotGameState gameState;
  final List<Animation<double>> reelAnimations;

  const SlotMachineWidget({
    super.key,
    required this.gameState,
    required this.reelAnimations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) => _buildReel(index)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              gameState.message,
              style: TextStyle(
                color: gameState.isGodMode ? AppColors.gold : Colors.white,
                fontSize: gameState.isGodMode ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReel(int reelIndex) {
    return Container(
      width: 80,
      height: 240, // 3つの図柄を表示するために高さを拡大
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AnimatedBuilder(
          animation: reelAnimations[reelIndex],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                gameState.isSpinning[reelIndex]
                    ? -reelAnimations[reelIndex].value *
                          2000 // 上から下へより高速回転
                    : 0,
              ),
              child: Column(children: _buildReelSymbols(reelIndex)),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildReelSymbols(int reelIndex) {
    final symbols = gameState.reels[reelIndex];
    final currentPos = gameState.currentPositions[reelIndex];
    List<Widget> symbolWidgets = [];

    // スピン中は複数の図柄を高速で表示
    if (gameState.isSpinning[reelIndex]) {
      for (int i = 0; i < 10; i++) {
        // 10個の図柄を循環表示
        final symbolIndex = (currentPos + i) % symbols.length;
        symbolWidgets.add(_buildSymbolWidget(symbols[symbolIndex], false));
      }
    } else {
      // 停止時は上下の図柄も表示（日本のスロット風）
      for (int i = -1; i <= 1; i++) {
        final symbolIndex = (currentPos + i + symbols.length) % symbols.length;
        final isCenter = i == 0;
        symbolWidgets.add(_buildSymbolWidget(symbols[symbolIndex], isCenter));
      }
    }

    return symbolWidgets;
  }

  Widget _buildSymbolWidget(String symbolPath, bool isCenter) {
    final isGodSymbol = symbolPath == 'assets/god.png';

    return Container(
      width: 76,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: isCenter && isGodSymbol
            ? Border.all(color: AppColors.gold, width: 3)
            : null,
        boxShadow: isCenter && isGodSymbol
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          symbolPath,
          fit: BoxFit.cover,
          opacity: isCenter ? null : const AlwaysStoppedAnimation(0.6),
        ),
      ),
    );
  }
}
