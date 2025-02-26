import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AttendanceController extends StateNotifier<WebViewController> {
  AttendanceController() : super(WebViewController()) {
    // Using a local variable for clarity
    final controller = state;
    
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) async {
          // Hide the navigation bar if it exists
          await controller.runJavaScript(
            "document.querySelector('nav')?.style.display = 'none';"
          );
          // Click the "Attendance" tab by ID
          await controller.runJavaScript(
            "document.getElementById('nav-profile-tab')?.click();"
          );
        },
      ),
    );
    controller.loadRequest(Uri.parse('https://extratech.extratechweb.com/student'));
  }

  Future<bool> canGoBack() async {
    return await state.canGoBack();
  }

  void goBack() {
    state.goBack();
  }
}

final attendanceControllerProvider = StateNotifierProvider<AttendanceController, WebViewController>((ref) {
  return AttendanceController();
});
