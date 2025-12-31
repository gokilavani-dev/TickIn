import 'package:flutter/material.dart';
import '../../api/real/auth_api.dart';

class ManagerHomeScreen extends StatelessWidget {
  const ManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthApi.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager Home"),
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
            "Welcome ${user?["name"] ?? "Manager"}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Manage Slots"),
              subtitle: const Text("Edit,Delete slots"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/slot-booking");
              },
            ),
          ),

          // ✅ Orders → list → OrderDetailScreen (same screen)
          Card(
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.blue),
              title: const Text("Orders"),
              subtitle: const Text("View all orders & book slot"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/sales/my-orders");
              },
            ),
          ),

          // ✅ Booking History (read only)
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Booking History"),
              subtitle: const Text("All bookings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/booking-history");
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.purple),
              title: const Text("Reports"),
              subtitle: const Text("Daily booking summary"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, "/manager/dashboard");
              },
            ),
          ),
        ],
      ),
    );
  }
}
