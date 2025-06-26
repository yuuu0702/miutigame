import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ミウチゲーム',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ミウチゲーム',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 4,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              _buildGameModeButton(
                context,
                '神経衰弱',
                Icons.psychology,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MemoryGameScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _buildGameModeButton(
                context,
                'GODスロット',
                Icons.casino,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SlotGameScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 250,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: Colors.white,
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameCard {
  final String imagePath;
  bool isFlipped;
  bool isMatched;
  
  GameCard({
    required this.imagePath,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class SlotGameScreen extends StatefulWidget {
  const SlotGameScreen({super.key});

  @override
  State<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends State<SlotGameScreen>
    with TickerProviderStateMixin {
  List<List<String>> reels = [
    ['7', 'BAR', 'BELL', 'CHERRY', 'GOD', 'LEMON', 'STAR'],
    ['7', 'BAR', 'BELL', 'CHERRY', 'GOD', 'LEMON', 'STAR'],
    ['7', 'BAR', 'BELL', 'CHERRY', 'GOD', 'LEMON', 'STAR'],
  ];
  
  List<int> currentPositions = [0, 0, 0];
  List<bool> isSpinning = [false, false, false];
  List<AnimationController> reelControllers = [];
  List<Animation<double>> reelAnimations = [];
  
  AnimationController? explosionController;
  AnimationController? godEffectController;
  Animation<double>? explosionAnimation;
  Animation<double>? godEffectAnimation;
  
  bool isGodMode = false;
  bool showExplosion = false;
  int credits = 1000;
  int bet = 10;
  String message = 'レバーを引いてゲーム開始！';
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 1000 + (i * 200)),
        vsync: this,
      );
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
      
      reelControllers.add(controller);
      reelAnimations.add(animation);
    }
    
    explosionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    explosionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: explosionController!,
      curve: Curves.elasticOut,
    ));
    
    godEffectController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    godEffectAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: godEffectController!,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    for (var controller in reelControllers) {
      controller.dispose();
    }
    explosionController?.dispose();
    godEffectController?.dispose();
    super.dispose();
  }
  
  Future<void> _spin() async {
    if (isSpinning.any((spinning) => spinning) || credits < bet) {
      return;
    }
    
    setState(() {
      credits -= bet;
      message = 'スピン中...';
      isSpinning = [true, true, true];
      showExplosion = false;
      isGodMode = false;
    });
    
    for (int i = 0; i < 3; i++) {
      reelControllers[i].reset();
      reelControllers[i].forward();
      
      Future.delayed(Duration(milliseconds: 1000 + (i * 200)), () {
        final random = Random();
        setState(() {
          currentPositions[i] = random.nextInt(reels[i].length);
          isSpinning[i] = false;
        });
        
        if (i == 2) {
          _checkResult();
        }
      });
    }
  }
  
  void _checkResult() {
    final symbols = currentPositions.map((pos) => reels[0][pos]).toList();
    
    if (symbols[0] == 'GOD' && symbols[1] == 'GOD' && symbols[2] == 'GOD') {
      _triggerGodMode();
    } else if (symbols[0] == symbols[1] && symbols[1] == symbols[2]) {
      final multiplier = _getMultiplier(symbols[0]);
      final win = bet * multiplier;
      setState(() {
        credits += win;
        message = '${symbols[0]} 揃い！ $win枚獲得！';
      });
      _triggerWinEffect();
    } else if (symbols.where((s) => s == 'GOD').length == 2) {
      setState(() {
        message = 'GODリーチ！惜しい！';
      });
      _triggerReachEffect();
    } else {
      setState(() {
        message = 'ハズレ... もう一度！';
      });
    }
  }
  
  int _getMultiplier(String symbol) {
    switch (symbol) {
      case '7':
        return 100;
      case 'BAR':
        return 50;
      case 'BELL':
        return 20;
      case 'STAR':
        return 15;
      case 'CHERRY':
        return 10;
      case 'LEMON':
        return 5;
      default:
        return 1;
    }
  }
  
  void _triggerGodMode() {
    setState(() {
      isGodMode = true;
      credits += bet * 777;
      message = '🎉 GOD降臨！！！ 777倍獲得！！！ 🎉';
      showExplosion = true;
    });
    
    explosionController!.forward();
    godEffectController!.repeat();
    
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showExplosion = false;
        isGodMode = false;
      });
      godEffectController!.stop();
      godEffectController!.reset();
    });
  }
  
  void _triggerWinEffect() {
    explosionController!.forward().then((_) {
      explosionController!.reset();
    });
  }
  
  void _triggerReachEffect() {
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          reelControllers[0].forward().then((_) {
            reelControllers[0].reset();
          });
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GODスロット'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF1a1a1a),
              Color(0xFF333333),
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                _buildInfoPanel(),
                Expanded(
                  child: Center(
                    child: _buildSlotMachine(),
                  ),
                ),
                _buildControlPanel(),
              ],
            ),
            if (showExplosion) _buildExplosionEffect(),
            if (isGodMode) _buildGodEffect(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoCard('クレジット', '$credits', Colors.green),
          _buildInfoCard('ベット', '$bet', Colors.blue),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSlotMachine() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) => _buildReel(index)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isGodMode ? const Color(0xFFFFD700) : Colors.white,
                fontSize: isGodMode ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReel(int reelIndex) {
    return AnimatedBuilder(
      animation: reelAnimations[reelIndex],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, isSpinning[reelIndex] ? -reelAnimations[reelIndex].value * 200 : 0),
          child: Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: Center(
              child: Text(
                isSpinning[reelIndex] ? '?' : reels[reelIndex][currentPositions[reelIndex]],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: reels[reelIndex][currentPositions[reelIndex]] == 'GOD' 
                      ? const Color(0xFFFFD700) 
                      : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                'ベット-',
                () {
                  if (bet > 10) {
                    setState(() {
                      bet -= 10;
                    });
                  }
                },
                Colors.red,
              ),
              _buildSpinButton(),
              _buildControlButton(
                'ベット+',
                () {
                  if (bet < 100 && credits >= bet + 10) {
                    setState(() {
                      bet += 10;
                    });
                  }
                },
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpinButton() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Colors.red, Colors.red],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(60),
          onTap: _spin,
          child: const Center(
            child: Text(
              'SPIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildControlButton(String text, VoidCallback onPressed, Color color) {
    return Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildExplosionEffect() {
    return AnimatedBuilder(
      animation: explosionAnimation!,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: explosionAnimation!.value,
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.8),
                  Colors.orange.withValues(alpha: 0.6),
                  Colors.red.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildGodEffect() {
    return AnimatedBuilder(
      animation: godEffectAnimation!,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFD700).withValues(alpha: 0.3 * godEffectAnimation!.value),
                  Colors.transparent,
                  Color(0xFFFFD700).withValues(alpha: 0.3 * godEffectAnimation!.value),
                ],
              ),
            ),
            child: Center(
              child: Transform.scale(
                scale: 1.0 + (godEffectAnimation!.value * 0.1),
                child: const Text(
                  '⚡ GOD MODE ⚡',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<GameCard> cards = [];
  List<int> flippedIndices = [];
  int matches = 0;
  int attempts = 0;
  bool isGameActive = false;
  DateTime? startTime;
  
  final List<String> imageAssets = [
    'assets/095dc733ec8058b707b700f23774ec9d.png',
    'assets/19e9a1cb6d20769c271dd718d31c8598.png',
    'assets/451398ef90ef876ffb5bec6f5502b12d.png',
    'assets/5Gfj5ATl.jpg',
    'assets/61157b81e3b7bd7338042cbaf54a5428.png',
    'assets/6ae53c425580e2ee7d7958e8bc70df63.png',
    'assets/997eed6774eecef536b18b2cadfc3210.png',
    'assets/c2d9341b2d32ecfd26cd68081a290ec8.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    cards.clear();
    flippedIndices.clear();
    matches = 0;
    attempts = 0;
    isGameActive = false;
    startTime = null;
    
    for (String asset in imageAssets) {
      cards.add(GameCard(imagePath: asset));
      cards.add(GameCard(imagePath: asset));
    }
    
    cards.shuffle(Random());
    setState(() {});
  }

  void _flipCard(int index) {
    if (!isGameActive) {
      isGameActive = true;
      startTime = DateTime.now();
    }
    
    if (cards[index].isFlipped || 
        cards[index].isMatched || 
        flippedIndices.length >= 2) {
      return;
    }

    setState(() {
      cards[index].isFlipped = true;
      flippedIndices.add(index);
    });

    if (flippedIndices.length == 2) {
      attempts++;
      Future.delayed(const Duration(milliseconds: 1000), () {
        _checkMatch();
      });
    }
  }

  void _checkMatch() {
    if (flippedIndices.length != 2) return;
    
    int firstIndex = flippedIndices[0];
    int secondIndex = flippedIndices[1];
    
    setState(() {
      if (cards[firstIndex].imagePath == cards[secondIndex].imagePath) {
        cards[firstIndex].isMatched = true;
        cards[secondIndex].isMatched = true;
        matches++;
        
        if (matches == imageAssets.length) {
          _showGameCompleteDialog();
        }
      } else {
        cards[firstIndex].isFlipped = false;
        cards[secondIndex].isFlipped = false;
      }
      
      flippedIndices.clear();
    });
  }

  void _showGameCompleteDialog() {
    final duration = DateTime.now().difference(startTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ゲームクリア！'),
          content: Text(
            'おめでとうございます！\n\n'
            '時間: $minutes分$seconds秒\n'
            '試行回数: $attempts回'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeGame();
              },
              child: const Text('もう一度'),
            ),
          ],
        );
      },
    );
  }

  String _getElapsedTime() {
    if (startTime == null) return '00:00';
    
    final duration = DateTime.now().difference(startTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('神経衰弱ゲーム'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'マッチ: $matches/${imageAssets.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '試行回数: $attempts',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Text(
                      '時間: ${_getElapsedTime()}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _flipCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: cards[index].isMatched 
                            ? Colors.grey[300]
                            : cards[index].isFlipped
                                ? Colors.white
                                : Colors.green[400],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: cards[index].isMatched 
                              ? Colors.grey
                              : Colors.green[600]!,
                          width: 2.0,
                        ),
                      ),
                      child: cards[index].isFlipped || cards[index].isMatched
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6.0),
                              child: Image.asset(
                                cards[index].imagePath,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Text(
                                '?',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _initializeGame,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                '新しいゲーム',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
