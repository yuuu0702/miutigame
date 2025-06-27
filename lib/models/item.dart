enum ItemType {
  attackBoost,
  defenseBoost,
  healing,
  lucky,
  protection,
}

class Item {
  final String id;
  final String name;
  final String description;
  final int cost;
  final ItemType type;
  final int value;
  final String emoji;
  
  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.type,
    required this.value,
    required this.emoji,
  });
}

class ShopItems {
  static const List<Item> items = [
    Item(
      id: 'attack_potion',
      name: '攻撃力強化薬',
      description: '攻撃力を永続的に+5します',
      cost: 30,
      type: ItemType.attackBoost,
      value: 5,
      emoji: '⚔️',
    ),
    Item(
      id: 'defense_potion',
      name: '防御力強化薬',
      description: '防御力を永続的に+3します',
      cost: 25,
      type: ItemType.defenseBoost,
      value: 3,
      emoji: '🛡️',
    ),
    Item(
      id: 'healing_potion',
      name: '回復薬',
      description: 'HPを50回復します',
      cost: 20,
      type: ItemType.healing,
      value: 50,
      emoji: '❤️',
    ),
    Item(
      id: 'lucky_coin',
      name: 'ラッキーコイン',
      description: '次回スロットで良い結果が出やすくなります',
      cost: 50,
      type: ItemType.lucky,
      value: 1,
      emoji: '🍀',
    ),
    Item(
      id: 'protection_charm',
      name: '保護のお守り',
      description: '1回だけダメージを完全に無効化します',
      cost: 40,
      type: ItemType.protection,
      value: 1,
      emoji: '🛡️',
    ),
  ];
  
  static Item getItemById(String id) {
    return items.firstWhere((item) => item.id == id);
  }
}