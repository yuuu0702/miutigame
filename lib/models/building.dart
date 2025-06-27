import 'dart:math' as math;

class Building {
  final String id;
  final String name;
  final String description;
  final double baseCost;
  final double baseProduction;
  final String icon;
  
  const Building({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.baseProduction,
    required this.icon,
  });
  
  double getCost(int count) {
    return baseCost * math.pow(1.15, count);
  }
  
  double getProduction(int count) {
    return baseProduction * count;
  }
}