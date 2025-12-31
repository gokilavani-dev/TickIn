// lib/screens/distributor/distributor_home_screen.dart
import 'package:flutter/material.dart';
import '../../api/real/auth_api.dart';

class DistributorHomeScreen extends StatelessWidget {
  const DistributorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthApi.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Distributor Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthApi.token = null;
              AuthApi.user = null;
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Welcome ${user?["name"] ?? "Distributor"}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Slot booking (NO bookingId)
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_available, color: Colors.blue),
              title: const Text("Slot Booking"),
              subtitle: const Text("Book full / partial truck slots"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/slot-booking");
              },
            ),
          ),

          // Booking history
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Booking History"),
              subtitle: const Text("My bookings • Track"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/booking-history");
              },
            ),
          ),
        ],
      ),
    );
  }
}
