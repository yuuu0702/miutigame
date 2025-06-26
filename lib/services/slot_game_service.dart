import 'dart:math';
import '../constants/app_constants.dart';

class SlotGameService {
  static int getMultiplier(String symbol) {
    return AppConstants.symbolMultipliers[symbol] ?? 1;
  }
  
  static bool isGodMatch(List<String> symbols) {
    return symbols[0] == AppConstants.godSymbol && 
           symbols[1] == AppConstants.godSymbol && 
           symbols[2] == AppConstants.godSymbol;
  }
  
  static bool isRegularMatch(List<String> symbols) {
    return symbols[0] == symbols[1] && symbols[1] == symbols[2];
  }
  
  static bool isGodReach(List<String> symbols) {
    return symbols.where((s) => s == AppConstants.godSymbol).length == 2;
  }
  
  static List<int> generateRandomPositions(List<List<String>> reels) {
    final random = Random();
    return reels.map((reel) => random.nextInt(reel.length)).toList();
  }
  
  static List<String> getSymbolsFromPositions(
    List<List<String>> reels, 
    List<int> positions
  ) {
    return positions.asMap().entries
        .map((entry) => reels[entry.key][entry.value])
        .toList();
  }
}