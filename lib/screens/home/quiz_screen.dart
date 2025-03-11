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

   return PopScope(
  canPop: false,
  onPopInvoked: (didPop) {
    if (didPop) return;
    _onWillPop(context, controller);
  },
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









