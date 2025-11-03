import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/tracker_home.dart';

void main() {
  runApp(FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FinanceTrackerHome(),
    );
  }
}