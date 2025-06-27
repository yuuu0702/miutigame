class Player {
  final int hp;
  final int maxHp;
  final int attack;
  final int defense;
  final int level;
  final int credits;
  final int experience;
  
  const Player({
    this.hp = 100,
    this.maxHp = 100,
    this.attack = 10,
    this.defense = 5,
    this.level = 1,
    this.credits = 100,
    this.experience = 0,
  });
  
  Player copyWith({
    int? hp,
    int? maxHp,
    int? attack,
    int? defense,
    int? level,
    int? credits,
    int? experience,
  }) {
    return Player(
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      level: level ?? this.level,
      credits: credits ?? this.credits,
      experience: experience ?? this.experience,
    );
  }
  
  bool get isAlive => hp > 0;
  
  int get nextLevelExp => level * 100;
  
  Player levelUp() {
    if (experience >= nextLevelExp) {
      return copyWith(
        level: level + 1,
        experience: experience - nextLevelExp,
        maxHp: maxHp + 20,
        hp: hp + 20,
        attack: attack + 3,
        defense: defense + 2,
      );
    }
    return this;
  }
  
  Player takeDamage(int damage) {
    final actualDamage = (damage - defense).clamp(1, damage);
    return copyWith(hp: (hp - actualDamage).clamp(0, maxHp));
  }
  
  Player heal(int amount) {
    return copyWith(hp: (hp + amount).clamp(0, maxHp));
  }
  
  Player addCredits(int amount) {
    return copyWith(credits: credits + amount);
  }
  
  Player spendCredits(int amount) {
    return copyWith(credits: (credits - amount).clamp(0, credits));
  }
  
  Player addExperience(int exp) {
    return copyWith(experience: experience + exp);
  }
}