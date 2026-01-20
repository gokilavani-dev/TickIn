import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/textstyles.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/lottie/splash.json', width: 160, height: 160),
            const SizedBox(height: 16),
            const Text('Expense Tracker', style: AppTextStyles.headline),
          ],
        ),
      ),
    );
  }
}
