import 'package:flutter/material.dart';
import 'dealer_booking_detail_screen.dart';
import 'dealer_waiting_screen.dart';

class DealerBookingScreen extends StatefulWidget {
  const DealerBookingScreen({super.key});

  @override
  State<DealerBookingScreen> createState() => _DealerBookingScreenState();
}

class _DealerBookingScreenState extends State<DealerBookingScreen> {
  final _amountController = TextEditingController();
  String? selectedSlot;

  final slotAvailability = {
    "08:30 - 09:00": 0,
    "09:00 - 09:30": 2,
    "09:30 - 10:00": 1,
    "10:00 - 10:30": 3,
  };

  void submitBooking() {
    final amount = int.tryParse(_amountController.text) ?? 0;

    if (amount < 80000) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DealerWaitingScreen()),
      );
      return;
    }

    if (selectedSlot == null) {
      _msg("Please select a slot");
      return;
    }

    if (slotAvailability[selectedSlot]! > 0) {
      slotAvailability[selectedSlot!] = slotAvailability[selectedSlot!]! - 1;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DealerBookingDetailScreen(
            bookingId: "BK123",
            amount: amount,
            slot: selectedSlot!,
            vehicle: "TN03 EF 1111",
            tripNo: 2,
          ),
        ),
      );
    } else {
      _showSuggestions();
    }
  }

  void _showSuggestions() {
    final available = slotAvailability.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Slot Not Available"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: available.map((s) => Text("• $s")).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final amount = int.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Book Slot")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter Amount"),
              onChanged: (_) => setState(() => selectedSlot = null),
            ),

            const SizedBox(height: 20),

            if (amount >= 80000) ...[
              const Text(
                "Select Slot Timing",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              /// ✅ NEW: RadioGroup
              RadioGroup<String>(
                groupValue: selectedSlot,
                onChanged: (value) {
                  setState(() => selectedSlot = value);
                },
                child: Column(
                  children: slotAvailability.keys
                      .map(
                        (slot) => RadioListTile<String>(
                          title: Text(slot),
                          subtitle: Text(
                            slotAvailability[slot]! > 0
                                ? "Available"
                                : "Not Available",
                            style: TextStyle(
                              color: slotAvailability[slot]! > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          value: slot,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitBooking,
                child: const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
