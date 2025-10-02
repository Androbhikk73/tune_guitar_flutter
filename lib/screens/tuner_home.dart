import 'package:flutter/material.dart';
import '../models/guitar_models.dart';
import '../models/guitar_string.dart';
import '../widgets/peg_button.dart';
import '../widgets/pitch_indicator.dart';

class TunerHome extends StatefulWidget {
  const TunerHome({super.key});

  @override
  State<TunerHome> createState() => _TunerHomeState();
}

class _TunerHomeState extends State<TunerHome> {
  GuitarModel _currentModel = standardSixString;

  bool _autoMode = true;
  bool _isRecording = false;

  double _deviation = 0.0;
  bool _isOnPitch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 🎸 Header row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tune Your Guitar",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),

                  // ✅ Model Selector Dropdown
                  DropdownButton<GuitarModel>(
                    dropdownColor: Colors.black87,
                    value: _currentModel,
                    items: guitarModels.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(
                          model.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (model) {
                      if (model != null) {
                        setState(() {
                          _currentModel = model;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            // 🎚️ Controls row (AUTO + Mic button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        "AUTO",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Switch(
                        value: _autoMode,
                        activeThumbColor: Colors.green,
                        onChanged: (val) {
                          setState(() {
                            _autoMode = val;
                            _resetCompletedStrings();
                          });
                        },
                      ),
                    ],
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isRecording = !_isRecording;
                        _resetCompletedStrings();
                      });
                    },
                    icon: Icon(
                      _isRecording ? Icons.mic : Icons.mic_off,
                      color: _isRecording ? Colors.red : Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Pitch indicator
            PitchIndicator(deviation: _deviation, isOnPitch: _isOnPitch),

            // ✅ Headstock + pegs
            SizedBox(
              width: 500,
              height: 450,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(_currentModel.headstockAsset),

                  // 🎸 Layout depends on headstock type
                  if (_currentModel.headstockType == "3x3") ...[
                    // Left 3 pegs
                    for (int i = 0; i < 3; i++)
                      Positioned(
                        left: 15,
                        top: 100 + (i * 70),
                        child: PegButton(
                          string: _currentModel.tuning[i],
                          isCompleted: false,
                          isActive: false,
                          autoMode: _autoMode,
                          deviation: _deviation,
                          onSelected: () {},
                        ),
                      ),

                    // Right 3 pegs
                    for (int i = 3; i < 6; i++)
                      Positioned(
                        right: 15,
                        top: 100 + ((i - 3) * 70),
                        child: PegButton(
                          string: _currentModel.tuning[i],
                          isCompleted: false,
                          isActive: false,
                          autoMode: _autoMode,
                          deviation: _deviation,
                          onSelected: () {},
                        ),
                      ),
                  ],

                  if (_currentModel.headstockType == "6-inline") ...[
                    for (int i = 0; i < _currentModel.tuning.length; i++)
                      Positioned(
                        right: 10,
                        top: 80 + (i * 55),
                        child: PegButton(
                          string: _currentModel.tuning[i],
                          isCompleted: false,
                          isActive: false,
                          autoMode: _autoMode,
                          deviation: _deviation,
                          onSelected: () {},
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetCompletedStrings() {
    // Reset logic for pegs when AUTO / mic toggled
    debugPrint("Resetting completed strings");
  }
}
