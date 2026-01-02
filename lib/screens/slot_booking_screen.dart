import 'package:flutter/material.dart';
import '../api/real/slot_api.dart';
import '../api/real/auth_api.dart';

class SlotBookingScreen extends StatefulWidget {
  const SlotBookingScreen({super.key});

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  String? bookedType;

  final TextEditingController globalAmountCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  bool loading = true;

  List<Map<String, dynamic>> slots = [];

  // ❌ OLD – index based (kept fully)
  int? selectedIndex;

  // ✅ ADD – safe slot key selection (no old logic removed)
  String? selectedSlotSk;

  String? bookingId;
  String? distributorName;
  String? distributorZone;
  String? distributorCode;

  int totalAmount = 0;
  DateTime selectedDate = DateTime.now();

  /* ===============================
     ROLE HELPERS
  =============================== */
  bool get isManager => AuthApi.user?["role"] == "MANAGER";
  bool get isDistributor => AuthApi.user?["role"] == "DISTRIBUTOR";

  bool get isAfter5PM => DateTime.now().hour >= 17;

  /// booking mode only if came from order
  bool get isBookingMode =>
      bookingId != null &&
      bookingId!.isNotEmpty &&
      distributorCode != null &&
      distributorCode!.isNotEmpty &&
      totalAmount > 0;

  bool get showDistributorName => isBookingMode && !isDistributor;

  String get companyCode => AuthApi.user?["companyId"] ?? "";

  /* ===============================
     INIT
  =============================== */
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    debugPrint("SLOT BOOKING ARGS => $args");

    bookingId = args?["bookingId"];
    distributorName = args?["distributorName"];
    distributorZone = args?["distributorZone"];
    distributorCode = args?["distributorCode"];
    totalAmount = (args?["amount"] as num?)?.round() ?? 0;

    amountCtrl.text = totalAmount.toString();
  }

  @override
  void initState() {
    super.initState();
    fetchSlots();
  }

  /* ===============================
     FETCH SLOTS (OLD RULE – UNTOUCHED)
  =============================== */
  Future<void> fetchSlots() async {
    final dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final res = await SlotApi.getSlots(companyCode: companyCode, date: dateStr);
    final allSlots = List<Map<String, dynamic>>.from(res);

    if (isManager) {
      slots = allSlots;
    } else {
      if (!isAfter5PM) {
        slots = allSlots.take(12).toList();
      } else {
        final lastSlotAvailable = allSlots.any(
          (s) => s["time"] == "20:30" && s["status"] == "AVAILABLE",
        );
        slots = lastSlotAvailable ? allSlots : allSlots.take(12).toList();
      }
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        loading = true;
        selectedIndex = null;

        // ✅ ADD – reset safe selection also
        selectedSlotSk = null;
      });

      await fetchSlots();
    }
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
     BOOK SLOT (OLD LOGIC + SAFE ADD)
  =============================== */
  Future<void> bookSelectedSlot() async {
    if (!isBookingMode || selectedIndex == null) return;

    // ✅ ADD – prefer slotSk if available, else fallback to index
    final slot = selectedSlotSk != null
        ? slots.firstWhere((s) => s["sk"] == selectedSlotSk)
        : slots[selectedIndex!];

    final res = await SlotApi.bookSlot(
      companyCode: companyCode,
      date: _fmtDate(selectedDate),
      time: slot["time"],
      pos: slot["pos"],
      distributorCode: distributorCode!,
      amount: totalAmount,
    );
    setState(() {
      bookedType = res["type"]; // FULL or HALF (backend truth)
    });
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  /* ===============================
     MANAGER SLOT ACTIONS (OLD – UNTOUCHED)
  =============================== */
  Future<void> _openManagerSlotActions(Map<String, dynamic> slot) async {
    String currentTime = (slot["time"] ?? "").toString();
    String editedTime = currentTime;
    bool doDelete = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Manager Slot Actions ($currentTime)",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

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

                SwitchListTile(
                  title: const Text("Delete / Disable slot"),
                  value: doDelete,
                  onChanged: (v) {
                    doDelete = v;
                    (ctx as Element).markNeedsBuild();
                  },
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text("Save"),
                    onPressed: () async {
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

                      if (doDelete) {
                        await SlotApi.managerDeleteSlot(
                          companyCode: companyCode,
                          date: _fmtDate(selectedDate),
                          time: currentTime,
                          location:
                              slot["location"] ?? slot["loc"] ?? "DEFAULT",
                        );
                      }

                      Navigator.pop(ctx);
                      setState(() => loading = true);
                      await fetchSlots();
                    },
                  ),
                ),
              ],
            ),
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
      appBar: AppBar(
        title: const Text("Slot Booking"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (isManager && !isBookingMode)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: globalAmountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Global Slot Max Amount",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final amt = int.tryParse(
                              globalAmountCtrl.text.trim(),
                            );
                            if (amt == null || amt <= 0) return;

                            await SlotApi.managerSetSlotMax(
                              companyCode: companyCode,
                              date: _fmtDate(selectedDate),
                              time: "ALL",
                              location: "DEFAULT",
                              maxAmount: amt,
                            );

                            setState(() => loading = true);
                            await fetchSlots();
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                  ),

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
                      bookedType == "FULL" ? "FULL TRUCK" : "HALF TRUCK",
                      style: TextStyle(
                        color: bookedType == "FULL"
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
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
                            : () => setState(() {
                                selectedIndex = i;

                                // ✅ ADD – capture slotSk also
                                selectedSlotSk = slot["sk"];
                              }),
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
                      child: ElevatedButton(
                        onPressed: selectedIndex == null
                            ? null
                            : bookSelectedSlot,
                        child: const Text("Book Now"),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
