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
import '../widgets/cutin_effect.dart';
import '../widgets/god_cutin_effect.dart';
import '../widgets/pre_effect_widget.dart';
import '../widgets/reel_flash_effect.dart';
import '../widgets/freeze_effect.dart';
import '../widgets/lightning_effect.dart';
import '../widgets/aura_effect.dart';
import '../widgets/notice_effect.dart';
import '../widgets/reel_glow_effect.dart';
import '../widgets/symbol_shine_effect.dart';
import '../models/slot_result.dart';
import '../services/internal_lottery_service.dart';

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

  bool showCutin = false;
  bool showGodCutin = false;
  String? cutinImagePath;

  // オート機能
  Timer? autoTimer;
  bool isAutoPausedForCutin = false;

  // 演出関連
  bool showPreEffect = false;
  bool showReelFlash = false;
  bool showFreeze = false;
  bool showLightning = false;
  bool showAura = false;
  bool showNotice = false;
  NoticeLevel currentNoticeLevel = NoticeLevel.weak;
  List<int> glowingReels = [];
  SlotResult? internalResult;

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
      isAutoMode: false,
      autoSpinsRemaining: 0,
      autoSpinCount: 0,
    );
  }

  void _initializeAnimations() {
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 4500 + (i * 500)), // より長いスピン時間
        vsync: this,
      );
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

      reelControllers.add(controller);
      reelAnimations.add(animation);
    }

    explosionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    explosionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: explosionController!, curve: Curves.elasticOut),
    );

    godEffectController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    godEffectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: godEffectController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    for (var controller in reelControllers) {
      controller.dispose();
    }
    explosionController?.dispose();
    autoTimer?.cancel();
    godEffectController?.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (gameState.isSpinning.any((spinning) => spinning) ||
        gameState.credits < gameState.bet ||
        gameState.isAutoMode) {
      return;
    }

    setState(() {
      gameState = gameState.copyWith(
        credits: gameState.credits - gameState.bet,
        message: '',
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
        newPositions[i] = SlotGameService.generateRandomPositions([
          gameState.reels[i],
        ])[0];

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
      gameState.currentPositions,
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
      _triggerReachEffect();
    } else {
      setState(() {
        gameState = gameState.copyWith(message: '');
      });
    }
  }

  void _triggerGodMode() {
    // カットイン演出を先に表示
    setState(() {
      showGodCutin = true;
      cutinImagePath = AppConstants.godSymbol;
      gameState = gameState.copyWith(isCutinActive: true);
    });

    // 3番目のリールのアニメーションを継続
    reelControllers[2].repeat();

    // カットイン演出完了後にGODモード開始
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          showGodCutin = false;
          gameState = gameState.copyWith(message: 'リール調整中...');
        });

        // カットイン終了後、少し回転させてから停止
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              gameState = gameState.copyWith(
                isGodMode: true,
                credits:
                    gameState.credits +
                    (gameState.bet * AppConstants.godMultiplier),
                message: '🎉 GOD降臨！！！ ${AppConstants.godMultiplier}倍獲得！！！ 🎉',
                showExplosion: true,
                isCutinActive: false,
              );
            });

            // 3番目のリールを停止
            reelControllers[2].stop();
            reelControllers[2].reset();

            explosionController!.forward();
            godEffectController!.repeat();
          }
        });

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
    });
  }

  void _triggerWinEffect() {
    explosionController!.forward().then((_) {
      explosionController!.reset();
    });
  }

  void _triggerReachEffect() {
    // リーチ専用カットイン演出
    final cutinImage = AppConstants.cutinImages[0]; // 最初のカットイン画像を使用

    setState(() {
      showCutin = true;
      cutinImagePath = cutinImage;
      gameState = gameState.copyWith(isCutinActive: true);
    });

    // 3番目のリールのアニメーションを継続
    reelControllers[2].repeat();

    // カットイン終了後にメッセージ更新
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showCutin = false;
          gameState = gameState.copyWith(message: 'リール調整中...');
        });

        // カットイン終了後、少し回転させてから停止
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              gameState = gameState.copyWith(message: '', isCutinActive: false);
            });

            // 3番目のリールを停止
            reelControllers[2].stop();
            reelControllers[2].reset();
          }
        });

        // リール振動エフェクト
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
    });
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

  void _startAutoMode() {
    if (gameState.isAutoMode || gameState.credits < gameState.bet) {
      return;
    }

    setState(() {
      gameState = gameState.copyWith(isAutoMode: true);
    });

    _scheduleNextAutoSpin();
  }

  void _stopAutoMode() {
    if (!gameState.isAutoMode) {
      return;
    }

    autoTimer?.cancel();
    setState(() {
      gameState = gameState.copyWith(isAutoMode: false);
    });
  }

  void _scheduleNextAutoSpin() {
    if (!gameState.isAutoMode || gameState.credits < gameState.bet) {
      _stopAutoMode();
      return;
    }

    autoTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted && gameState.isAutoMode) {
        _performInternalLotterySpin();
      }
    });
  }

  Future<void> _performInternalLotterySpin() async {
    if (gameState.isSpinning.any((spinning) => spinning) ||
        gameState.credits < gameState.bet) {
      return;
    }

    // 内部抽選を実行
    final lotteryService = InternalLotteryService();
    internalResult = lotteryService.performLottery();

    // 演出の表示
    await _showPreEffects();

    // スピン実行
    await _executeSpinWithResult();

    // 次のオートスピンをスケジュール
    if (gameState.isAutoMode) {
      _scheduleNextAutoSpin();
    }
  }

  Future<void> _showPreEffects() async {
    if (internalResult == null) return;

    // 予告演出の表示
    if (internalResult!.noticeType != NoticeType.none) {
      setState(() {
        showNotice = true;
        currentNoticeLevel = _convertNoticeType(internalResult!.noticeType);
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        showNotice = false;
      });
    }

    // 稲妻演出
    if (internalResult!.hasLightning) {
      setState(() {
        showLightning = true;
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        showLightning = false;
      });
    }

    // オーラ演出
    if (internalResult!.hasAura) {
      setState(() {
        showAura = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        showAura = false;
      });
    }

    // 激アツ予告の表示（従来の）
    if (internalResult!.shouldShowPreEffect) {
      setState(() {
        showPreEffect = true;
      });

      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        showPreEffect = false;
      });
    }

    // フリーズ演出
    if (internalResult!.shouldShowFreeze) {
      setState(() {
        showFreeze = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        showFreeze = false;
      });
    }
  }

  NoticeLevel _convertNoticeType(NoticeType type) {
    switch (type) {
      case NoticeType.weak:
        return NoticeLevel.weak;
      case NoticeType.medium:
        return NoticeLevel.medium;
      case NoticeType.strong:
        return NoticeLevel.strong;
      case NoticeType.super_:
        return NoticeLevel.super_;
      case NoticeType.none:
        return NoticeLevel.weak;
    }
  }

  Future<void> _executeSpinWithResult() async {
    setState(() {
      gameState = gameState.copyWith(
        credits: gameState.credits - gameState.bet,
        message: '',
        isSpinning: [true, true, true],
        showExplosion: false,
        isGodMode: false,
      );
    });

    // 内部抽選結果に基づいてリール停止位置を決定
    List<int> targetPositions;
    if (internalResult!.isWin) {
      if (internalResult!.resultType == SlotResultType.god) {
        // GOD揃いの位置を設定
        final godIndex = AppConstants.slotSymbols.indexOf(
          AppConstants.godSymbol,
        );
        targetPositions = [godIndex, godIndex, godIndex];
      } else {
        // 通常当たりの位置を設定
        final symbols = AppConstants.slotSymbols;
        final winSymbol = symbols[internalResult!.symbolIndex ?? 0];
        final winIndex = symbols.indexOf(winSymbol);
        targetPositions = [winIndex, winIndex, winIndex];
      }
    } else if (internalResult!.shouldShowReach) {
      // リーチ演出: GODリーチを作る
      final godIndex = AppConstants.slotSymbols.indexOf(AppConstants.godSymbol);
      targetPositions = [
        godIndex,
        godIndex,
        (godIndex + 1) % AppConstants.slotSymbols.length,
      ];
    } else {
      // ハズレ
      targetPositions = SlotGameService.generateRandomPositions(
        gameState.reels,
      );
    }

    // リールアニメーション実行
    for (int i = 0; i < 3; i++) {
      reelControllers[i].reset();
      reelControllers[i].forward();

      int delay;
      if (internalResult!.shouldShowReach) {
        // リーチの場合：1番目、2番目は通常、3番目は長時間回転
        delay = i < 2 ? 1000 + (i * 500) : 4000; // 3番目のリールは4秒後に停止
      } else {
        // 通常：順次停止
        delay = 1000 + (i * 300);
      }

      Future.delayed(Duration(milliseconds: delay), () {
        final newPositions = [...gameState.currentPositions];
        newPositions[i] = targetPositions[i];

        final newIsSpinning = [...gameState.isSpinning];
        newIsSpinning[i] = false;

        setState(() {
          gameState = gameState.copyWith(
            currentPositions: newPositions,
            isSpinning: newIsSpinning,
          );
        });

        // リーチ演出：2番目が停止した時点でリーチ状態を検出
        if (internalResult!.shouldShowReach && i == 1) {
          setState(() {
            gameState = gameState.copyWith(message: 'GODリーチ！！！');
          });

          // リール光演出を開始
          if (internalResult!.hasReelGlow) {
            setState(() {
              glowingReels = internalResult!.glowingReels;
            });
          }
        }

        if (i == 2) {
          _processInternalResult();
        }
      });
    }
  }

  void _processInternalResult() {
    if (internalResult == null) return;

    // カットイン演出がある場合、Autoを一時停止
    if (internalResult!.cutinImagePath != null && gameState.isAutoMode) {
      isAutoPausedForCutin = true;
      autoTimer?.cancel();
    }

    if (internalResult!.isWin) {
      if (internalResult!.resultType == SlotResultType.god) {
        _triggerGodModeWithCutin();
      } else {
        _triggerWinWithCutin();
      }
    } else if (internalResult!.shouldShowReach) {
      _triggerReachWithCutin();
    } else {
      setState(() {
        gameState = gameState.copyWith(message: 'ハズレ... もう一度！');
      });
      _resumeAutoIfNeeded();
    }

    // 内部抽選結果をリセット
    internalResult = null;
  }

  void _resumeAutoIfNeeded() {
    if (isAutoPausedForCutin && gameState.isAutoMode) {
      isAutoPausedForCutin = false;
      _scheduleNextAutoSpin();
    }
  }

  void _triggerGodModeWithCutin() {
    if (internalResult?.cutinImagePath != null) {
      setState(() {
        showGodCutin = true;
        cutinImagePath = internalResult!.cutinImagePath;
        gameState = gameState.copyWith(isCutinActive: true);
      });

      // 3番目のリールのアニメーションを継続
      reelControllers[2].repeat();

      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            showGodCutin = false;
            gameState = gameState.copyWith(message: 'リール調整中...');
          });

          // カットイン終了後、少し回転させてから停止
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                gameState = gameState.copyWith(
                  isGodMode: true,
                  credits:
                      gameState.credits +
                      (gameState.bet * AppConstants.godMultiplier),
                  message: '🎉 GOD降臨！！！ ${AppConstants.godMultiplier}倍獲得！！！ 🎉',
                  showExplosion: true,
                  isCutinActive: false,
                );
              });

              // 3番目のリールを停止
              reelControllers[2].stop();
              reelControllers[2].reset();

              explosionController!.forward();
              godEffectController!.repeat();
            }
          });

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
              _resumeAutoIfNeeded();
            }
          });
        }
      });
    } else {
      _triggerGodMode();
    }
  }

  void _triggerWinWithCutin() {
    if (internalResult?.cutinImagePath != null) {
      setState(() {
        showCutin = true;
        cutinImagePath = internalResult!.cutinImagePath;
        gameState = gameState.copyWith(isCutinActive: true);
      });

      // 3番目のリールのアニメーションを継続
      reelControllers[2].repeat();

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showCutin = false;
            gameState = gameState.copyWith(message: 'リール調整中...');
          });

          // カットイン終了後、少し回転させてから停止
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              // 3番目のリールを停止
              reelControllers[2].stop();
              reelControllers[2].reset();

              final multiplier = internalResult!.multiplier;
              final win = (gameState.bet * multiplier).toInt();
              setState(() {
                gameState = gameState.copyWith(
                  credits: gameState.credits + win,
                  message: '当たり！ $win枚獲得！',
                  isCutinActive: false,
                );
              });
              _triggerWinEffect();
              _resumeAutoIfNeeded();
            }
          });
        }
      });
    } else {
      final multiplier = internalResult!.multiplier;
      final win = (gameState.bet * multiplier).toInt();
      setState(() {
        gameState = gameState.copyWith(
          credits: gameState.credits + win,
          message: '当たり！ $win枚獲得！',
        );
      });
      _triggerWinEffect();
      _resumeAutoIfNeeded();
    }
  }

  void _triggerReachWithCutin() {
    if (internalResult?.cutinImagePath != null) {
      setState(() {
        showCutin = true;
        cutinImagePath = internalResult!.cutinImagePath;
        gameState = gameState.copyWith(isCutinActive: true);
      });

      // 3番目のリールのアニメーションを継続
      reelControllers[2].repeat();

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showCutin = false;
            gameState = gameState.copyWith(message: 'リール調整中...');
          });

          // カットイン終了後、少し回転させてから停止
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                gameState = gameState.copyWith(
                  message: 'GODリーチ！惜しい！次に期待！',
                  isCutinActive: false,
                );
              });

              // 3番目のリールを停止
              reelControllers[2].stop();
              reelControllers[2].reset();
            }
          });

          for (int i = 0; i < 3; i++) {
            Future.delayed(Duration(milliseconds: i * 200), () {
              if (mounted) {
                reelControllers[0].forward().then((_) {
                  reelControllers[0].reset();
                });
              }
            });
          }
          _resumeAutoIfNeeded();
        }
      });
    } else {
      _triggerReachEffect();
      _resumeAutoIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('なおスロット'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.slotMachineGradient,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                SlotInfoPanel(credits: gameState.credits, bet: gameState.bet),
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
                  onAutoStart: _startAutoMode,
                  onAutoStop: _stopAutoMode,
                  isAutoMode: gameState.isAutoMode,
                  canSpin:
                      !gameState.isSpinning.any((s) => s) &&
                      gameState.credits >= gameState.bet &&
                      !gameState.isAutoMode,
                ),
              ],
            ),
            if (gameState.showExplosion)
              ExplosionEffect(animation: explosionAnimation!),
            if (gameState.isGodMode) GodEffect(animation: godEffectAnimation!),
            if (showGodCutin && cutinImagePath != null)
              GodCutinEffect(
                imagePath: cutinImagePath!,
                onComplete: () {
                  setState(() {
                    showGodCutin = false;
                  });
                },
              ),
            if (showCutin && cutinImagePath != null)
              CutinEffect(
                imagePath: cutinImagePath!,
                onComplete: () {
                  setState(() {
                    showCutin = false;
                  });
                },
              ),
            if (showPreEffect)
              PreEffectWidget(
                onComplete: () {
                  setState(() {
                    showPreEffect = false;
                  });
                },
              ),
            if (showFreeze)
              FreezeEffect(
                duration: const Duration(seconds: 2),
                onComplete: () {
                  setState(() {
                    showFreeze = false;
                  });
                },
              ),
            if (showReelFlash)
              ReelFlashEffect(
                reelIndex: 0,
                onComplete: () {
                  setState(() {
                    showReelFlash = false;
                  });
                },
              ),
            // 新しい演出エフェクト
            if (showLightning)
              LightningEffect(
                onComplete: () {
                  setState(() {
                    showLightning = false;
                  });
                },
              ),
            if (showAura)
              AuraEffect(
                color: Colors.purple,
                onComplete: () {
                  setState(() {
                    showAura = false;
                  });
                },
              ),
            if (showNotice)
              NoticeEffect(
                level: currentNoticeLevel,
                onComplete: () {
                  setState(() {
                    showNotice = false;
                  });
                },
              ),
            // リール光演出
            ...glowingReels.map(
              (reelIndex) => ReelGlowEffect(
                reelIndex: reelIndex,
                glowColor: Colors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
