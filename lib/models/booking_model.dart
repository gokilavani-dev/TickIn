import 'tracking_event_model.dart';

class ChildBooking {
  final String dealerName;
  final int amount;
  final String slot;

  ChildBooking({
    required this.dealerName,
    required this.amount,
    required this.slot,
  });
}

class BookingModel {
  final String id;
  final int totalAmount;
  final String slot;
  final String vehicleNo;

  final bool isMerged;
  final List<ChildBooking> mergedBookings;

  final List<TrackingEvent> trackingEvents;

  BookingModel({
    required this.id,
    required this.totalAmount,
    required this.slot,
    required this.vehicleNo,
    this.isMerged = false,
    this.mergedBookings = const [],
    this.trackingEvents = const [],
  });
}
