class Enemy {
  final String name;
  final int hp;
  final int maxHp;
  final int attack;
  final int defense;
  final int expReward;
  final int creditReward;
  final String? emoji;
  final String? image;

  const Enemy({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.attack,
    required this.defense,
    required this.expReward,
    required this.creditReward,
    this.emoji,
    this.image,
  });

  Enemy copyWith({
    String? name,
    int? hp,
    int? maxHp,
    int? attack,
    int? defense,
    int? expReward,
    int? creditReward,
    String? emoji,
    String? image,
  }) {
    return Enemy(
      name: name ?? this.name,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      expReward: expReward ?? this.expReward,
      creditReward: creditReward ?? this.creditReward,
      emoji: emoji ?? this.emoji,
      image: image ?? this.image,
    );
  }

  bool get isAlive => hp > 0;

  Enemy takeDamage(int damage) {
    final actualDamage = (damage - defense).clamp(1, damage);
    return copyWith(hp: (hp - actualDamage).clamp(0, maxHp));
  }

  static Enemy generateForFloor(int floor) {
    final baseHp = 50 + (floor * 15);
    final baseAttack = 8 + (floor * 3);
    final baseDefense = 2 + (floor * 2);

    final enemies = [
      {
        'name': 'なおき',
        'image': 'assets/nao1.png',
        'hpMod': 0.8,
        'attackMod': 0.7,
        'defenseMod': 0.5,
      },
      {
        'name': 'なお',
        'image': 'assets/nao2.png',
        'hpMod': 1.0,
        'attackMod': 1.0,
        'defenseMod': 0.8,
      },
      {
        'name': '大倉',
        'image': 'assets/nao3.png',
        'hpMod': 1.3,
        'attackMod': 1.2,
        'defenseMod': 1.1,
      },
      {
        'name': '雄大',
        'image': 'assets/nao4.png',
        'hpMod': 2.0,
        'attackMod': 1.8,
        'defenseMod': 1.5,
      },
    ];

    final enemyType = enemies[floor % enemies.length];
    final hp = (baseHp * (enemyType['hpMod'] as double)).round();
    final attack = (baseAttack * (enemyType['attackMod'] as double)).round();
    final defense = (baseDefense * (enemyType['defenseMod'] as double)).round();

    return Enemy(
      name: enemyType['name']! as String,
      hp: hp,
      maxHp: hp,
      attack: attack,
      defense: defense,
      expReward: floor * 20 + 30,
      creditReward: floor * 5 + 15,
      image: enemyType['image']! as String,
    );
  }

  static Enemy generateBoss(int floor) {
    final bossFloor = ((floor - 1) ~/ 10 + 1) * 10;
    final baseHp = 200 + (bossFloor * 50);
    final baseAttack = 25 + (bossFloor * 8);
    final baseDefense = 10 + (bossFloor * 5);

    return Enemy(
      name: 'ボス雄大',
      hp: baseHp,
      maxHp: baseHp,
      attack: baseAttack,
      defense: baseDefense,
      expReward: bossFloor * 50 + 100,
      creditReward: bossFloor * 20 + 50,
      image: 'assets/nao4.png',
    );
  }
}
