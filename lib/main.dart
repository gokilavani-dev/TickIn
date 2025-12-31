import 'package:book_yours/screens/manager/manager_dashboard_screen.dart';
import 'package:book_yours/screens/master/master_dashboard_screen.dart'
    show MasterDashboardScreen;
import 'package:book_yours/screens/sales_officer/sales_edit_draft_order_screen.dart';
import 'package:flutter/material.dart';

// 🔹 AUTH / COMMON
import 'screens/login_screen.dart';
import 'screens/booking/booking_history_screen.dart';
import 'screens/slot_booking_screen.dart';

// 🔹 SALES
import 'screens/sales_officer/sales_officer_home_screen.dart';
import 'screens/sales_officer/sales_create_order_screen.dart';
import 'screens/sales_officer/sales_confirmed_orders_screen.dart';
import 'screens/sales_officer/order_detail_screen.dart';
import 'screens/sales_officer/sales_draft_orders_screen.dart';
import 'screens/sales_officer/sales_draft_detail_screen.dart';
import 'screens/sales_officer/order_success_screen.dart';

// 🔹 MANAGER
import 'screens/manager/manager_home_screen.dart';
import 'screens/manager/manager_slot_config_screen.dart';

// 🔹 OTHER ROLES
import 'screens/distributor/distributor_home_screen.dart';
import 'screens/driver/driverhomescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Slot Booking System',

      // ✅ Login is entry point
      home: const LoginScreen(),

      routes: {
        // =========================
        // AUTH / TEMP
        // =========================
        "/home": (context) => const HomeScreen(),

        // =========================
        // SALES OFFICER
        // =========================
        "/sales": (_) => const SalesOfficerHomeScreen(),
        "/sales/create-order": (_) => const SalesCreateOrderScreen(),
        "/sales/my-orders": (_) => const SalesConfirmedOrdersScreen(),

        // =========================
        // SALES – DRAFT FLOW
        // =========================
        "/sales/drafts": (_) => const SalesDraftOrdersScreen(),
        "/sales/draft-detail": (_) => const SalesDraftDetailScreen(),
        "/sales/edit-draft": (_) => const SalesEditDraftOrderScreen(),

        // =========================
        // ORDER SUCCESS
        // =========================
        "/order-success": (_) => const OrderSuccessScreen(),

        // =========================
        // MANAGER
        // =========================
        "/manager-home": (context) => const ManagerHomeScreen(),
        // manager uses SAME order list screen
        "/manager/orders": (_) => const SalesConfirmedOrdersScreen(),
        "/slot-config": (context) => const ManagerSlotConfigScreen(slot: {}),
        "/manager/dashboard": (context) => ManagerDashboardScreen(),
        // =========================
        // COMMON (IMPORTANT)
        // =========================
        "/order-detail": (_) => const OrderDetailScreen(),
        "/slot-booking": (context) => const SlotBookingScreen(),
        "/booking-history": (_) => const BookingHistoryScreen(),

        // =========================
        // OTHER ROLES
        // =========================
        "/distributor-home": (context) => const DistributorHomeScreen(),
        "/driver": (context) => const DriverHomeScreen(),

        "/master": (context) => const MasterDashboardScreen(),
      },

      theme: ThemeData(
        primaryColor: const Color(0xFF2F80ED),
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        useMaterial3: false,
      ),
    );
  }
}

/// 🔹 TEMP HOME SCREEN (login success apram)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFF2F80ED),
      ),
      body: const Center(
        child: Text("Login Successful ✅", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
