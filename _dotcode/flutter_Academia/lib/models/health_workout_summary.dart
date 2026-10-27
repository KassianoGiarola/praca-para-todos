import '../utils/json_helpers.dart';

class HealthWorkoutSummary {
  const HealthWorkoutSummary({
    this.averageHeartRateBpm,
    this.minHeartRateBpm,
    this.maxHeartRateBpm,
    this.activeCaloriesKcal,
    this.totalCaloriesKcal,
    this.sourceName = 'Health Connect',
    this.syncedAt,
  });

  final double? averageHeartRateBpm;
  final double? minHeartRateBpm;
  final double? maxHeartRateBpm;
  final double? activeCaloriesKcal;
  final double? totalCaloriesKcal;
  final String sourceName;
  final DateTime? syncedAt;

  bool get hasHeartRate =>
      averageHeartRateBpm != null ||
      minHeartRateBpm != null ||
      maxHeartRateBpm != null;

  bool get hasCalories =>
      activeCaloriesKcal != null || totalCaloriesKcal != null;

  bool get hasData => hasHeartRate || hasCalories;

  double? get displayCaloriesKcal => activeCaloriesKcal ?? totalCaloriesKcal;

  String get caloriesLabel =>
      activeCaloriesKcal != null ? 'Calorias ativas' : 'Calorias totais';

  Map<String, dynamic> toMap() {
    return {
      'averageHeartRateBpm': averageHeartRateBpm,
      'minHeartRateBpm': minHeartRateBpm,
      'maxHeartRateBpm': maxHeartRateBpm,
      'activeCaloriesKcal': activeCaloriesKcal,
      'totalCaloriesKcal': totalCaloriesKcal,
      'sourceName': sourceName,
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  factory HealthWorkoutSummary.fromMap(Map<String, dynamic> map) {
    return HealthWorkoutSummary(
      averageHeartRateBpm: nullableDoubleFromJson(map['averageHeartRateBpm']),
      minHeartRateBpm: nullableDoubleFromJson(map['minHeartRateBpm']),
      maxHeartRateBpm: nullableDoubleFromJson(map['maxHeartRateBpm']),
      activeCaloriesKcal: nullableDoubleFromJson(map['activeCaloriesKcal']),
      totalCaloriesKcal: nullableDoubleFromJson(map['totalCaloriesKcal']),
      sourceName: map['sourceName']?.toString() ?? 'Health Connect',
      syncedAt: map['syncedAt'] == null ? null : dateFromJson(map['syncedAt']),
    );
  }
}
