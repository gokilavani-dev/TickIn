import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String orderId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Success"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Order Placed Successfully 🎉",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Order ID: $orderId"),
            const SizedBox(height: 30),

            // 🔵 BOOK SLOT
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text("Book Slot"),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    "/slot-booking",
                    arguments: {"orderId": orderId},
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 🔵 VIEW MY ORDERS
            SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/sales/my-orders");
                },
                child: const Text("View My Orders"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
