import 'package:flutter/material.dart';

class SlotControlPanel extends StatelessWidget {
  final VoidCallback onSpin;
  final VoidCallback onBetDecrease;
  final VoidCallback onBetIncrease;
  final VoidCallback onAutoStart;
  final VoidCallback onAutoStop;
  final bool isAutoMode;
  final bool canSpin;

  const SlotControlPanel({
    super.key,
    required this.onSpin,
    required this.onBetDecrease,
    required this.onBetIncrease,
    required this.onAutoStart,
    required this.onAutoStop,
    required this.isAutoMode,
    required this.canSpin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // メインコントロール行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton('ベット-', onBetDecrease, Colors.red),
              _buildSpinButton(),
              _buildControlButton('ベット+', onBetIncrease, Colors.blue),
            ],
          ),
          const SizedBox(height: 15),
          // オートコントロール行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAutoButton(),
              _buildStopButton(),
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
          onTap: canSpin ? onSpin : null,
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
  
  Widget _buildAutoButton() {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: isAutoMode ? Colors.orange : Colors.green,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isAutoMode ? [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isAutoMode ? null : onAutoStart,
          child: Center(
            child: Text(
              isAutoMode ? 'AUTO中' : 'AUTO',
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
  
  Widget _buildStopButton() {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: isAutoMode ? onAutoStop : null,
          child: Center(
            child: Text(
              'STOP',
              style: TextStyle(
                color: isAutoMode ? Colors.white : Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}