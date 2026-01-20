import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/textstyles.dart';

class TransactionsScreen extends StatelessWidget {
  static const String routeName = '/transactions';

  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/lottie/empty.json', width: 160, height: 160),
          const SizedBox(height: 16),
          const Text('Transactions', style: AppTextStyles.title),
        ],
      ),
    );
  }
}
