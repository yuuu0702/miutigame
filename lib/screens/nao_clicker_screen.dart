import 'package:flutter/material.dart';
import 'dart:async';
import '../models/clicker_game_state.dart';
import '../services/clicker_game_service.dart';
import '../constants/clicker_constants.dart';
import '../widgets/building_shop_item.dart';

class NaoClickerScreen extends StatefulWidget {
  const NaoClickerScreen({super.key});

  @override
  State<NaoClickerScreen> createState() => _NaoClickerScreenState();
}

class _NaoClickerScreenState extends State<NaoClickerScreen>
    with TickerProviderStateMixin {
  ClickerGameState gameState = const ClickerGameState();
  late AnimationController _clickAnimationController;
  late Animation<double> _clickAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    ClickerGameService.startGameTimer(_updateGameState, () => gameState);
  }

  void _initializeAnimation() {
    _clickAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _clickAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _clickAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _updateGameState(ClickerGameState newState) {
    if (mounted) {
      setState(() {
        gameState = newState;
      });
    }
  }

  void _handleNaoClick() {
    setState(() {
      gameState = ClickerGameService.handleClick(gameState);
    });
    _clickAnimationController.forward().then((_) {
      _clickAnimationController.reverse();
    });
  }

  void _buyBuilding(String buildingId) {
    setState(() {
      gameState = ClickerGameService.buyBuilding(gameState, buildingId);
    });
  }

  @override
  void dispose() {
    ClickerGameService.stopGameTimer();
    _clickAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E8B57),
      appBar: AppBar(
        title: const Text('ナオクリッカー'),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Row(
        children: [
          // 左側: クリックエリア
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ナオカウンター
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${ClickerGameService.formatNumber(gameState.naoCount)} ナオ',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF228B22),
                          ),
                        ),
                        if (gameState.naoPerSecond > 0)
                          Text(
                            '毎秒 ${ClickerGameService.formatNumber(gameState.naoPerSecond)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // ナオクリックボタン
                  AnimatedBuilder(
                    animation: _clickAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _clickAnimation.value,
                        child: GestureDetector(
                          onTap: _handleNaoClick,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [
                                  Color(0xFFFFD700),
                                  Color(0xFFB8860B),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/nao1.png',
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'クリック回数: ${gameState.totalClicks}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 右側: ショップ
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF228B22),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.store, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'ショップ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: ClickerConstants.buildings.length,
                      itemBuilder: (context, index) {
                        final building = ClickerConstants.buildings[index];
                        final count = gameState.buildings[building.id] ?? 0;
                        final canAfford = ClickerGameService.canAffordBuilding(
                          gameState,
                          building.id,
                        );
                        
                        return BuildingShopItem(
                          building: building,
                          count: count,
                          canAfford: canAfford,
                          onBuy: () => _buyBuilding(building.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}