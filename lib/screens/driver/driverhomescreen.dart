import 'package:flutter/material.dart';
import '../../api/real/auth_api.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthApi.user;
    final name = user?["name"] ?? "Driver";
    final role = user?["role"] ?? "DRIVER";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Sample"),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_shipping, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              "Welcome $name",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Role: $role", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Driver screen working 👍")),
                );
              },
              child: const Text("Test Button"),
            ),
          ],
        ),
      ),
    );
  }
}
