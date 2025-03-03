import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ems/controller/career_controller.dart';
import 'package:ems/screens/home/dashboard_screen.dart';
import 'package:ems/widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_app_bar.dart';
import 'package:ems/widgets/custom_navigation.dart';

class CareerScreen extends ConsumerWidget {
  const CareerScreen({super.key});

  // Handle back button behavior
  Future<bool> _onWillPop(BuildContext context, CareerController controller) async {
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
    final controller = ref.watch(careerControllerProvider.notifier);
    final webViewController = ref.watch(careerControllerProvider);

    return WillPopScope(
      onWillPop: () => _onWillPop(context, controller),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Career',
          icon: Icons.work,
          showBackButton: true,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Career',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context);
          },
        ),
        body: WebViewWidget(controller: webViewController),
      ),
    );
  }
}


















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';

// class CareerScreen extends StatelessWidget {
//   const CareerScreen({Key? key}) : super(key: key);

//    Future<bool> _onWillPop() async {
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
//           title: 'Career',
//           icon: Icons.work,
//           showBackButton: true,  // Explicitly show back button
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Career',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Career Overview',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add attendance-specific content here
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
