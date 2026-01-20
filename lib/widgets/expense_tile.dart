import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../constants/textstyles.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;

  const ExpenseTile({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.title, style: AppTextStyles.title),
      subtitle: Text(expense.category, style: AppTextStyles.body),
      trailing: Text(
        '\$${expense.amount.toStringAsFixed(2)}',
        style: AppTextStyles.title,
      ),
    );
  }
}
