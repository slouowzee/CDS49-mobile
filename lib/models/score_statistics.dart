import 'score.dart';

class ScoreStatistics {
  final double moyenne;
  final List<Score> top3;
  final int total;

  ScoreStatistics({
    required this.moyenne,
    required this.top3,
    required this.total,
  });

  factory ScoreStatistics.fromJson(Map<String, dynamic> json) {
    return ScoreStatistics(
      moyenne: (json['moyenne'] ?? 0).toDouble(),
      top3: (json['top3'] as List<dynamic>)
          .map((item) => Score.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}
