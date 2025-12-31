enum TrackingStatus { started, arrived, loadingStarted, unloading, completed }

class TrackingEvent {
  final TrackingStatus status;
  final DateTime time;
  final String updatedBy; // Driver / Supervisor

  TrackingEvent({
    required this.status,
    required this.time,
    required this.updatedBy,
  });
}
