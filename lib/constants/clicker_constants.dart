import '../models/building.dart';

class ClickerConstants {
  static const List<Building> buildings = [
    Building(
      id: 'cursor',
      name: 'ナオポインター',
      description: 'ナオが勝手にクリックしてくれます。怠惰の始まり。',
      baseCost: 15.0,
      baseProduction: 0.1,
      icon: '👆',
    ),
    Building(
      id: 'nao_farm',
      name: 'ナオ畑',
      description: 'ナオを種から育てます。水やりは涙です。',
      baseCost: 100.0,
      baseProduction: 1.0,
      icon: '🌾',
    ),
    Building(
      id: 'nao_mine',
      name: 'ナオ鉱山',
      description: '地下に埋まってるナオを掘り起こします。違法です。',
      baseCost: 1100.0,
      baseProduction: 8.0,
      icon: '⛏️',
    ),
    Building(
      id: 'nao_factory',
      name: 'ナオ製造工場',
      description: 'ナオをベルトコンベアで量産。品質は保証しません。',
      baseCost: 12000.0,
      baseProduction: 47.0,
      icon: '🏭',
    ),
    Building(
      id: 'nao_bank',
      name: 'ナオ銀行',
      description: 'ナオがナオを生む魔法の場所。利子は複利です。',
      baseCost: 130000.0,
      baseProduction: 260.0,
      icon: '🏦',
    ),
    Building(
      id: 'nao_temple',
      name: 'ナオ神社',
      description: 'ナオ神に祈ってご利益をもらいます。お賽銭はナオで。',
      baseCost: 1400000.0,
      baseProduction: 1400.0,
      icon: '⛩️',
    ),
    Building(
      id: 'nao_tower',
      name: 'ナオスカイツリー',
      description: '天空のナオを電波で受信します。地デジ対応。',
      baseCost: 20000000.0,
      baseProduction: 7800.0,
      icon: '🗼',
    ),
    Building(
      id: 'nao_spaceship',
      name: 'ナオ宇宙ステーション',
      description: '無重力でナオが浮遊生産されます。NASA公認。',
      baseCost: 330000000.0,
      baseProduction: 44000.0,
      icon: '🚀',
    ),
    Building(
      id: 'nao_portal',
      name: 'ナオ次元ゲート',
      description: 'パラレルワールドのナオを強制召喚。倫理的に問題あり。',
      baseCost: 5100000000.0,
      baseProduction: 260000.0,
      icon: '🌀',
    ),
    Building(
      id: 'nao_machine',
      name: 'ナオタイムマシン',
      description: '過去に戻ってナオの歴史を改変。因果律崩壊注意。',
      baseCost: 75000000000.0,
      baseProduction: 1600000.0,
      icon: '⏰',
    ),
  ];
  
  static Building getBuildingById(String id) {
    return buildings.firstWhere((building) => building.id == id);
  }
}