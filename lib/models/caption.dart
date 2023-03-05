class Caption {
  final String text;
  final double start;
  final double duration;

  Caption({required this.text, required this.start, required this.duration});

  factory Caption.fromJson(Map<String, dynamic> json) {
    return Caption(
      text: json['text'],
      start: json['start'],
      duration: json['duration'],
    );
  }
}
