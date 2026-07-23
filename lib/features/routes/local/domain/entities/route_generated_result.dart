class RouteGeneratedResult {
  final String routeId;
  final int totalStops;
  final int totalDistanceMeters;
  final int totalDurationSeconds;

  const RouteGeneratedResult({
    required this.routeId,
    required this.totalStops,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
  });

  factory RouteGeneratedResult.fromJson(Map<String, dynamic> json) {
    return RouteGeneratedResult(
      routeId: json['routeId'] as String,
      totalStops: (json['totalStops'] as num).toInt(),
      totalDistanceMeters: (json['totalDistanceMeters'] as num).toInt(),
      totalDurationSeconds: (json['totalDurationSeconds'] as num).toInt(),
    );
  }
}
