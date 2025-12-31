import 'package:flutter/material.dart';

class ManagerSlotConfigScreen extends StatefulWidget {
  final Map<String, dynamic> slot;

  const ManagerSlotConfigScreen({super.key, required this.slot});

  @override
  State<ManagerSlotConfigScreen> createState() =>
      _ManagerSlotConfigScreenState();
}

class _ManagerSlotConfigScreenState extends State<ManagerSlotConfigScreen> {
  late bool isAvailable;
  late String vehicleType;

  @override
  void initState() {
    super.initState();
    isAvailable = widget.slot["booked"] != true;
    vehicleType = widget.slot["vehicleType"] ?? "FULL";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Slot")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Slot Time : ${widget.slot["time"]}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: vehicleType,
              decoration: const InputDecoration(
                labelText: "Vehicle Type",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "FULL", child: Text("FULL Truck")),
                DropdownMenuItem(value: "HALF", child: Text("HALF Truck")),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => vehicleType = v);
              },
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text("Slot Available"),
              value: isAvailable,
              onChanged: (v) {
                setState(() => isAvailable = v);
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 🔴 TEMP ONLY — backend later
                  Navigator.pop(context, {
                    "vehicleType": vehicleType,
                    "available": isAvailable,
                  });
                },
                child: const Text("Save Changes"),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.slot["booked"] = false;
                Navigator.pop(context);
              },
              child: const Text("Delete Slot"),
            ),
          ],
        ),
      ),
    );
  }
}
