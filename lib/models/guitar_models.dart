import '../models/guitar_string.dart';

class GuitarModel {
  final String name;
  final String headstockType; // e.g., "3x3" or "6-inline"
  final String headstockAsset;
  final List<GuitarString> tuning;

  const GuitarModel({
    required this.name,
    required this.headstockType,
    required this.headstockAsset,
    required this.tuning,
  });
}

/// 🎸 Standard 6-string guitar
const GuitarModel standardSixString = GuitarModel(
  name: "Standard Guitar",
  headstockType: "3x3",
  headstockAsset: "assets/images/headstock.png",
  tuning: [
    GuitarString(
      id: "E2",
      label: "Low E",
      note: "E",
      octave: 2,
      frequency: 82.41,
    ),
    GuitarString(id: "A2", label: "A", note: "A", octave: 2, frequency: 110.0),
    GuitarString(id: "D3", label: "D", note: "D", octave: 3, frequency: 146.83),
    GuitarString(id: "G3", label: "G", note: "G", octave: 3, frequency: 196.0),
    GuitarString(id: "B3", label: "B", note: "B", octave: 3, frequency: 246.94),
    GuitarString(
      id: "E4",
      label: "High E",
      note: "E",
      octave: 4,
      frequency: 329.63,
    ),
  ],
);

/// 🎸 Fender-style 6-inline
const GuitarModel sixInline = GuitarModel(
  name: "6 Inline Guitar",
  headstockType: "6-inline",
  headstockAsset: "assets/images/headstock_single.png",
  tuning: [
    GuitarString(
      id: "E2",
      label: "Low E",
      note: "E",
      octave: 2,
      frequency: 82.41,
    ),
    GuitarString(id: "A2", label: "A", note: "A", octave: 2, frequency: 110.0),
    GuitarString(id: "D3", label: "D", note: "D", octave: 3, frequency: 146.83),
    GuitarString(id: "G3", label: "G", note: "G", octave: 3, frequency: 196.0),
    GuitarString(id: "B3", label: "B", note: "B", octave: 3, frequency: 246.94),
    GuitarString(
      id: "E4",
      label: "High E",
      note: "E",
      octave: 4,
      frequency: 329.63,
    ),
  ],
);

/// 🎸 All available guitar models
const List<GuitarModel> guitarModels = [standardSixString, sixInline];
