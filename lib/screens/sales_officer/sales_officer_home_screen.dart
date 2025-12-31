import 'package:book_yours/api/real/auth_api.dart';
import 'package:flutter/material.dart';
import '../../api/real/order_api.dart';

class SalesOfficerHomeScreen extends StatefulWidget {
  const SalesOfficerHomeScreen({super.key});

  @override
  State<SalesOfficerHomeScreen> createState() => _SalesOfficerHomeScreenState();
}

class _SalesOfficerHomeScreenState extends State<SalesOfficerHomeScreen> {
  int confirmedCount = 0;
  int draftCount = 0;

  @override
  void initState() {
    super.initState();
    loadCounts();
  }

  /* ===============================
     LOAD COUNTS (BADGES)
  =============================== */
  Future<void> loadCounts() async {
    try {
      final confirmed = await OrderApi.getMyOrders();
      final drafts = await OrderApi.getMyDraftOrders();

      if (!mounted) return;
      setState(() {
        confirmedCount = confirmed.length;
        draftCount = drafts.length;
      });
    } catch (_) {
      // silent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Officer"),
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

      /* ===============================
         MANAGER-STYLE CARD LAYOUT
      =============================== */
      body: RefreshIndicator(
        onRefresh: loadCounts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            /// CREATE ORDER
            _dashboardCard(
              icon: Icons.add_shopping_cart,
              title: "Create Order",
              subtitle: "Create new draft order",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/sales/create-order",
                ).then((_) => loadCounts());
              },
            ),

            /// DRAFT ORDERS
            _dashboardCard(
              icon: Icons.edit_note,
              title: "Draft Orders",
              subtitle: "Edit & confirm draft orders",
              badge: draftCount,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/sales/drafts",
                ).then((_) => loadCounts());
              },
            ),

            /// CONFIRMED ORDERS
            _dashboardCard(
              icon: Icons.list_alt,
              title: "My Orders",
              subtitle: "Confirmed orders",
              badge: confirmedCount,
              onTap: () {
                Navigator.pushNamed(context, "/sales/my-orders");
              },
            ),

            /// HISTORY
            _dashboardCard(
              icon: Icons.history,
              title: "Booking History",
              subtitle: "Past booking history",
              onTap: () {
                Navigator.pushNamed(context, "/booking-history");
              },
            ),
          ],
        ),
      ),
    );
  }

  /* ===============================
     DASHBOARD CARD (MANAGER STYLE)
  =============================== */
  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(icon, size: 32),
            if (badge > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
