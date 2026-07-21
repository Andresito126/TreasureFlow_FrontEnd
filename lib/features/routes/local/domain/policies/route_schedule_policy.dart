class RouteSchedulePolicy {
  const RouteSchedulePolicy();

  bool isToday(String isoDate) => isoDate == _todayAsIso();

  bool canGenerateRoute(String date) => isToday(date);

  bool canStartRoute(String routeDate) => isToday(routeDate);

  String _todayAsIso() {
    final now = DateTime.now();
    return _format(now);
  }

  String _format(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
