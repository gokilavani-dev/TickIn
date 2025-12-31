import '../models/tracking_event_model.dart';

class TrackingService {
  static List<TrackingEvent> getTracking(String bookingId) {
    return [
      TrackingEvent(
        status: TrackingStatus.started,
        time: DateTime.now().subtract(const Duration(hours: 4)),
        updatedBy: "Driver",
      ),
      TrackingEvent(
        status: TrackingStatus.arrived,
        time: DateTime.now().subtract(const Duration(hours: 3)),
        updatedBy: "Driver",
      ),
      TrackingEvent(
        status: TrackingStatus.loadingStarted,
        time: DateTime.now().subtract(const Duration(hours: 2)),
        updatedBy: "Supervisor",
      ),
    ];
  }
}
