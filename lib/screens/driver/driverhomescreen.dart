import 'package:book_yours/api/real/auth_api.dart';
import 'package:flutter/material.dart';
import '../../api/real/driver_api.dart';
//import '../../api/real/auth_api.dart';

class DriverOrdersScreen extends StatefulWidget {
  const DriverOrdersScreen({super.key});

  @override
  State<DriverOrdersScreen> createState() => _DriverOrdersScreenState();
}

class _DriverOrdersScreenState extends State<DriverOrdersScreen> {
  bool loading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    orders = await DriverApi.getOrders();
    setState(() => loading = false);
  }

  Future<void> updateStatus(String orderId, String status) async {
    await DriverApi.updateStatus(orderId, status);
    await loadOrders(); // 🔁 refresh same screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final o = orders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order ${o["orderId"]}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("Vehicle: ${o["vehicleNo"] ?? "-"}"),
                        Text("Status: ${o["status"]}"),
                        const Divider(),

                        /// 🔘 ACTION BUTTONS
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (o["status"] == "DRIVER_ASSIGNED")
                              _btn(
                                "Start Trip",
                                () => updateStatus(
                                  o["orderId"],
                                  "DRIVER_STARTED",
                                ),
                              ),

                            if (o["status"] == "DRIVER_STARTED")
                              _btn(
                                "Reached Distributor",
                                () => updateStatus(
                                  o["orderId"],
                                  "DRIVER_REACHED_DISTRIBUTOR",
                                ),
                              ),

                            if (o["status"] == "DRIVER_REACHED_DISTRIBUTOR")
                              _btn(
                                "Reached Warehouse",
                                () => updateStatus(
                                  o["orderId"],
                                  "WAREHOUSE_REACHED",
                                ),
                              ),

                            if (o["status"] == "WAREHOUSE_REACHED")
                              _btn(
                                "Unload Start",
                                () =>
                                    updateStatus(o["orderId"], "UNLOAD_START"),
                              ),

                            if (o["status"] == "UNLOAD_START")
                              _btn(
                                "Unload End",
                                () => updateStatus(o["orderId"], "UNLOAD_END"),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _btn(String text, VoidCallback onTap) {
    return ElevatedButton(onPressed: onTap, child: Text(text));
  }
}
