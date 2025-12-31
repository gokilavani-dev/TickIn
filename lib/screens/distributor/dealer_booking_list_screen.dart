import 'package:flutter/material.dart';
import 'dealer_booking_detail_screen.dart';

class DealerBookingListScreen extends StatelessWidget {
  const DealerBookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = [
      {
        "id": "BK123",
        "status": "CONFIRMED",
        "amount": 90000,
        "slot": "09:00 - 09:30",
        "vehicle": "TN03 EF 1111",
        "trip": 2,
      },
      {"id": "BK124", "status": "WAITING", "amount": 40000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];

          return Card(
            child: ListTile(
              title: Text("Booking ID: ${b["id"]}"),
              subtitle: Text("Status: ${b["status"]}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: b["status"] == "CONFIRMED"
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DealerBookingDetailScreen(
                            bookingId: b["id"] as String,
                            amount: b["amount"] as int,
                            slot: b["slot"] as String,
                            vehicle: b["vehicle"] as String,
                            tripNo: b["trip"] as int,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
