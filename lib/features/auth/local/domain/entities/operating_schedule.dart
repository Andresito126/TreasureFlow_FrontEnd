class OperatingSchedule {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const OperatingSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'startTime': startTime,
    'endTime': endTime,
  };
}
