import 'package:flutter/material.dart';

class AppConstants {
  static const String appTitle = 'ミウチゲーム';
  
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
  
  static const List<String> slotSymbols = [
    '7', 'BAR', 'BELL', 'CHERRY', 'GOD', 'LEMON', 'STAR'
  ];
  
  static const Color goldColor = Color(0xFFFFD700);
  
  static const Map<String, int> symbolMultipliers = {
    '7': 100,
    'BAR': 50,
    'BELL': 20,
    'STAR': 15,
    'CHERRY': 10,
    'LEMON': 5,
  };
  
  static const int godMultiplier = 777;
  static const int initialCredits = 1000;
  static const int initialBet = 10;
  static const int minBet = 10;
  static const int maxBet = 100;
  static const int betIncrement = 10;
}