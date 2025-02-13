import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'loading_indicator.dart';
import 'error_display.dart';

class WebViewContainer extends StatelessWidget {
  final WebViewController controller;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRetry;

  const WebViewContainer({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (isLoading) const LoadingIndicator(),
        if (errorMessage.isNotEmpty)
          ErrorDisplay(
            message: errorMessage,
            onRetry: onRetry,
          ),
      ],
    );
  }
}