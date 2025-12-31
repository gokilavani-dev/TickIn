import 'package:flutter/material.dart';
import '../api/real/slot_api.dart';
import '../api/real/auth_api.dart';

class SlotBookingScreen extends StatefulWidget {
  const SlotBookingScreen({super.key});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  bool loading = true;

  List<Map<String, dynamic>> slots = [];
  int? selectedIndex;

  String? bookingId;
  String? distributorName;
  String? distributorZone;
  String? distributorCode;

  int totalAmount = 0;
  DateTime selectedDate = DateTime.now();

  final TextEditingController amountCtrl = TextEditingController();
  final int fullTruckLimit = 80000;

  /* ===============================
     ROLE HELPERS
  =============================== */
  bool get isManager => AuthApi.user?["role"] == "MANAGER";
  bool get isDistributor => AuthApi.user?["role"] == "DISTRIBUTOR";

  bool get isBookingMode => bookingId != null && bookingId!.isNotEmpty;
  bool get showDistributorName => isBookingMode && !isDistributor;

  bool get isFullTruck => totalAmount >= fullTruckLimit;

  String get companyCode => AuthApi.user?["companyId"] ?? "";

  bool get isAfter5PM => DateTime.now().hour >= 17;

  /* ===============================
     INIT
  =============================== */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    debugPrint("SLOT BOOKING ARGS => $args"); // 👈 ADD THIS

    bookingId = args?["bookingId"];
    distributorName = args?["distributorName"];
    distributorZone = args?["distributorZone"];
    distributorCode = args?["distributorCode"];
    totalAmount = (args?["amount"] as num?)?.round() ?? 0;

