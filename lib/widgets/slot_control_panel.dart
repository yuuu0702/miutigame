import 'package:flutter/material.dart';

class SlotControlPanel extends StatelessWidget {
  final VoidCallback onSpin;
  final VoidCallback onBetDecrease;
  final VoidCallback onBetIncrease;

  const SlotControlPanel({
    super.key,
    required this.onSpin,
    required this.onBetDecrease,
    required this.onBetIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton('ベット-', onBetDecrease, Colors.red),
          _buildSpinButton(),
          _buildControlButton('ベット+', onBetIncrease, Colors.blue),
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
          onTap: onSpin,
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
}