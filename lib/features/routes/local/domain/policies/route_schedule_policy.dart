class RouteSchedulePolicy {
  const RouteSchedulePolicy();

  bool isToday(String isoDate) => isoDate == _todayInMexicoAsIso();

  bool canGenerateRoute(String date) => isToday(date);

  bool canStartRoute(String routeDate) => isToday(routeDate);

  static const _mexicoCityUtcOffset = Duration(hours: -6);

  String _todayInMexicoAsIso() {
    final nowInMexico = DateTime.now().toUtc().add(_mexicoCityUtcOffset);
    return _format(nowInMexico);
  }

  String _format(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
