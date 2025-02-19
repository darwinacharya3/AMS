import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ems/screens/home/dashboard_screen.dart';
import 'package:ems/widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_app_bar.dart';
import 'package:ems/widgets/custom_navigation.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({Key? key}) : super(key: key);

   Future<bool> _onWillPop() async {
    if (Get.previousRoute.isNotEmpty) {
      // Get.back();
      Get.to(()=>DashboardScreen());
      return false;
    }
    // If no previous route, let the system handle the back button
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Create Tickets',
          icon: Icons.add_circle_outline,
          showBackButton: true,  // Explicitly show back button
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Create Ticket',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context);
          },
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creating Tickets',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Add attendance-specific content here
            ],
          ),
        ),
      ),
    );
  }
}
