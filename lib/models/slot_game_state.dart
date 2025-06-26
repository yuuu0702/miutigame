class SlotGameState {
  final List<List<String>> reels;
  final List<int> currentPositions;
  final List<bool> isSpinning;
  final bool isGodMode;
  final bool showExplosion;
  final int credits;
  final int bet;
  final String message;
  
  const SlotGameState({
    required this.reels,
    required this.currentPositions,
    required this.isSpinning,
    this.isGodMode = false,
    this.showExplosion = false,
    this.credits = 1000,
    this.bet = 10,
    this.message = 'レバーを引いてゲーム開始！',
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
    );
  }
}