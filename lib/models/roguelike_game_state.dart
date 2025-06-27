import 'player.dart';
import 'enemy.dart';
import 'item.dart';

enum GamePhase {
  exploration,
  battle,
  shop,
  gameOver,
}

enum SlotResult {
  none,
  single,
  double,
  triple,
  jackpot,
}

class RoguelikeGameState {
  final Player player;
  final Enemy? currentEnemy;
  final int currentFloor;
  final GamePhase phase;
  final List<String> inventory;
  final bool hasLuckyBoost;
  final bool hasProtection;
  final SlotResult lastSlotResult;
  final String battleLog;
  
  const RoguelikeGameState({
    this.player = const Player(),
    this.currentEnemy,
    this.currentFloor = 1,
    this.phase = GamePhase.exploration,
    this.inventory = const [],
    this.hasLuckyBoost = false,
    this.hasProtection = false,
    this.lastSlotResult = SlotResult.none,
    this.battleLog = '',
  });
  
  RoguelikeGameState copyWith({
    Player? player,
    Enemy? currentEnemy,
    int? currentFloor,
    GamePhase? phase,
    List<String>? inventory,
    bool? hasLuckyBoost,
    bool? hasProtection,
    SlotResult? lastSlotResult,
    String? battleLog,
    bool clearEnemy = false,
  }) {
    return RoguelikeGameState(
      player: player ?? this.player,
      currentEnemy: clearEnemy ? null : (currentEnemy ?? this.currentEnemy),
      currentFloor: currentFloor ?? this.currentFloor,
      phase: phase ?? this.phase,
      inventory: inventory ?? this.inventory,
      hasLuckyBoost: hasLuckyBoost ?? this.hasLuckyBoost,
      hasProtection: hasProtection ?? this.hasProtection,
      lastSlotResult: lastSlotResult ?? this.lastSlotResult,
      battleLog: battleLog ?? this.battleLog,
    );
  }
  
  bool get isBossFloor => currentFloor % 10 == 0;
  bool get canProceed => currentEnemy == null || !currentEnemy!.isAlive;
  
  RoguelikeGameState startBattle() {
    final enemy = isBossFloor 
        ? Enemy.generateBoss(currentFloor)
        : Enemy.generateForFloor(currentFloor);
    
    return copyWith(
      currentEnemy: enemy,
      phase: GamePhase.battle,
      battleLog: '${enemy.name}が現れた！',
    );
  }
  
