import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ems/controller/attendance_controller.dart';
import 'package:ems/screens/home/dashboard_screen.dart';
import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/custom_widgets/custom_navigation.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  // Handle back button behavior
  Future<bool> _onWillPop(BuildContext context, AttendanceController controller) async {
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
    final controller = ref.watch(attendanceControllerProvider.notifier);
    final webViewController = ref.watch(attendanceControllerProvider);

    return WillPopScope(
      onWillPop: () => _onWillPop(context, controller),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Attendance',
          icon: Icons.calendar_today,
          showBackButton: true,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Attendance',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context,);
          },
        ),
        body: Stack(
  children: [
    // White background that will show while content loads
    Container(
      color: Colors.white,
    ),
    
    // WebView on top of the white background
    WebViewWidget(controller: webViewController),
    
    // Loading indicator that displays until page is fully loaded
    // Consumer(
    //   builder: (context, ref, child) {
    //     final isLoading = ref.watch(attendanceControllerProvider.select(
    //       (controller) => controller.isLoading,
    //     ));
        
    //     return isLoading 
    //       ? const Center(child: CircularProgressIndicator())
    //       : const SizedBox.shrink();
    //   },
    // ),
  ],
),
    ),);
  }
}











