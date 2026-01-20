import 'package:flutter/material.dart';
import '../constants/textstyles.dart';

class AddExpenseScreen extends StatelessWidget {
  static const String routeName = '/add-expense';

  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Expense', style: AppTextStyles.title),
      ),
    );
  }
}
