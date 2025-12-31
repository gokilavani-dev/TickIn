import 'package:flutter/material.dart';

class DealerBookingDetailScreen extends StatelessWidget {
  final String bookingId;
  final int amount;
  final String slot;
  final String vehicle;
  final int tripNo;

  const DealerBookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.slot,
    required this.vehicle,
    required this.tripNo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text("Booking ID: $bookingId"),
            Text("Amount: ₹$amount"),
            Text("Slot: $slot"),
            Text("Vehicle: $vehicle"),
            Text("Trip No: $tripNo"),
          ],
        ),
      ),
    );
  }
}
