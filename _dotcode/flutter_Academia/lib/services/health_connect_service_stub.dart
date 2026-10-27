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
  const HealthConnectService();

  bool get isSupportedPlatform => false;

  Future<HealthConnectAvailability> checkAvailability() async {
    return HealthConnectAvailability.unsupportedPlatform;
  }

  Future<bool> hasPermissions() async => false;

  Future<bool> requestPermissions() async => false;

  Future<void> installHealthConnect() async {}

  Future<HealthWorkoutSummary?> readWorkoutSummary(
    WorkoutSession session,
  ) async {
    return null;
  }
}
