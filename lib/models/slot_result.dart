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
  super_strong,
  god_mode,
}

class SlotResult {
  final SlotResultType resultType;
  final List<String> symbols;
  final int payout;
  final EffectType effectType;
  final bool hasPreEffect;  // 予告演出の有無
  final String message;
  
  const SlotResult({
    required this.resultType,
    required this.symbols,
    required this.payout,
    required this.effectType,
    this.hasPreEffect = false,
    required this.message,
  });
}