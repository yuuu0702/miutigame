import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/game_mode_button.dart';
import 'memory_game_screen.dart';
import 'slot_game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainMenuGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                AppConstants.appTitle,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              GameModeButton(
                title: '神経衰弱',
                icon: Icons.psychology,
                color: Colors.green,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MemoryGameScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GameModeButton(
                title: 'GODスロット',
                icon: Icons.casino,
                color: Colors.orange,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SlotGameScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}