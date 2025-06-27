import 'dart:math';
import '../models/slot_result.dart';
import '../constants/app_constants.dart';
import '../widgets/notice_effect.dart';

class InternalLotteryService {
  static final Random _random = Random();

  SlotResult performLottery() {
    return performInternalLottery();
  }

  // パチスロ風の内部抽選確率（分母65536）
  static const Map<SlotResultType, int> _probabilities = {
    SlotResultType.god: 256, // 1/256 (約0.39%)
    SlotResultType.bigWin: 1024, // 1/64 (約1.56%)
    SlotResultType.mediumWin: 4096, // 1/16 (約6.25%)
    SlotResultType.smallWin: 8192, // 1/8 (約12.5%)
    SlotResultType.reach: 6554, // 約10%
    SlotResultType.hazure: 45414, // 残り（約69.3%）
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
          effectType: EffectType.godMode,
          hasPreEffect: _shouldHavePreEffect(type),
          message: '🎉 GOD降臨！！！ ${AppConstants.godMultiplier}倍獲得！！！ 🎉',
          multiplier: AppConstants.godMultiplier.toDouble(),
          cutinImagePath: _getCutinImageForType(type),
          noticeType: _getNoticeType(type),
          hasLightning: true,
          hasAura: true,
          hasReelGlow: true,
          glowingReels: [0, 1, 2],
        );

      case SlotResultType.bigWin:
        final symbols = _generateMatchingSymbols([
          'assets/nao1.png',
          'assets/nao2.png',
        ]);
        final multiplier = AppConstants.symbolMultipliers[symbols[0]] ?? 50;
        return SlotResult(
          resultType: type,
          symbols: symbols,
          payout: multiplier,
          effectType: EffectType.superStrong,
          hasPreEffect: _shouldHavePreEffect(type),
          message: '🔥 BIG WIN！！ $multiplier倍獲得！ 🔥',
          multiplier: multiplier.toDouble(),
          symbolIndex: AppConstants.slotSymbols.indexOf(symbols[0]),
          cutinImagePath: _getCutinImageForType(type),
          noticeType: _getNoticeType(type),
          hasLightning: _random.nextDouble() < 0.7,
          hasAura: true,
          hasReelGlow: true,
          glowingReels: [0, 1, 2],
        );

      case SlotResultType.mediumWin:
        final symbols = _generateMatchingSymbols([
          'assets/nao3.png',
          'assets/nao4.png',
        ]);
        final multiplier = AppConstants.symbolMultipliers[symbols[0]] ?? 20;
        return SlotResult(
          resultType: type,
          symbols: symbols,
          payout: multiplier,
          effectType: EffectType.strong,
          hasPreEffect: _shouldHavePreEffect(type),
          message: '⭐ WIN！ $multiplier倍獲得！ ⭐',
          multiplier: multiplier.toDouble(),
          symbolIndex: AppConstants.slotSymbols.indexOf(symbols[0]),
          cutinImagePath: _getCutinImageForType(type),
          noticeType: _getNoticeType(type),
          hasLightning: _random.nextDouble() < 0.4,
          hasAura: _random.nextDouble() < 0.6,
          hasReelGlow: _random.nextDouble() < 0.8,
          glowingReels: [0, 1, 2],
        );

      case SlotResultType.smallWin:
        final symbols = _generateMatchingSymbols([
          'assets/nao5.png',
          'assets/naoki.png',
        ]);
        final multiplier = AppConstants.symbolMultipliers[symbols[0]] ?? 5;
        return SlotResult(
          resultType: type,
          symbols: symbols,
          payout: multiplier,
          effectType: EffectType.normal,
          hasPreEffect: false,
          message: '✨ 小当たり！ $multiplier倍獲得！ ✨',
          multiplier: multiplier.toDouble(),
          symbolIndex: AppConstants.slotSymbols.indexOf(symbols[0]),
          cutinImagePath: _getCutinImageForType(type),
          noticeType: _getNoticeType(type),
          hasReelGlow: _random.nextDouble() < 0.5,
          glowingReels: [1], // 真ん中のリールのみ
        );

