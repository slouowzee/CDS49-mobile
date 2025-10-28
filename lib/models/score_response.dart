import 'score.dart';
import 'score_statistics.dart';

class ScoreResponse {
  final List<Score> scores;
  final ScoreStatistics statistics;

  ScoreResponse({
    required this.scores,
    required this.statistics,
  });

  factory ScoreResponse.fromJson(Map<String, dynamic> json) {
    return ScoreResponse(
      scores: (json['scores'] as List<dynamic>)
          .map((item) => Score.fromJson(item))
          .toList(),
      statistics: ScoreStatistics.fromJson(json['statistics']),
    );
  }
}
