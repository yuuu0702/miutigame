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
    return AnimatedBuilder(
      animation: reelAnimations[reelIndex],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0, 
            gameState.isSpinning[reelIndex] 
                ? -reelAnimations[reelIndex].value * 200 
                : 0
          ),
          child: Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: Center(
              child: Text(
                gameState.isSpinning[reelIndex] 
                    ? '?' 
                    : gameState.reels[reelIndex][gameState.currentPositions[reelIndex]],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gameState.reels[reelIndex][gameState.currentPositions[reelIndex]] == 'GOD' 
                      ? AppColors.gold 
                      : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}