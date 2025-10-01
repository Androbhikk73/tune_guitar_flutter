import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pitch_detection/flutter_pitch_detection.dart';
import 'dart:math' as math;
import 'package:wakelock_plus/wakelock_plus.dart';

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

class TunerHome extends StatefulWidget {
  const TunerHome({super.key});

  @override
  State<TunerHome> createState() => _TunerHomeState();
}

class _TunerHomeState extends State<TunerHome> {
  final FlutterPitchDetection _pitchDetector = FlutterPitchDetection();
  StreamSubscription<Map<String, dynamic>>? _sub;

  bool _isRecording = false;
  bool _autoMode = true;

  String _note = "";
  String _noteOctave = "";
  double _frequency = 0.0;
  bool _isOnPitch = false;
  double _pitchDeviation = 0.0;
  double _volume = 0.0;

  String? _targetNote;
  int? _targetOctave;
  double? _targetFrequency;
  GuitarString? _lastDetectedString;
  DateTime _lastLockTime = DateTime.now();
  Set<String> _completedStrings = {};

  // Standard guitar strings
  final List<GuitarString> _strings = [
    GuitarString('Low E', 'E', 2, 82.41),
    GuitarString('A', 'A', 2, 110.0),
    GuitarString('D', 'D', 3, 146.83),
    GuitarString('G', 'G', 3, 196.0),
    GuitarString('B', 'B', 3, 246.94),
    GuitarString('High E', 'E', 4, 329.63),
  ];

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _sub?.cancel();
    _pitchDetector.stopDetection();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (_isRecording) return;
    try {
      _resetCompletedStrings();
      await _pitchDetector.startDetection();
      bool rec = await _pitchDetector.isRecording();
      setState(() {
        _isRecording = rec;
      });

      _pitchDetector.setParameters(
        toleranceCents: 0.6,
        bufferSize: 8196,
        sampleRate: 44100,
        minPrecision: 0.8,
        a4Reference: 440.0,
      );

      _sub = _pitchDetector.onPitchDetected.listen((data) {
        double freq = (data['frequency'] ?? 0.0).toDouble();
        double vol = (data['volume'] ?? 0.0).toDouble();

        // 1. Filter frequency range (only guitar range)
        if (freq < 70 || freq > 1000) return;

        // 2. Filter low volume (background noise)
        if (vol < 0.01) return;

        // 3. If manual mode, ignore very far frequencies
        if (!_autoMode && _targetFrequency != null) {
          double cents = _centsFromFrequencyDiff(freq, _targetFrequency!);
          if (cents.abs() > 100) return;
        }

        setState(() {
          _note = data['note'] ?? '';
          _noteOctave = data['noteOctave'] ?? '';
          _frequency = freq;
          _isOnPitch = data['isOnPitch'] ?? false;
          _pitchDeviation = (data['pitchDeviation'] ?? 0.0).toDouble();
          _volume = vol;

          if (_autoMode) {
            // Find nearest string
            final nearest = _strings.reduce(
              (a, b) => (freq - a.frequency).abs() < (freq - b.frequency).abs()
                  ? a
                  : b,
            );

            // Lock mechanism (don’t switch too fast)
            final now = DateTime.now();
            if (_lastDetectedString == null ||
                _lastDetectedString != nearest ||
                now.difference(_lastLockTime) > const Duration(seconds: 1)) {
              _lastDetectedString = nearest;
              _lastLockTime = now;
              _selectString(nearest, auto: true);
            }

            // If tuned correctly, mark as completed
            if (_isOnPitch && nearest.note == _targetNote) {
              _completedStrings.add(nearest.note + nearest.octave.toString());
            }
          }
        });
      });
    } catch (e) {
      debugPrint("Start error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start listening: $e')));
    }
  }

