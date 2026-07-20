class WeeklyPlanningDay {
  final String date;
  final String dayLabel;
  final int pickupCount;

  const WeeklyPlanningDay({
    required this.date,
    required this.dayLabel,
    required this.pickupCount,
  });

  factory WeeklyPlanningDay.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanningDay(
      date: json['date'] as String,
      dayLabel: json['dayLabel'] as String,
      pickupCount: (json['pickupCount'] as num).toInt(),
    );
  }
}
