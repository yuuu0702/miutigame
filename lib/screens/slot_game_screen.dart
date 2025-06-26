import 'package:flutter/material.dart';
import 'dart:async';
import '../models/slot_game_state.dart';
import '../services/slot_game_service.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../widgets/slot_machine_widget.dart';
import '../widgets/slot_control_panel.dart';
import '../widgets/slot_info_panel.dart';
import '../widgets/explosion_effect.dart';
import '../widgets/god_effect.dart';

class SlotGameScreen extends StatefulWidget {
  const SlotGameScreen({super.key});

  @override
  State<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends State<SlotGameScreen>
    with TickerProviderStateMixin {
  late SlotGameState gameState;
  List<AnimationController> reelControllers = [];
  List<Animation<double>> reelAnimations = [];
  
  AnimationController? explosionController;
  AnimationController? godEffectController;
  Animation<double>? explosionAnimation;
  Animation<double>? godEffectAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
  }
  
  void _initializeGame() {
    gameState = SlotGameState(
      reels: [
        AppConstants.slotSymbols,
        AppConstants.slotSymbols,
        AppConstants.slotSymbols,
      ],
      currentPositions: [0, 0, 0],
      isSpinning: [false, false, false],
      credits: AppConstants.initialCredits,
      bet: AppConstants.initialBet,
    );
  }
  
  void _initializeAnimations() {
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 1000 + (i * 200)),
        vsync: this,
      );
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
      
      reelControllers.add(controller);
      reelAnimations.add(animation);
    }
    
    explosionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    explosionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: explosionController!,
      curve: Curves.elasticOut,
    ));
    
    godEffectController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    godEffectAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: godEffectController!,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    for (var controller in reelControllers) {
      controller.dispose();
    }
    explosionController?.dispose();
    godEffectController?.dispose();
    super.dispose();
  }
  
  Future<void> _spin() async {
    if (gameState.isSpinning.any((spinning) => spinning) || 
        gameState.credits < gameState.bet) {
      return;
    }
    
    setState(() {
      gameState = gameState.copyWith(
        credits: gameState.credits - gameState.bet,
        message: 'スピン中...',
        isSpinning: [true, true, true],
        showExplosion: false,
        isGodMode: false,
      );
    });
    
    for (int i = 0; i < 3; i++) {
      reelControllers[i].reset();
      reelControllers[i].forward();
      
      Future.delayed(Duration(milliseconds: 1000 + (i * 200)), () {
        final newPositions = [...gameState.currentPositions];
        newPositions[i] = SlotGameService.generateRandomPositions([gameState.reels[i]])[0];
        
        final newIsSpinning = [...gameState.isSpinning];
        newIsSpinning[i] = false;
        
        setState(() {
          gameState = gameState.copyWith(
            currentPositions: newPositions,
            isSpinning: newIsSpinning,
          );
        });
        
        if (i == 2) {
          _checkResult();
        }
      });
    }
  }
  
  void _checkResult() {
    final symbols = SlotGameService.getSymbolsFromPositions(
      gameState.reels, 
      gameState.currentPositions
    );
    
    if (SlotGameService.isGodMatch(symbols)) {
      _triggerGodMode();
    } else if (SlotGameService.isRegularMatch(symbols)) {
      final multiplier = SlotGameService.getMultiplier(symbols[0]);
      final win = gameState.bet * multiplier;
      setState(() {
        gameState = gameState.copyWith(
          credits: gameState.credits + win,
          message: '${symbols[0]} 揃い！ $win枚獲得！',
        );
      });
      _triggerWinEffect();
    } else if (SlotGameService.isGodReach(symbols)) {
      setState(() {
        gameState = gameState.copyWith(
          message: 'GODリーチ！惜しい！',
        );
      });
      _triggerReachEffect();
    } else {
      setState(() {
        gameState = gameState.copyWith(
          message: 'ハズレ... もう一度！',
        );
      });
    }
  }
  
  void _triggerGodMode() {
    setState(() {
      gameState = gameState.copyWith(
        isGodMode: true,
        credits: gameState.credits + (gameState.bet * AppConstants.godMultiplier),
        message: '🎉 GOD降臨！！！ ${AppConstants.godMultiplier}倍獲得！！！ 🎉',
        showExplosion: true,
      );
    });
    
    explosionController!.forward();
    godEffectController!.repeat();
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          gameState = gameState.copyWith(
            showExplosion: false,
            isGodMode: false,
          );
        });
        godEffectController!.stop();
        godEffectController!.reset();
      }
    });
  }
  
  void _triggerWinEffect() {
    explosionController!.forward().then((_) {
      explosionController!.reset();
    });
  }
  
  void _triggerReachEffect() {
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          reelControllers[0].forward().then((_) {
            reelControllers[0].reset();
          });
        }
      });
    }
  }
  
  void _adjustBet(bool increase) {
    if (increase) {
      if (gameState.bet < AppConstants.maxBet && 
          gameState.credits >= gameState.bet + AppConstants.betIncrement) {
        setState(() {
          gameState = gameState.copyWith(
            bet: gameState.bet + AppConstants.betIncrement,
          );
        });
      }
    } else {
      if (gameState.bet > AppConstants.minBet) {
        setState(() {
          gameState = gameState.copyWith(
            bet: gameState.bet - AppConstants.betIncrement,
          );
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GODスロット'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.slotMachineGradient),
        child: Stack(
          children: [
            Column(
              children: [
                SlotInfoPanel(
                  credits: gameState.credits,
                  bet: gameState.bet,
                ),
                Expanded(
                  child: Center(
                    child: SlotMachineWidget(
                      gameState: gameState,
                      reelAnimations: reelAnimations,
                    ),
                  ),
                ),
                SlotControlPanel(
                  onSpin: _spin,
                  onBetDecrease: () => _adjustBet(false),
                  onBetIncrease: () => _adjustBet(true),
                ),
              ],
            ),
            if (gameState.showExplosion)
              ExplosionEffect(animation: explosionAnimation!),
            if (gameState.isGodMode)
              GodEffect(animation: godEffectAnimation!),
          ],
        ),
      ),
    );
  }
}