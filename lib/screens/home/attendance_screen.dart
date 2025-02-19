import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ems/screens/home/dashboard_screen.dart';
import 'package:ems/widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_app_bar.dart';
import 'package:ems/widgets/custom_navigation.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

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
          title: 'Attendance',
          icon: Icons.calendar_today,
          showBackButton: true,  // Explicitly show back button
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Attendance',
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
                'Attendance Overview',
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












// // lib/screens/home/attendance_screen.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';

// class AttendanceScreen extends StatelessWidget {
//   const AttendanceScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Attendance',
//         icon: Icons.calendar_today,
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: 'Attendance',
//         onItemSelected: (String item) {
//           CustomNavigation.navigateToScreen(item, context);
//         },
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Attendance Overview',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Add attendance-specific content here
//           ],
//         ),
//       ),
//     );
//   }
// }

















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';

// class AttendanceScreen extends StatelessWidget {
//   const AttendanceScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Attendance',
//         icon: Icons.calendar_today, // Changed icon to match attendance context
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: 'Attendance',
//         onItemSelected: (String item) {
//           // Your existing navigation logic here
//         },
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Attendance Overview',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Add your attendance-specific content here
//           ],
//         ),
//       ),
//     );
//   }
// }