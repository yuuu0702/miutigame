import 'slot_result.dart';

class SlotGameState {
  final List<List<String>> reels;
  final List<int> currentPositions;
  final List<bool> isSpinning;
  final bool isGodMode;
  final bool showExplosion;
  final int credits;
  final int bet;
  final String message;
  
  // オート機能関連
  final bool isAutoMode;
  final int autoSpinsRemaining;
  final int autoSpinCount;
  
  // 演出関連
  final bool showPreEffect;
  final bool showReelFlash;
  final SlotResult? currentResult;
  final bool hasInternalResult; // 内部抽選結果があるかどうか
  final bool isCutinActive; // カットイン演出中かどうか
  
  const SlotGameState({
    required this.reels,
    required this.currentPositions,
    required this.isSpinning,
    this.isGodMode = false,
    this.showExplosion = false,
    this.credits = 1000,
    this.bet = 10,
    this.message = 'レバーを引いてゲーム開始！',
    this.isAutoMode = false,
    this.autoSpinsRemaining = 0,
    this.autoSpinCount = 0,
    this.showPreEffect = false,
    this.showReelFlash = false,
    this.currentResult,
    this.hasInternalResult = false,
    this.isCutinActive = false,
  });
  
  SlotGameState copyWith({
    List<List<String>>? reels,
    List<int>? currentPositions,
    List<bool>? isSpinning,
    bool? isGodMode,
    bool? showExplosion,
    int? credits,
    int? bet,
    String? message,
    bool? isAutoMode,
    int? autoSpinsRemaining,
    int? autoSpinCount,
    bool? showPreEffect,
    bool? showReelFlash,
    SlotResult? currentResult,
    bool? hasInternalResult,
    bool? isCutinActive,
  }) {
    return SlotGameState(
      reels: reels ?? this.reels,
      currentPositions: currentPositions ?? this.currentPositions,
      isSpinning: isSpinning ?? this.isSpinning,
      isGodMode: isGodMode ?? this.isGodMode,
      showExplosion: showExplosion ?? this.showExplosion,
      credits: credits ?? this.credits,
      bet: bet ?? this.bet,
      message: message ?? this.message,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      autoSpinsRemaining: autoSpinsRemaining ?? this.autoSpinsRemaining,
      autoSpinCount: autoSpinCount ?? this.autoSpinCount,
      showPreEffect: showPreEffect ?? this.showPreEffect,
      showReelFlash: showReelFlash ?? this.showReelFlash,
      currentResult: currentResult ?? this.currentResult,
      hasInternalResult: hasInternalResult ?? this.hasInternalResult,
      isCutinActive: isCutinActive ?? this.isCutinActive,
    );
  }
}