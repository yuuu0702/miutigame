class ClickerGameState {
  final double naoCount;
  final double naoPerSecond;
  final double naoPerClick;
  final int totalClicks;
  final Map<String, int> upgrades;
  final Map<String, int> buildings;
  final double allTimeNao;
  
  const ClickerGameState({
    this.naoCount = 0.0,
    this.naoPerSecond = 0.0,
    this.naoPerClick = 1.0,
    this.totalClicks = 0,
    this.upgrades = const {},
    this.buildings = const {},
    this.allTimeNao = 0.0,
  });
  
  ClickerGameState copyWith({
    double? naoCount,
    double? naoPerSecond,
    double? naoPerClick,
    int? totalClicks,
    Map<String, int>? upgrades,
    Map<String, int>? buildings,
    double? allTimeNao,
  }) {
    return ClickerGameState(
      naoCount: naoCount ?? this.naoCount,
      naoPerSecond: naoPerSecond ?? this.naoPerSecond,
      naoPerClick: naoPerClick ?? this.naoPerClick,
      totalClicks: totalClicks ?? this.totalClicks,
      upgrades: upgrades ?? this.upgrades,
      buildings: buildings ?? this.buildings,
      allTimeNao: allTimeNao ?? this.allTimeNao,
    );
  }
}