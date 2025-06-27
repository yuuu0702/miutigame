import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/roguelike_game_state.dart';
import '../models/item.dart';
import '../widgets/slot_reel.dart';

class RoguelikeSlotScreen extends StatefulWidget {
  const RoguelikeSlotScreen({super.key});

  @override
  State<RoguelikeSlotScreen> createState() => _RoguelikeSlotScreenState();
}

class _RoguelikeSlotScreenState extends State<RoguelikeSlotScreen>
    with TickerProviderStateMixin {
  RoguelikeGameState gameState = const RoguelikeGameState();

  late AnimationController _reel1Controller;
  late AnimationController _reel2Controller;
  late AnimationController _reel3Controller;

  final List<String> _symbols = ['⭐', '💎', '🔥', '⚡', '🌟', '💯', '🎯'];
  final Random _random = Random();

  bool _isSpinning = false;
  List<String> _currentSymbols = ['⭐', '⭐', '⭐'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGame();
  }

  void _initializeAnimations() {
    _reel1Controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _reel2Controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _reel3Controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
  }

  void _initializeGame() {
    setState(() {
      gameState = const RoguelikeGameState();
    });
  }

  Future<void> _spin() async {
    if (_isSpinning || gameState.phase != GamePhase.battle) return;

    setState(() {
      _isSpinning = true;
    });

    // 先に結果を決定
    final newSymbols = [
      _getRandomSymbol(),
      _getRandomSymbol(),
      _getRandomSymbol(),
    ];

    // リール回転開始
    _reel1Controller.repeat();
    _reel2Controller.repeat();
    _reel3Controller.repeat();

    // リールを順番に停止
    await Future.delayed(const Duration(milliseconds: 2000));
    _reel1Controller.stop();
    setState(() {
      _currentSymbols[0] = newSymbols[0];
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    _reel2Controller.stop();
    setState(() {
      _currentSymbols[1] = newSymbols[1];
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    _reel3Controller.stop();
    setState(() {
      _currentSymbols[2] = newSymbols[2];
    });

    // 結果判定
    final result = _evaluateResult();

    setState(() {
      gameState = gameState.processSlotResult(result);
      _isSpinning = false;
    });
  }

  String _getRandomSymbol() {
    if (gameState.hasLuckyBoost) {
      // ラッキーブースト時は良い結果が出やすい
      if (_random.nextDouble() < 0.3) {
        return _symbols[_random.nextInt(3)]; // 上位3つのシンボル
      }
    }
    return _symbols[_random.nextInt(_symbols.length)];
  }

  SlotResult _evaluateResult() {
    final sym1 = _currentSymbols[0];
    final sym2 = _currentSymbols[1];
    final sym3 = _currentSymbols[2];

    if (sym1 == sym2 && sym2 == sym3) {
      // 3つ揃い
      if (sym1 == '⭐') {
        return SlotResult.jackpot;
      } else {
        return SlotResult.triple;
      }
    } else if (sym1 == sym2 || sym2 == sym3 || sym1 == sym3) {
      // 2つ揃い
      return SlotResult.double;
    } else if (_currentSymbols.any((s) => ['💎', '🔥', '⚡'].contains(s))) {
      // 特別シンボルが1つでもある
      return SlotResult.single;
    } else {
      // ハズレ
      return SlotResult.none;
    }
  }

  void _startBattle() {
    setState(() {
      gameState = gameState.startBattle();
    });
  }

  void _nextFloor() {
    setState(() {
      gameState = gameState.nextFloor();
    });
  }

  void _enterShop() {
    setState(() {
      gameState = gameState.enterShop();
    });
  }

  void _buyItem(String itemId) {
    final item = ShopItems.getItemById(itemId);
    if (gameState.player.credits >= item.cost) {
      setState(() {
        gameState = gameState.useItem(itemId);
      });
    }
  }

  void _returnToExploration() {
    setState(() {
      gameState = gameState.copyWith(phase: GamePhase.exploration);
    });
  }

  @override
  void dispose() {
    _reel1Controller.dispose();
    _reel2Controller.dispose();
    _reel3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('なお＆ダンジョン'),
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(child: _buildGameContent()),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0f3460),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'HP',
            '${gameState.player.hp}/${gameState.player.maxHp}',
            Colors.red,
          ),
          _buildStatItem('攻撃', '${gameState.player.attack}', Colors.orange),
          _buildStatItem('防御', '${gameState.player.defense}', Colors.blue),
          _buildStatItem('Lv', '${gameState.player.level}', Colors.yellow),
          _buildStatItem('クレジット', '${gameState.player.credits}', Colors.green),
          _buildStatItem('フロア', '${gameState.currentFloor}', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildGameContent() {
    switch (gameState.phase) {
      case GamePhase.exploration:
        return _buildExplorationPhase();
      case GamePhase.battle:
        return _buildBattlePhase();
      case GamePhase.shop:
        return _buildShopPhase();
      case GamePhase.gameOver:
        return _buildGameOverPhase();
    }
  }

  Widget _buildExplorationPhase() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'フロア ${gameState.currentFloor}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (gameState.isBossFloor)
            const Text(
              'ボスフロア！',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startBattle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text('戦闘開始', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _enterShop,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text('ショップ', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildBattlePhase() {
    return Row(
      children: [
        // 左側: 戦闘エリア
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // 敵情報
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      gameState.currentEnemy?.name ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (gameState.currentEnemy?.image != null)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            gameState.currentEnemy!.image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else if (gameState.currentEnemy?.emoji != null)
                      Text(
                        gameState.currentEnemy!.emoji!,
                        style: const TextStyle(fontSize: 40),
                      ),
                    Text(
                      'HP: ${gameState.currentEnemy?.hp}/${gameState.currentEnemy?.maxHp}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // スロットマシン
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SlotReel(
                          controller: _reel1Controller,
                          symbol: _currentSymbols[0],
                          symbols: _symbols,
                        ),
                        const SizedBox(width: 20),
                        SlotReel(
                          controller: _reel2Controller,
                          symbol: _currentSymbols[1],
                          symbols: _symbols,
                        ),
                        const SizedBox(width: 20),
                        SlotReel(
                          controller: _reel3Controller,
                          symbol: _currentSymbols[2],
                          symbols: _symbols,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isSpinning ? null : _spin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 20,
                        ),
                      ),
                      child: Text(
                        _isSpinning ? '回転中...' : 'スピン',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // バトルログ
              Container(
                height: 100,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    gameState.battleLog,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),

              // 戦闘終了後のボタン
              if (gameState.canProceed)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _nextFloor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('次のフロアへ', style: TextStyle(fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),

        // 右側: ルール説明
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0f3460),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ゲームルール',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRuleItem(
                            '⭐⭐⭐',
                            'ジャックポット\n敵を一撃で倒す！\n報酬2倍',
                            Colors.yellow,
                          ),
                          const SizedBox(height: 12),
                          _buildRuleItem(
                            '💎💎💎',
                            '3つ揃い\n攻撃力×3ダメージ',
                            Colors.cyan,
                          ),
                          const SizedBox(height: 12),
                          _buildRuleItem(
                            '🔥🔥-',
                            '2つ揃い\n攻撃力×2ダメージ',
                            Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _buildRuleItem('💎--', '特別シンボル\n通常攻撃', Colors.blue),
                          const SizedBox(height: 12),
                          _buildRuleItem('🌟--', 'ハズレ\n敵の攻撃を受ける', Colors.red),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 8),
                          const Text(
                            '特別効果',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (gameState.hasLuckyBoost)
                            const Text(
                              '🍀 ラッキー効果中\n良い結果が出やすい',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          if (gameState.hasProtection)
                            const Text(
                              '🛡️ 保護効果中\n次回ダメージ無効',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          if (!gameState.hasLuckyBoost &&
                              !gameState.hasProtection)
                            const Text(
                              'ショップでアイテムを\n購入して有利に戦おう！',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String pattern, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            pattern,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopPhase() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF16213e),
          child: const Text(
            'ショップ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ShopItems.items.length,
            itemBuilder: (context, index) {
              final item = ShopItems.items[index];
              final canAfford = gameState.player.credits >= item.cost;

              return Card(
                color: const Color(0xFF16213e),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    item.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: ElevatedButton(
                    onPressed: canAfford ? () => _buyItem(item.id) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAfford ? Colors.green : Colors.grey,
                    ),
                    child: Text('${item.cost}C'),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _returnToExploration,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text('探索に戻る', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverPhase() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ゲームオーバー',
            style: TextStyle(
              color: Colors.red,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'フロア ${gameState.currentFloor} で力尽きました',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _initializeGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text('もう一度プレイ', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
