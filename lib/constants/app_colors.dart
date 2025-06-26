import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF9C27B0);
  static const Color gold = Color(0xFFFFD700);
  static const Color darkBlue = Color(0xFF1a1a2e);
  static const Color mediumBlue = Color(0xFF16213e);
  static const Color lightBlue = Color(0xFF0f3460);
  
  static const LinearGradient mainMenuGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBlue, mediumBlue, lightBlue],
  );
  
  static const LinearGradient slotMachineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000),
      Color(0xFF1a1a1a),
      Color(0xFF333333),
    ],
  );
}