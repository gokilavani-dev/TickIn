import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/add_expense_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/transactions_screen.dart';
import 'state/expense_provider.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
        ),
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          TransactionsScreen.routeName: (_) => const TransactionsScreen(),
          StatsScreen.routeName: (_) => const StatsScreen(),
          AddExpenseScreen.routeName: (_) => const AddExpenseScreen(),
        },
      ),
    );
  }
}
