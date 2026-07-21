library;

enum WeeklyPlanningStatus { idle, loading, success, error }

enum RouteDetailStatus { idle, loading, success, error }

enum GenerateRouteStatus { idle, resolvingLocation, generating, error }

enum RescheduleStatus { idle, working, error }

enum StopActionStatus { idle, working, error }

enum RouteSummaryStatus { idle, loading, success, error }

enum BroadcastStatus {
  idle,
  resolvingLocation,
  permissionDenied,
  broadcasting,
  routeClosed,
}
