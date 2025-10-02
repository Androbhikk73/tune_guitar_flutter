class GuitarString {
  final String id;
  final String label; // Human name, e.g., "Low E"
  final String note; // Note letter, e.g., "E"
  final int octave; // Octave number
  final double frequency; // Hz

  const GuitarString({
    required this.id,
    required this.label,
    required this.note,
    required this.octave,
    required this.frequency,
  });
}
