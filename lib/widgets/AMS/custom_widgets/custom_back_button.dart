import 'package:ems/screens/AMS/home/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;

  const CustomBackButton({
    super.key,
    this.iconColor = const Color.fromARGB(255, 227, 10, 169),
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.all(8.0),
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: iconColor,
        iconSize: iconSize!,
        onPressed: onPressed ?? () {
          // Default behavior using GetX navigation
          // Get.back();
          Get.to(()=>const DashboardScreen());
        },
      ),
    );
  }
}