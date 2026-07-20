const _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _monthNames = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatPickupLabel(String date, String start, String end) {
  if (date.isEmpty) return '';
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return '';

  final day = _dayNames[parsed.weekday - 1];
  final month = _monthNames[parsed.month - 1];
  final dateLabel = '$day ${parsed.day} $month';

  if (start.isEmpty || end.isEmpty) return dateLabel;
  return '$dateLabel · $start - $end';
}
