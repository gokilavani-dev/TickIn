import 'package:flutter/material.dart';

class DealerWaitingScreen extends StatelessWidget {
  const DealerWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Waiting")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.hourglass_top, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              "Waiting for Manager Approval",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
