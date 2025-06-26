class GameCard {
  final String imagePath;
  bool isFlipped;
  bool isMatched;
  
  GameCard({
    required this.imagePath,
    this.isFlipped = false,
    this.isMatched = false,
  });
}