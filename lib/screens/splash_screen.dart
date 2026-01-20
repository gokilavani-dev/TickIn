import 'package:flutter/material.dart';
import '../constants/textstyles.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Expense Tracker', style: AppTextStyles.headline),
      ),
    );
  }
}
