import 'package:intl/intl.dart';

final _dateFormatter = DateFormat('dd/MM/yyyy');
final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

String formatDate(DateTime value) => _dateFormatter.format(value);

String formatDateTime(DateTime value) => _dateTimeFormatter.format(value);

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String formatKg(double? value) {
  if (value == null) {
    return '-';
  }
  if (value == value.roundToDouble()) {
    return '${value.round()} kg';
  }
  return '${value.toStringAsFixed(1)} kg';
}

String formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toStringAsFixed(1);
}

String formatBpm(double? value) {
  if (value == null) {
    return '-';
  }
  return '${value.round()} bpm';
}

String formatCalories(double? value) {
  if (value == null) {
    return '-';
  }
  return '${value.round()} kcal';
}

const weekdayShortLabels = <int, String>{
  1: 'Seg',
  2: 'Ter',
  3: 'Qua',
  4: 'Qui',
  5: 'Sex',
  6: 'Sáb',
  7: 'Dom',
};

const weekdayLongLabels = <int, String>{
  1: 'Segunda',
  2: 'Terça',
  3: 'Quarta',
  4: 'Quinta',
  5: 'Sexta',
  6: 'Sábado',
  7: 'Domingo',
};

String formatWeekdays(List<int> weekdays, {bool short = true}) {
  final labels = short ? weekdayShortLabels : weekdayLongLabels;
  final normalized =
      weekdays.where((weekday) => labels.containsKey(weekday)).toSet().toList()
        ..sort();

  if (normalized.isEmpty) {
    return 'Sem dia fixo';
  }

  return normalized.map((weekday) => labels[weekday]!).join(', ');
}
