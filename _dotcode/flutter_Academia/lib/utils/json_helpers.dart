DateTime dateFromJson(Object? value, {DateTime? fallback}) {
  if (value is DateTime) {
    return value;
  }

  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  }

  try {
    final date = (value as dynamic).toDate();
    if (date is DateTime) {
      return date;
    }
  } catch (_) {
    // Firestore Timestamps expose toDate(), but mock data uses plain values.
  }

  return fallback ?? DateTime.now();
}

int intFromJson(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

double? nullableDoubleFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    final normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }
  return null;
}

double doubleFromJson(Object? value, {double fallback = 0}) {
  return nullableDoubleFromJson(value) ?? fallback;
}

List<Map<String, dynamic>> mapListFromJson(Object? value) {
  if (value is! List) {
    return const [];
  }

  return value
      .whereType<Map>()
      .map((entry) => Map<String, dynamic>.from(entry))
      .toList();
}