      case SlotResultType.reach:
        final symbols = _generateReachSymbols();
        return SlotResult(
          resultType: type,
          symbols: symbols,
          payout: 0,
          effectType: EffectType.strong,
          hasPreEffect: _shouldHavePreEffect(type),
          message: '',
          symbolIndex: AppConstants.slotSymbols.indexOf(symbols[0]),
          cutinImagePath: _getCutinImageForType(type),
          noticeType: _getNoticeType(type),
          hasLightning: _random.nextDouble() < 0.5,
          hasReelGlow: true,
          glowingReels: [0, 1], // 最初の2つのリールが光る
        );

      case SlotResultType.hazure:
        return SlotResult(
          resultType: type,
          symbols: _generateHazureSymbols(),
          payout: 0,
          effectType: EffectType.none,
          hasPreEffect: false,
          message: '',
          noticeType: _random.nextDouble() < 0.1 ? NoticeType.weak : NoticeType.none, // 10%で弱予告
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

  // 当たる確率によってカットイン画像を選択
  static String? _getCutinImageForType(SlotResultType type) {
    switch (type) {
      case SlotResultType.god:
        return 'assets/saginaoki.jpg'; // 最高演出
      case SlotResultType.bigWin:
        return AppConstants.cutinImages[2]; // 3番目に熱い
      case SlotResultType.mediumWin:
        return AppConstants.cutinImages[1]; // 2番目に熱い
      case SlotResultType.smallWin:
        return AppConstants.cutinImages[0]; // 通常演出
      case SlotResultType.reach:
        return AppConstants.cutinImages[1]; // リーチは中程度の熱さ
      case SlotResultType.hazure:
        return null; // ハズレはカットインなし
    }
  }

  // 予告タイプを決定
  static NoticeType _getNoticeType(SlotResultType type) {
    switch (type) {
      case SlotResultType.god:
        // GOD時は80%で激アツ予告
        final rand = _random.nextDouble();
        if (rand < 0.8) return NoticeType.super_;
        if (rand < 0.95) return NoticeType.strong;
        return NoticeType.medium;
        
      case SlotResultType.bigWin:
        // 大当たり時は60%で強予告以上
        final rand = _random.nextDouble();
        if (rand < 0.1) return NoticeType.super_;
        if (rand < 0.6) return NoticeType.strong;
        if (rand < 0.9) return NoticeType.medium;
        return NoticeType.weak;
        
      case SlotResultType.mediumWin:
        // 中当たり時は40%で中予告以上
        final rand = _random.nextDouble();
        if (rand < 0.05) return NoticeType.super_;
        if (rand < 0.2) return NoticeType.strong;
        if (rand < 0.4) return NoticeType.medium;
        if (rand < 0.7) return NoticeType.weak;
        return NoticeType.none;
        
      case SlotResultType.smallWin:
        // 小当たり時は20%で予告
        final rand = _random.nextDouble();
        if (rand < 0.01) return NoticeType.strong;
        if (rand < 0.05) return NoticeType.medium;
        if (rand < 0.2) return NoticeType.weak;
        return NoticeType.none;
        
      case SlotResultType.reach:
        // リーチ時は70%で予告
        final rand = _random.nextDouble();
        if (rand < 0.2) return NoticeType.super_;
        if (rand < 0.5) return NoticeType.strong;
        if (rand < 0.7) return NoticeType.medium;
        return NoticeType.weak;
        
      case SlotResultType.hazure:
        // ハズレ時は5%で弱予告（ガセ予告）
        return _random.nextDouble() < 0.05 ? NoticeType.weak : NoticeType.none;
    }
  }

  // 演出の強さに応じたリール停止タイミング調整
  static List<Duration> getReelStopTimings(EffectType effectType) {
    switch (effectType) {
      case EffectType.godMode:
        return [
          const Duration(milliseconds: 1500),
          const Duration(milliseconds: 3000),
          const Duration(milliseconds: 5000), // 超ロングフリーズ
        ];
      case EffectType.superStrong:
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
