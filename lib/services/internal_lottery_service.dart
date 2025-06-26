import 'dart:math';
import '../models/slot_result.dart';
import '../constants/app_constants.dart';

class InternalLotteryService {
  static final Random _random = Random();
  
  // パチスロ風の内部抽選確率（分母65536）
  static const Map<SlotResultType, int> _probabilities = {
    SlotResultType.god: 256,        // 1/256 (約0.39%)
    SlotResultType.bigWin: 1024,    // 1/64 (約1.56%)
    SlotResultType.mediumWin: 4096, // 1/16 (約6.25%)
    SlotResultType.smallWin: 8192,  // 1/8 (約12.5%)
    SlotResultType.reach: 6554,     // 約10%
    SlotResultType.hazure: 45414,   // 残り（約69.3%）
  };
  
  // 内部抽選を実行（スタート時に結果が決定）
  static SlotResult performInternalLottery() {
    final randomValue = _random.nextInt(65536);
    int cumulativeProbability = 0;
    
    for (final entry in _probabilities.entries) {
      cumulativeProbability += entry.value;
      if (randomValue < cumulativeProbability) {
        return _createResultFromType(entry.key);
      }
    }
    
    // フォールバック（通常は到達しない）
    return _createResultFromType(SlotResultType.hazure);
  }
  
  static SlotResult _createResultFromType(SlotResultType type) {
    switch (type) {
      case SlotResultType.god:
        return SlotResult(
          resultType: type,
          symbols: _generateGodSymbols(),
          payout: AppConstants.godMultiplier,
          effectType: EffectType.god_mode,
          hasPreEffect: _shouldHavePreEffect(type),
          message: '🎉 GOD降臨！！！ ${AppConstants.godMultiplier}倍獲得！！！ 🎉',
        );
        
      case SlotResultType.bigWin:
        final symbols = _generateMatchingSymbols([
          'assets/nao7.png',
          'assets/nao8.png'
        ]);
        final multiplier = AppConstants.symbolMultipliers[symbols[0]] ?? 50;
        return SlotResult(
          resultType: type,
          symbols: symbols,
          payout: multiplier,
          effectType: EffectType.super_strong,
          hasPreEffect: _shouldHavePreEffect(type),
          message: '🔥 BIG WIN！！ ${multiplier}倍獲得！ 🔥',
        );
        
      case SlotResultType.mediumWin:
        final symbols = _generateMatchingSymbols([
          'assets/nao9.png',
          'assets/nao10.png'
        ]);
        final multiplier = AppConstants.symbolMultipliers[symbols[0]] ?? 20;
        return SlotResult(
          resultType: type,
          symbols: symbols,
          payout: multiplier,
          effectType: EffectType.strong,
          hasPreEffect: _shouldHavePreEffect(type),
          message: '⭐ WIN！ ${multiplier}倍獲得！ ⭐',
        );
        
      case SlotResultType.smallWin:
        final symbols = _generateMatchingSymbols([
          'assets/nao11.jpg',
          'assets/nao12.jpg'
        ]);
        final multiplier = AppConstants.symbolMultipliers[symbols[0]] ?? 5;
        return SlotResult(
          resultType: type,
          symbols: symbols,
          payout: multiplier,
          effectType: EffectType.normal,
          hasPreEffect: false,
          message: '✨ 小当たり！ ${multiplier}倍獲得！ ✨',
        );
        
      case SlotResultType.reach:
        return SlotResult(
          resultType: type,
          symbols: _generateReachSymbols(),
          payout: 0,
          effectType: EffectType.strong,
          hasPreEffect: _shouldHavePreEffect(type),
          message: 'GODリーチ！惜しい！次に期待！',
        );
        
      case SlotResultType.hazure:
        return SlotResult(
          resultType: type,
          symbols: _generateHazureSymbols(),
          payout: 0,
          effectType: EffectType.none,
          hasPreEffect: false,
          message: 'ハズレ... もう一度！',
        );
    }
  }
  
  static List<String> _generateGodSymbols() {
    return [
      AppConstants.godSymbol,
      AppConstants.godSymbol,
      AppConstants.godSymbol,
    ];
  }
  
  static List<String> _generateMatchingSymbols(List<String> candidateSymbols) {
    final symbol = candidateSymbols[_random.nextInt(candidateSymbols.length)];
    return [symbol, symbol, symbol];
  }
  
  static List<String> _generateReachSymbols() {
    final symbols = <String>[];
    final godSymbol = AppConstants.godSymbol;
    
    // 2つのGODシンボルを配置
    symbols.add(godSymbol);
    symbols.add(godSymbol);
    
    // 3つ目は別のシンボル
    final otherSymbols = AppConstants.slotSymbols
        .where((s) => s != godSymbol)
        .toList();
    symbols.add(otherSymbols[_random.nextInt(otherSymbols.length)]);
    
    return symbols;
  }
  
  static List<String> _generateHazureSymbols() {
    final symbols = <String>[];
    final availableSymbols = List<String>.from(AppConstants.slotSymbols);
    
    for (int i = 0; i < 3; i++) {
      symbols.add(availableSymbols[_random.nextInt(availableSymbols.length)]);
    }
    
    // 揃いになってしまった場合は調整
    if (symbols[0] == symbols[1] && symbols[1] == symbols[2]) {
      // 最後のシンボルを変更
      availableSymbols.remove(symbols[2]);
      if (availableSymbols.isNotEmpty) {
        symbols[2] = availableSymbols[_random.nextInt(availableSymbols.length)];
      }
    }
    
    return symbols;
  }
  
  static bool _shouldHavePreEffect(SlotResultType type) {
    switch (type) {
      case SlotResultType.god:
        return _random.nextDouble() < 0.8; // 80%の確率で予告演出
      case SlotResultType.bigWin:
        return _random.nextDouble() < 0.6; // 60%の確率で予告演出
      case SlotResultType.mediumWin:
        return _random.nextDouble() < 0.4; // 40%の確率で予告演出
      case SlotResultType.reach:
        return _random.nextDouble() < 0.7; // 70%の確率で予告演出
      default:
        return false;
    }
  }
  
  // 演出の強さに応じたリール停止タイミング調整
  static List<Duration> getReelStopTimings(EffectType effectType) {
    switch (effectType) {
      case EffectType.god_mode:
        return [
          const Duration(milliseconds: 1500),
          const Duration(milliseconds: 3000),
          const Duration(milliseconds: 5000), // 超ロングフリーズ
        ];
      case EffectType.super_strong:
        return [
          const Duration(milliseconds: 1200),
          const Duration(milliseconds: 2400),
          const Duration(milliseconds: 3800),
        ];
      case EffectType.strong:
        return [
          const Duration(milliseconds: 1000),
          const Duration(milliseconds: 2000),
          const Duration(milliseconds: 3200),
        ];
      case EffectType.normal:
        return [
          const Duration(milliseconds: 800),
          const Duration(milliseconds: 1600),
          const Duration(milliseconds: 2400),
        ];
      case EffectType.none:
        return [
          const Duration(milliseconds: 600),
          const Duration(milliseconds: 1200),
          const Duration(milliseconds: 1800),
        ];
    }
  }
}