enum RouteExecutionStatus {
  draft,
  active,
  completed;

  static RouteExecutionStatus fromApi(String? raw) {
    switch (raw) {
      case 'active':
        return RouteExecutionStatus.active;
      case 'completed':
        return RouteExecutionStatus.completed;
      case 'draft':
      default:
        return RouteExecutionStatus.draft;
    }
  }
}

enum StopStatus {
  pending,
  completed,
  postponed,
  cancelled;

  static StopStatus fromApi(String? raw) {
    switch (raw) {
      case 'completed':
        return StopStatus.completed;
      case 'postponed':
        return StopStatus.postponed;
      case 'cancelled':
        return StopStatus.cancelled;
      case 'pending':
      default:
        return StopStatus.pending;
    }
  }

  bool get isPending => this == StopStatus.pending;
}
