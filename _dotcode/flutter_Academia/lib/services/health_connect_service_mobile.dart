import 'dart:io';

import 'package:health/health.dart';

import '../models/health_workout_summary.dart';
import '../models/workout_session.dart';

enum HealthConnectAvailability {
  available,
  unsupportedPlatform,
  unavailable,
  updateRequired,
  unknown,
}

class HealthConnectService {
  HealthConnectService();

  final Health _health = Health();
  bool _configured = false;

  static const _types = <HealthDataType>[
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  static const _permissions = <HealthDataAccess>[
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  bool get isSupportedPlatform => Platform.isAndroid;

  Future<HealthConnectAvailability> checkAvailability() async {
    if (!Platform.isAndroid) {
      return HealthConnectAvailability.unsupportedPlatform;
    }

    await _configure();
    final status = await _health.getHealthConnectSdkStatus();
    return switch (status) {
      HealthConnectSdkStatus.sdkAvailable =>
        HealthConnectAvailability.available,
      HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired =>
        HealthConnectAvailability.updateRequired,
      HealthConnectSdkStatus.sdkUnavailable =>
        HealthConnectAvailability.unavailable,
      null => HealthConnectAvailability.unknown,
    };
  }

  Future<bool> hasPermissions() async {
    if (await checkAvailability() != HealthConnectAvailability.available) {
      return false;
    }

    try {
      return await _health.hasPermissions(_types, permissions: _permissions) ??
          false;
    } on Object {
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    if (await checkAvailability() != HealthConnectAvailability.available) {
      return false;
    }

    try {
      return _health.requestAuthorization(_types, permissions: _permissions);
    } on Object {
      return false;
    }
  }

  Future<void> installHealthConnect() async {
    if (!Platform.isAndroid) {
      return;
    }
    await _configure();
    await _health.installHealthConnect();
  }

  Future<HealthWorkoutSummary?> readWorkoutSummary(
    WorkoutSession session,
  ) async {
    if (await checkAvailability() != HealthConnectAvailability.available) {
      return null;
    }

    final hasAccess = await hasPermissions();
    if (!hasAccess) {
      return null;
    }

    final endedAt = session.endedAt ?? DateTime.now();
    final startTime = session.startedAt.subtract(const Duration(minutes: 1));
    final endTime = endedAt.add(const Duration(minutes: 1));

    final points = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: startTime,
      endTime: endTime,
    );

    final heartRates = points
        .where((point) => point.type == HealthDataType.HEART_RATE)
        .map(_numericValue)
        .nonNulls
        .where((value) => value > 0)
        .toList();
    final activeCalories = points
        .where((point) => point.type == HealthDataType.ACTIVE_ENERGY_BURNED)
        .map(_numericValue)
        .nonNulls
        .where((value) => value > 0)
        .toList();
    final totalCalories = points
        .where((point) => point.type == HealthDataType.TOTAL_CALORIES_BURNED)
        .map(_numericValue)
        .nonNulls
        .where((value) => value > 0)
        .toList();

    final summary = HealthWorkoutSummary(
      averageHeartRateBpm: _average(heartRates),
      minHeartRateBpm: _min(heartRates),
      maxHeartRateBpm: _max(heartRates),
      activeCaloriesKcal: _sum(activeCalories),
      totalCaloriesKcal: _sum(totalCalories),
      sourceName: _friendlySourceName(points),
      syncedAt: DateTime.now(),
    );

    return summary.hasData ? summary : null;
  }

  Future<void> _configure() async {
    if (_configured) {
      return;
    }
    await _health.configure();
    _configured = true;
  }

  double? _numericValue(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
  }

  double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.fold<double>(0, (sum, value) => sum + value) / values.length;
  }

  double? _min(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a < b ? a : b);
  }

  double? _max(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a > b ? a : b);
  }

  double? _sum(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.fold<double>(0, (sum, value) => sum + value);
  }

  String _friendlySourceName(List<HealthDataPoint> points) {
    final sourceName = points
        .map((point) => point.sourceName.trim())
        .firstWhere((name) => name.isNotEmpty, orElse: () => 'Health Connect');
    final normalized = sourceName.toLowerCase();
    if (normalized.contains('huami') ||
        normalized.contains('zepp') ||
        normalized.contains('amazfit')) {
      return 'Zepp';
    }
    return sourceName;
  }
}
