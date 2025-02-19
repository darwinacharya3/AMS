import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ems/screens/home/attendance_screen.dart';
import 'package:ems/screens/home/career_screen.dart';
import 'package:ems/screens/home/quiz_screen.dart';
import 'package:ems/screens/material/material_screen.dart';
import 'package:ems/screens/zoom_link/zoom_link_screen.dart';
import 'package:ems/screens/tickets/all_tickets_screen.dart';
import 'package:ems/screens/tickets/completed_tickets_screen.dart';
import 'package:ems/screens/tickets/create_ticket_screen.dart';
import 'package:ems/screens/enrollment/enrollment_screen.dart';
import 'package:ems/screens/home/dashboard_screen.dart';

class CustomNavigation {
  static void navigateToScreen(String item, BuildContext context) {
    // Close drawer first
    Navigator.of(context).pop();
    
    // Add small delay to ensure drawer is closed before navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (item) {
        case 'General':
          Get.to(() => const DashboardScreen(), transition: Transition.rightToLeft);
          break;
        case 'Attendance':
          Get.to(() => const AttendanceScreen(), transition: Transition.rightToLeft);
          break;
        case 'Quiz':
          Get.to(() => const QuizScreen(), transition: Transition.rightToLeft);
          break;
        case 'Career':
          Get.to(() => const CareerScreen(), transition: Transition.rightToLeft);
          break;
        case 'Materials':
          Get.to(() => const MaterialsScreen(), transition: Transition.rightToLeft);
          break;
        case 'Zoom Links':
          Get.to(() => const ZoomLinksScreen(), transition: Transition.rightToLeft);
          break;
        case 'Create Ticket':
          Get.to(() => const CreateTicketScreen(), transition: Transition.rightToLeft);
          break;
        case 'All Tickets':
          Get.to(() => const AllTicketsScreen(), transition: Transition.rightToLeft);
          break;
        case 'Completed Tickets':
          Get.to(() => const CompletedTicketsScreen(), transition: Transition.rightToLeft);
          break;
        case 'Logout':
          Get.offAll(() => const EnrollmentScreen(), transition: Transition.fade);
          break;
      }
    });
  }
}
