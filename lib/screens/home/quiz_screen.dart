import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ems/controller/quiz_controller.dart';
import 'package:ems/screens/home/dashboard_screen.dart';
import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/custom_widgets/custom_navigation.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  // Handle back button behavior
  Future<bool> _onWillPop(BuildContext context, QuizController controller) async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(quizControllerProvider.notifier);
    final webViewController = ref.watch(quizControllerProvider);

    return WillPopScope(
      onWillPop: () => _onWillPop(context, controller),
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
        body: WebViewWidget(controller: webViewController),
      ),
    );
  }
}













// // lib/screens/home/quiz_screen.dart
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_navigation.dart';


// class QuizScreen extends StatelessWidget {
//   const QuizScreen({Key? key}) : super(key: key);

//   Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       // Get.back();
//       Get.to(()=>DashboardScreen());
//       return false;
//     }
//     // If no previous route, let the system handle the back button
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Quiz',
//           icon: Icons.quiz,
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Quiz',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Available Quizzes',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Add quiz content here
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }












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