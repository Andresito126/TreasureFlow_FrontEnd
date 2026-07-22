enum RouteExecutionStatus {
  draft,
  active,
  completed,

  abandoned;

  static RouteExecutionStatus fromApi(String? raw) {
    switch (raw) {
      case 'active':
        return RouteExecutionStatus.active;
      case 'completed':
        return RouteExecutionStatus.completed;
      case 'abandoned':
        return RouteExecutionStatus.abandoned;
      case 'draft':
      default:
        return RouteExecutionStatus.draft;
    }
  }
}

enum StopStatus {
  pending,

  inProgress,
  completed,
  postponed,
  cancelled;

  static StopStatus fromApi(String? raw) {
    switch (raw) {
      case 'in_progress':
        return StopStatus.inProgress;
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

  bool get isActionable =>
      this == StopStatus.pending || this == StopStatus.inProgress;

  bool get isArrived => this == StopStatus.inProgress;
}