  RoguelikeGameState processSlotResult(SlotResult result) {
    String log = battleLog;
    Player updatedPlayer = player;
    Enemy? updatedEnemy = currentEnemy;
    
    switch (result) {
      case SlotResult.single:
        // プレイヤーが攻撃
        if (updatedEnemy != null) {
          final damage = updatedPlayer.attack;
          updatedEnemy = updatedEnemy.takeDamage(damage);
          log += '\n${updatedPlayer.attack}ダメージを与えた！';
          
          if (!updatedEnemy.isAlive) {
            log += '\n${updatedEnemy.name}を倒した！';
            updatedPlayer = updatedPlayer
                .addExperience(updatedEnemy.expReward)
                .addCredits(updatedEnemy.creditReward);
            
            updatedPlayer = _checkLevelUp(updatedPlayer);
            log += '\n経験値${updatedEnemy.expReward}、クレジット${updatedEnemy.creditReward}を獲得！';
          }
        }
        break;
        
      case SlotResult.double:
        // プレイヤーが2倍ダメージ攻撃
        if (updatedEnemy != null) {
          final damage = updatedPlayer.attack * 2;
          updatedEnemy = updatedEnemy.takeDamage(damage);
          log += '\n会心の一撃！${damage}ダメージを与えた！';
          
          if (!updatedEnemy.isAlive) {
            log += '\n${updatedEnemy.name}を倒した！';
            updatedPlayer = updatedPlayer
                .addExperience(updatedEnemy.expReward)
                .addCredits(updatedEnemy.creditReward);
            
            updatedPlayer = _checkLevelUp(updatedPlayer);
            log += '\n経験値${updatedEnemy.expReward}、クレジット${updatedEnemy.creditReward}を獲得！';
          }
        }
        break;
        
      case SlotResult.triple:
        // プレイヤーが3倍ダメージ攻撃
        if (updatedEnemy != null) {
          final damage = updatedPlayer.attack * 3;
          updatedEnemy = updatedEnemy.takeDamage(damage);
          log += '\n必殺技！${damage}ダメージを与えた！';
          
          if (!updatedEnemy.isAlive) {
            log += '\n${updatedEnemy.name}を倒した！';
            updatedPlayer = updatedPlayer
                .addExperience(updatedEnemy.expReward)
                .addCredits(updatedEnemy.creditReward);
            
            updatedPlayer = _checkLevelUp(updatedPlayer);
            log += '\n経験値${updatedEnemy.expReward}、クレジット${updatedEnemy.creditReward}を獲得！';
          }
        }
        break;
        
      case SlotResult.jackpot:
        // 即死攻撃
        if (updatedEnemy != null) {
          log += '\nジャックポット！${updatedEnemy.name}を一撃で倒した！';
          updatedPlayer = updatedPlayer
              .addExperience(updatedEnemy.expReward * 2)
              .addCredits(updatedEnemy.creditReward * 2);
          
          updatedPlayer = _checkLevelUp(updatedPlayer);
          log += '\n経験値${updatedEnemy.expReward * 2}、クレジット${updatedEnemy.creditReward * 2}を獲得！';
          updatedEnemy = updatedEnemy.copyWith(hp: 0);
        }
        break;
        
      case SlotResult.none:
        // 敵が攻撃
        if (updatedEnemy != null && updatedEnemy.isAlive) {
          if (hasProtection) {
            log += '\n保護のお守りでダメージを無効化した！';
            return copyWith(
              hasProtection: false,
              battleLog: log,
              lastSlotResult: result,
            );
          }
          
          final damage = updatedEnemy.attack;
          updatedPlayer = updatedPlayer.takeDamage(damage);
          log += '\n${updatedEnemy.name}の攻撃！${damage}ダメージを受けた！';
        }
        break;
    }
    
    // 戦闘終了チェック
    GamePhase newPhase = phase;
    if (updatedEnemy != null && !updatedEnemy.isAlive) {
      newPhase = GamePhase.exploration;
      updatedEnemy = null;
    } else if (!updatedPlayer.isAlive) {
      newPhase = GamePhase.gameOver;
    }
    
    return copyWith(
      player: updatedPlayer,
      currentEnemy: updatedEnemy,
      phase: newPhase,
      battleLog: log,
      lastSlotResult: result,
      hasLuckyBoost: result != SlotResult.none ? false : hasLuckyBoost,
      clearEnemy: updatedEnemy == null,
    );
  }
  
  Player _checkLevelUp(Player player) {
    Player currentPlayer = player;
    while (currentPlayer.experience >= currentPlayer.nextLevelExp) {
      currentPlayer = currentPlayer.levelUp();
    }
    return currentPlayer;
  }
  
  RoguelikeGameState nextFloor() {
    return copyWith(
      currentFloor: currentFloor + 1,
      phase: GamePhase.exploration,
      battleLog: 'フロア${currentFloor + 1}に進んだ！',
    );
  }
  
  RoguelikeGameState enterShop() {
    return copyWith(
      phase: GamePhase.shop,
      battleLog: 'ショップに立ち寄った。',
    );
  }
  
  RoguelikeGameState useItem(String itemId) {
    final item = ShopItems.getItemById(itemId);
    Player updatedPlayer = player;
    String log = battleLog;
    
    switch (item.type) {
      case ItemType.attackBoost:
        updatedPlayer = updatedPlayer.copyWith(attack: player.attack + item.value);
        log += '\n攻撃力が${item.value}上がった！';
        break;
      case ItemType.defenseBoost:
        updatedPlayer = updatedPlayer.copyWith(defense: player.defense + item.value);
        log += '\n防御力が${item.value}上がった！';
        break;
      case ItemType.healing:
        updatedPlayer = updatedPlayer.heal(item.value);
        log += '\nHPが${item.value}回復した！';
        break;
      case ItemType.lucky:
        log += '\n次回スロットで良い結果が出やすくなった！';
        return copyWith(
          player: updatedPlayer.spendCredits(item.cost),
          hasLuckyBoost: true,
          battleLog: log,
        );
      case ItemType.protection:
        log += '\n保護のお守りを装備した！';
        return copyWith(
          player: updatedPlayer.spendCredits(item.cost),
          hasProtection: true,
          battleLog: log,
        );
    }
    
    return copyWith(
      player: updatedPlayer.spendCredits(item.cost),
      battleLog: log,
    );
  }
}