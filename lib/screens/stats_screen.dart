import 'package:flutter/material.dart';
import '../constants/textstyles.dart';

class StatsScreen extends StatelessWidget {
  static const String routeName = '/stats';

  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Stats', style: AppTextStyles.title),
    );
  }
}
