import 'package:flutter/material.dart';
import 'screens/enrollment/enrollment_screen.dart';

void main() {
  runApp(const EMSApp());
}

class EMSApp extends StatelessWidget {
  const EMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EMS Enrollment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const EnrollmentScreen(),
    );
  }
}







