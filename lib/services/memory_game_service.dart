import 'dart:math';
import '../models/game_card.dart';
import '../constants/app_constants.dart';

class MemoryGameService {
  static List<GameCard> generateCards() {
    final cards = <GameCard>[];
    final selectedImages = AppConstants.imageAssets.take(8).toList();
    
    for (String asset in selectedImages) {
      cards.add(GameCard(imagePath: asset));
      cards.add(GameCard(imagePath: asset));
    }
    
    cards.shuffle(Random());
    return cards;
  }
  
  static bool areCardsMatching(GameCard card1, GameCard card2) {
    return card1.imagePath == card2.imagePath;
  }
  
  static String formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}