  Future<void> _stopListening() async {
    if (!_isRecording) return;
    try {
      _resetCompletedStrings();
      await _sub?.cancel();
      _sub = null;
      await _pitchDetector.stopDetection();
      setState(() {
        _isRecording = false;
        _note = '';
        _noteOctave = '';
        _frequency = 0.0;
        _pitchDeviation = 0.0;
        _isOnPitch = false;
      });
    } catch (e) {
      debugPrint("Stop error: $e");
    }
  }

  void _selectString(GuitarString s, {bool auto = false}) {
    setState(() {
      _targetNote = s.note;
      _targetOctave = s.octave;
      _targetFrequency = s.frequency;
    });
  }

  void _resetCompletedStrings() {
    setState(() {
      _completedStrings.clear();
      _lastDetectedString = null;
    });
  }

  // Helpers
  double _centsFromFrequencyDiff(double freq, double target) {
    if (freq <= 0 || target <= 0) return 0.0;
    return 1200.0 * (math.log(freq / target) / math.log(2));
  }

  double _currentDeviation() {
    if (_targetFrequency == null) return 0.0;
    return _centsFromFrequencyDiff(_frequency, _targetFrequency!);
  }

  Color _indicatorColor() {
    if (_isOnPitch) return Colors.green;
    final cents = _currentDeviation().abs();
    if (cents < 15) return Colors.white;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final double deviation = _currentDeviation();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with AUTO toggle
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tune Your Guitar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "AUTO",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Switch(
                        value: _autoMode,
                        activeThumbColor:
                            Colors.green, // ✅ replaces activeColor
                        activeTrackColor: Colors.green.withValues(alpha: 0.5),
                        onChanged: (val) {
                          _resetCompletedStrings();
                        },
                      ),
                      IconButton(
                        onPressed: _isRecording
                            ? _stopListening
                            : _startListening,
                        icon: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          color: _isRecording ? Colors.green : Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Detected note with rounded frequency
            Text(
              _note.isNotEmpty
                  ? "Detected: $_note$_noteOctave (${_frequency.toStringAsFixed(1)} Hz)"
                  : "—",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Indicator
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 2,
                    height: double.infinity,
                    color: _isOnPitch ? Colors.green : Colors.white24,
                  ),
                  if (_isOnPitch)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 4.0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 26,
                      ),
                    )
                  else
                    AnimatedAlign(
                      alignment: Alignment(
                        (deviation / 50).clamp(-1.0, 1.0),
                        0,
                      ),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _indicatorColor(),
                            width: 4.0,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          deviation > 0
                              ? "+${deviation.toStringAsFixed(0)}"
                              : deviation.toStringAsFixed(0),
                          style: TextStyle(
                            color: _indicatorColor(),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              _isOnPitch
                  ? "Perfectly tuned!"
                  : _frequency > 0
                  ? deviation > 0
                        ? "Tighten your string"
                        : "Loosen your string"
                  : "Start tuning by playing any string",
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),

            // Headstock with pegs
            SizedBox(
              width: 500,
              height: 450,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/images/headstock.png",
                    fit: BoxFit.contain,
                  ),
                  Positioned(left: 15, top: 105, child: _pegButton("D")),
                  Positioned(left: 15, top: 170, child: _pegButton("A")),
                  Positioned(left: 15, bottom: 160, child: _pegButton("E")),
                  Positioned(right: 10, top: 105, child: _pegButton("G")),
                  Positioned(right: 10, top: 170, child: _pegButton("B")),
                  Positioned(right: 10, bottom: 160, child: _pegButton("E")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pegButton(String label) {
    final isCompleted = _completedStrings.contains(label);
    final active = _targetNote == label;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted
            ? Colors
                  .green // completed string
            : Colors.grey[850],
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(14),
        side: active && !isCompleted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      onPressed: _autoMode || isCompleted
          ? null
          : () {
              final s = _strings.firstWhere(
                (gs) => gs.note == label,
                orElse: () => _strings.first,
              );
              _selectString(s);
            },
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          decoration: isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
    );
  }
}

class GuitarString {
  final String label;
  final String note;
  final int octave;
  final double frequency;
  GuitarString(this.label, this.note, this.octave, this.frequency);
}
