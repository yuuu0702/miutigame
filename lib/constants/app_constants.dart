import 'package:flutter/material.dart';

class AppConstants {
  static const String appTitle = 'OguraGames';

  static const List<String> imageAssets = [
    'assets/095dc733ec8058b707b700f23774ec9d.png',
    'assets/19e9a1cb6d20769c271dd718d31c8598.png',
    'assets/451398ef90ef876ffb5bec6f5502b12d.png',
    'assets/5Gfj5ATl.jpg',
    'assets/61157b81e3b7bd7338042cbaf54a5428.png',
    'assets/6ae53c425580e2ee7d7958e8bc70df63.png',
    'assets/997eed6774eecef536b18b2cadfc3210.png',
    'assets/c2d9341b2d32ecfd26cd68081a290ec8.png',
    'assets/d18ed6724eb5731d08537c6b172b8580.png',
    'assets/disneyKMR.png',
    'assets/nao10.png',
    'assets/nao11.jpg',
    'assets/nao12.jpg',
    'assets/nao6.png',
    'assets/nao7.png',
    'assets/nao8.png',
    'assets/nao9.png',
  ];

  // スロット図柄（assetsの画像を使用）
  static const List<String> slotSymbols = [
    'assets/god.png', // GODシンボル（特別）
    'assets/nao1.png', // 高配当シンボル
    'assets/nao2.png', // 高配当シンボル
    'assets/nao3.png', // 中配当シンボル
    'assets/nao4.png', // 中配当シンボル
    'assets/nao5.png', // 低配当シンボル
    'assets/naoki.png', // 低配当シンボル
  ];

  // GODシンボル専用
  static const String godSymbol = 'assets/god.png';

  static const Color goldColor = Color(0xFFFFD700);

  static const Map<String, int> symbolMultipliers = {
    'assets/nao1.png': 100, // 最高配当
    'assets/nao2.png': 50, // 高配当
    'assets/nao3.png': 20, // 中配当
    'assets/nao4.png': 15, // 中配当
    'assets/nao5.png': 10, // 低配当
    'assets/naoki.png': 5, // 最低配当
  };

  // カットイン用の画像
  static const List<String> cutinImages = [
    'assets/nao11.jpg',
    'assets/nao12.jpg',
    'assets/nao7.png',
    'assets/saginaoki.jpg',
  ];

  static const int godMultiplier = 777;
  static const int initialCredits = 1000;
  static const int initialBet = 10;
  static const int minBet = 10;
  static const int maxBet = 100;
  static const int betIncrement = 10;
}
