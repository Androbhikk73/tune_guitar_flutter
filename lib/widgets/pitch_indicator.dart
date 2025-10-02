import 'package:flutter/material.dart';

class PitchIndicator extends StatelessWidget {
  final double deviation;
  final bool isOnPitch;

  const PitchIndicator({
    super.key,
    required this.deviation,
    required this.isOnPitch,
  });

  Color _indicatorColor() {
    if (isOnPitch) return Colors.green;
    final cents = deviation.abs();
    if (cents < 15) return Colors.white;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 2,
            height: double.infinity,
            color: isOnPitch ? Colors.green : Colors.white24,
          ),
          if (isOnPitch)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4.0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 26),
            )
          else
            AnimatedAlign(
              alignment: Alignment((deviation / 50).clamp(-1.0, 1.0), 0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: _indicatorColor(), width: 4.0),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  deviation > 0
                      ? "+${deviation.toStringAsFixed(0)}"
                      : deviation.toStringAsFixed(0),
                  style: TextStyle(color: _indicatorColor(), fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
