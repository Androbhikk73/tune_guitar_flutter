import 'package:flutter/material.dart';
import '../models/guitar_string.dart';

class PegButton extends StatelessWidget {
  final GuitarString string;
  final bool isCompleted;
  final bool isActive;
  final bool autoMode;
  final double deviation;
  final VoidCallback? onSelected;

  const PegButton({
    super.key,
    required this.string,
    required this.isCompleted,
    required this.isActive,
    required this.autoMode,
    required this.deviation,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    if (deviation != 999) {
      progress = (1 - (deviation.abs() / 50.0)).clamp(0.0, 1.0);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: isCompleted ? 1.0 : progress,
            strokeWidth: 5,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? Colors.green : Colors.blueAccent,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isCompleted ? Colors.green : Colors.grey[850],
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(18),
            side: isActive && !isCompleted
                ? const BorderSide(color: Colors.green, width: 2)
                : BorderSide.none,
          ),
          onPressed: (autoMode || isCompleted) ? null : onSelected,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 24)
              : Text(
                  string.id,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
        ),
      ],
    );
  }
}
