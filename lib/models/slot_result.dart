enum SlotResultType {
  god,        // GOD揃い
  bigWin,     // 大当たり
  mediumWin,  // 中当たり
  smallWin,   // 小当たり
  reach,      // リーチ
  hazure,     // ハズレ
}

enum EffectType {
  none,
  normal,
  strong,
  superStrong,
  godMode,
}

class SlotResult {
  final SlotResultType resultType;
  final List<String> symbols;
  final int payout;
  final EffectType effectType;
  final bool hasPreEffect;
  final String message;
  final int? symbolIndex;
  final double multiplier;
  
  const SlotResult({
    required this.resultType,
    required this.symbols,
    required this.payout,
    required this.effectType,
    this.hasPreEffect = false,
    required this.message,
    this.symbolIndex,
    this.multiplier = 1.0,
  });

  bool get isWin => resultType != SlotResultType.hazure && resultType != SlotResultType.reach;
  
  bool get shouldShowPreEffect => hasPreEffect || effectType == EffectType.superStrong || effectType == EffectType.godMode;
  
  bool get shouldShowFreeze => effectType == EffectType.godMode || (effectType == EffectType.superStrong && isWin);
  
  bool get shouldShowReach => resultType == SlotResultType.reach;
}