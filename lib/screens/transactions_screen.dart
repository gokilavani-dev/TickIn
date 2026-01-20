import 'package:flutter/material.dart';
import '../constants/textstyles.dart';

class TransactionsScreen extends StatelessWidget {
  static const String routeName = '/transactions';

  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Transactions', style: AppTextStyles.title),
    );
  }
}
