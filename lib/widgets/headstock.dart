import 'package:flutter/material.dart';
import '../models/guitar_string.dart';
import 'peg_button.dart';

class Headstock extends StatelessWidget {
  final List<GuitarString> strings;
  final Set<String> completedStrings;
  final String? targetNote;
  final int? targetOctave;
  final bool autoMode;
  final double deviation;
  final void Function(GuitarString) onSelect;

  const Headstock({
    super.key,
    required this.strings,
    required this.completedStrings,
    required this.targetNote,
    required this.targetOctave,
    required this.autoMode,
    required this.deviation,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 450,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/headstock.png"),

          // Left side (Low E, A, D)
          Positioned(
            left: 15,
            top: 265,
            child: PegButton(
              string: strings[0],
              isCompleted: completedStrings.contains(strings[0].id),
              isActive: targetNote == "E" && targetOctave == 2,
              autoMode: autoMode,
              deviation: deviation,
              onSelected: () => onSelect(strings[0]),
            ),
          ),
          Positioned(
            left: 15,
            top: 185,
            child: PegButton(
              string: strings[1],
              isCompleted: completedStrings.contains(strings[1].id),
              isActive: targetNote == "A" && targetOctave == 2,
              autoMode: autoMode,
              deviation: deviation,
              onSelected: () => onSelect(strings[1]),
            ),
          ),
          Positioned(
            left: 15,
            top: 105,
            child: PegButton(
              string: strings[2],
              isCompleted: completedStrings.contains(strings[2].id),
              isActive: targetNote == "D" && targetOctave == 3,
              autoMode: autoMode,
              deviation: deviation,
              onSelected: () => onSelect(strings[2]),
            ),
          ),

          // Right side (G, B, High E)
          Positioned(
            right: 15,
            top: 105,
            child: PegButton(
              string: strings[3],
              isCompleted: completedStrings.contains(strings[3].id),
              isActive: targetNote == "G" && targetOctave == 3,
              autoMode: autoMode,
              deviation: deviation,
              onSelected: () => onSelect(strings[3]),
            ),
          ),
          Positioned(
            right: 15,
            top: 185,
            child: PegButton(
              string: strings[4],
              isCompleted: completedStrings.contains(strings[4].id),
              isActive: targetNote == "B" && targetOctave == 3,
              autoMode: autoMode,
              deviation: deviation,
              onSelected: () => onSelect(strings[4]),
            ),
          ),
          Positioned(
            right: 15,
            top: 265,
            child: PegButton(
              string: strings[5],
              isCompleted: completedStrings.contains(strings[5].id),
              isActive: targetNote == "E" && targetOctave == 4,
              autoMode: autoMode,
              deviation: deviation,
              onSelected: () => onSelect(strings[5]),
            ),
          ),
        ],
      ),
    );
  }
}
