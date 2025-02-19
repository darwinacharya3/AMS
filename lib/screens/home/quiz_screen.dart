// lib/screens/home/quiz_screen.dart
import 'package:ems/screens/home/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ems/widgets/custom_app_bar.dart';
import 'package:ems/widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_navigation.dart';


class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

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
          title: 'Quiz',
          icon: Icons.quiz,
          showBackButton: true,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Quiz',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context);
          },
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Quizzes',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Add quiz content here
              ],
            ),
          ),
        ),
      ),
    );
  }
}












// class QuizScreen extends StatelessWidget {
//   const QuizScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Quiz',
//         icon: Icons.quiz,
//         showBackButton: true,
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: 'Quiz',
//         onItemSelected: (String item) {
//           CustomNavigation.navigateToScreen(item, context);
//         },
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Available Quizzes',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add quiz content here
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';

// class QuizScreen extends StatelessWidget {
//   const QuizScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Quiz',
//         icon: Icons.quiz, // Changed icon to match quiz context
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: 'Quiz',
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
//               'Available Quizzes',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Add your quiz-specific content here
//           ],
//         ),
//       ),
//     );
//   }
// }