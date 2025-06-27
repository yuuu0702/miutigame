import 'package:flutter/material.dart';
import '../models/building.dart';
import '../services/clicker_game_service.dart';

class BuildingShopItem extends StatelessWidget {
  final Building building;
  final int count;
  final bool canAfford;
  final VoidCallback onBuy;

  const BuildingShopItem({
    super.key,
    required this.building,
    required this.count,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final cost = building.getCost(count);
    final production = building.baseProduction;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: canAfford ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: canAfford ? const Color(0xFF228B22) : Colors.grey,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: canAfford ? onBuy : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // アイコンと数量
                Column(
                  children: [
                    Text(
                      building.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    if (count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF228B22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // 建物情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.black : Colors.grey,
                        ),
                      ),
                      Text(
                        building.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: canAfford ? Colors.grey.shade600 : Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${ClickerGameService.formatNumber(cost)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: canAfford ? const Color(0xFF228B22) : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${ClickerGameService.formatNumber(production)}/秒',
                            style: TextStyle(
                              fontSize: 10,
                              color: canAfford ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}