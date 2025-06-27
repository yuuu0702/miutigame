import 'dart:async';
import '../models/clicker_game_state.dart';
import '../models/building.dart';
import '../constants/clicker_constants.dart';

class ClickerGameService {
  static Timer? _gameTimer;
  
  static void startGameTimer(Function(ClickerGameState) onUpdate, ClickerGameState Function() getCurrentState) {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final currentState = getCurrentState();
      if (currentState.naoPerSecond > 0) {
        final newNaoCount = currentState.naoCount + (currentState.naoPerSecond * 0.1);
        final newState = currentState.copyWith(
          naoCount: newNaoCount,
          allTimeNao: currentState.allTimeNao + (currentState.naoPerSecond * 0.1),
        );
        onUpdate(newState);
      }
    });
  }
  
  static void stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }
  
  static ClickerGameState handleClick(ClickerGameState gameState) {
    return gameState.copyWith(
      naoCount: gameState.naoCount + gameState.naoPerClick,
      totalClicks: gameState.totalClicks + 1,
      allTimeNao: gameState.allTimeNao + gameState.naoPerClick,
    );
  }
  
  static ClickerGameState buyBuilding(ClickerGameState gameState, String buildingId) {
    final building = ClickerConstants.getBuildingById(buildingId);
    final currentCount = gameState.buildings[buildingId] ?? 0;
    final cost = building.getCost(currentCount);
    
    if (gameState.naoCount >= cost) {
      final newBuildings = Map<String, int>.from(gameState.buildings);
      newBuildings[buildingId] = currentCount + 1;
      
      final newNaoPerSecond = _calculateNaoPerSecond(newBuildings);
      
      return gameState.copyWith(
        naoCount: gameState.naoCount - cost,
        buildings: newBuildings,
        naoPerSecond: newNaoPerSecond,
      );
    }
    
    return gameState;
  }
  
  static double _calculateNaoPerSecond(Map<String, int> buildings) {
    double total = 0.0;
    
    for (final building in ClickerConstants.buildings) {
      final count = buildings[building.id] ?? 0;
      total += building.getProduction(count);
    }
    
    return total;
  }
  
  static bool canAffordBuilding(ClickerGameState gameState, String buildingId) {
    final building = ClickerConstants.getBuildingById(buildingId);
    final currentCount = gameState.buildings[buildingId] ?? 0;
    final cost = building.getCost(currentCount);
    return gameState.naoCount >= cost;
  }
  
  static double getBuildingCost(String buildingId, int currentCount) {
    final building = ClickerConstants.getBuildingById(buildingId);
    return building.getCost(currentCount);
  }
  
  static String formatNumber(double number) {
    if (number < 1000) {
      return number.toInt().toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number < 1000000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else {
      return '${(number / 1000000000000).toStringAsFixed(1)}T';
    }
  }
}