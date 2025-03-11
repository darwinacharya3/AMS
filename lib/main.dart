import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/enrollment/enrollment_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ems/screens/sign_in/signin_screen.dart';

void main() {
  runApp(
    
     ProviderScope(
      child: EMSApp(),
    ),
  );
}

class EMSApp extends StatelessWidget {
  const EMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EMS Enrollment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EnrollmentScreen(),
    );
  }
}