    amountCtrl.text = totalAmount.toString();
    debugPrint("distributorCode => $distributorCode"); // 👈 ADD THIS
  }

  @override
  void initState() {
    super.initState();
    fetchSlots();
  }

  /* ===============================
     FETCH SLOTS
  =============================== */
  Future<void> fetchSlots() async {
    final dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final res = await SlotApi.getSlots(companyCode: companyCode, date: dateStr);
    final allSlots = List<Map<String, dynamic>>.from(res);

    // ✅ AFTER 5 PM RULE
    if (!isManager && !isAfter5PM) {
      slots = allSlots.take(12).toList();
    } else if (!isManager && isAfter5PM) {
      final lastSlotOpened = allSlots.any(
        (s) => s["time"] == "20:30" && s["status"] == "AVAILABLE",
      );
      slots = lastSlotOpened ? allSlots : allSlots.take(12).toList();
    } else {
      slots = allSlots; // manager always sees all
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  /* ===============================
     SLOT COLOR
  =============================== */
  Color slotColor(Map s, bool selected) {
    if (s["status"] == "BOOKED") return Colors.grey.shade300;
    if (selected) return Colors.blue.shade300;
    return Colors.green.shade200;
  }

  /* ===============================
     BOOK SLOT (SAFE)
  =============================== */
  Future<void> bookSelectedSlot() async {
    if (!isBookingMode || selectedIndex == null) return;

    if (distributorCode == null || distributorCode!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Distributor not found")));
      return;
    }

    final slot = slots[selectedIndex!];
    debugPrint(
      "BOOK SLOT PAYLOAD => "
      "companyCode=$companyCode, "
      "date=$selectedDate, "
      "time=${slot["time"]}, "
      "vehicleType=${isFullTruck ? "FULL" : "HALF"}, "
      "pos=${slot["pos"]}, "
      "distributorCode=$distributorCode, "
      "amount=$totalAmount",
    );
    await SlotApi.bookSlot(
      companyCode: companyCode,
      date: "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
      time: slot["time"],
      vehicleType: isFullTruck ? "FULL" : "HALF",
      pos: slot["pos"],
      distributorCode: distributorCode!,
      amount: totalAmount,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _openManagerSlotActions(Map<String, dynamic> slot) async {
    final TextEditingController maxAmountCtrl = TextEditingController(
      text: (slot["maxAmount"] ?? slot["max_amount"] ?? "").toString(),
    );

    // time edit controls
    String currentTime = (slot["time"] ?? "").toString();
    String editedTime = currentTime;

    bool doDelete = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Manager Slot Actions (${slot["time"]})",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // ✅ 1) MaxAmount / Full truck amount override (one textbox)
              TextField(
                controller: maxAmountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Slot Max Amount (override)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ 2) Edit timing (simple dropdown or custom picker)
              DropdownButtonFormField<String>(
                initialValue: editedTime,
                items: slots
                    .map((s) => (s["time"] ?? "").toString())
                    .toSet()
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) editedTime = v;
                },
                decoration: const InputDecoration(
                  labelText: "Edit Slot Time",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ 3) Delete slot toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Delete / Disable this slot"),
                value: doDelete,
                onChanged: (v) {
                  doDelete = v;
                  (ctx as Element).markNeedsBuild();
                },
              ),

              const SizedBox(height: 12),

              // ✅ Save -> DB alter -> refresh -> reflect all
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Save"),
                  onPressed: () async {
                    try {
                      final maxAmt = int.tryParse(maxAmountCtrl.text.trim());

                      // ✅ A) set-max (optional)
                      if (maxAmt != null && maxAmt > 0) {
                        await SlotApi.managerSetSlotMax(
                          companyCode: companyCode,
                          date: _fmtDate(selectedDate),
                          time: currentTime,
                          location:
                              slot["location"] ?? slot["loc"] ?? "DEFAULT",
                          maxAmount: maxAmt,
                        );
                      }

                      // ✅ B) edit time (only if changed)
                      if (editedTime != currentTime) {
                        await SlotApi.managerEditSlotTime(
                          companyCode: companyCode,
                          date: _fmtDate(selectedDate),
                          oldTime: currentTime,
                          newTime: editedTime,
                          location:
                              slot["location"] ?? slot["loc"] ?? "DEFAULT",
                        );
                      }

                      // ✅ C) delete/disable slot
                      if (doDelete) {
                        await SlotApi.managerDeleteSlot(
                          companyCode: companyCode,
                          date: _fmtDate(selectedDate),
                          time: currentTime,
                          location:
                              slot["location"] ?? slot["loc"] ?? "DEFAULT",
                        );
                      }

                      if (!mounted) return;
                      Navigator.pop(ctx);
                      setState(() => loading = true);
                      await fetchSlots(); // ✅ refresh -> everyone sees updated grid
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Save failed: $e")),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  /* ===============================
     UI
  =============================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Slot Booking")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  if (showDistributorName && distributorName != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        distributorName!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  if (isBookingMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: amountCtrl,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                  if (isBookingMode)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        isFullTruck ? "FULL TRUCK" : "HALF TRUCK",
                        style: TextStyle(
                          color: isFullTruck ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legend(Colors.green.shade200, "Available"),
                        const SizedBox(width: 12),
                        _legend(Colors.grey.shade300, "Booked"),
                      ],
                    ),
                  ),

                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: slots.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (_, i) {
                        final slot = slots[i];
                        final selected = selectedIndex == i;

                        return GestureDetector(
                          onTap: slot["status"] == "BOOKED"
                              ? null
                              : () => setState(() => selectedIndex = i),

                          // ✅ ADD ONLY: Manager long press actions
                          onLongPress: !isManager
                              ? null
                              : () => _openManagerSlotActions(slot),

                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: slotColor(slot, selected),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slot["time"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  slot["status"] == "BOOKED"
                                      ? "Booked"
                                      : "Available",
                                  style: TextStyle(
                                    color: slot["status"] == "BOOKED"
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (isBookingMode)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Book Now"),
                          onPressed: selectedIndex == null
                              ? null
                              : bookSelectedSlot,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
