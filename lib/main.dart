import 'package:flutter/material.dart';
import 'screens/tuner_home.dart';

void main() {
  runApp(const GuitarTunerApp());
}

class GuitarTunerApp extends StatelessWidget {
  const GuitarTunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TunerHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
