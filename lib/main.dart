import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '神経衰弱ゲーム',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MemoryGameScreen(),
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
            '時間: ${minutes}分${seconds}秒\n'
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
