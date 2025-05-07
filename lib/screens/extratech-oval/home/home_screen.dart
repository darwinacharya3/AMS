import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExtratechOvalScreen extends StatefulWidget {
  const ExtratechOvalScreen({Key? key}) : super(key: key);

  @override
  State<ExtratechOvalScreen> createState() => _ExtratechOvalScreenState();
}

class _ExtratechOvalScreenState extends State<ExtratechOvalScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://portal.extratechoval.com/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Extratech Oval',
          style: TextStyle(
            color: Color(0xFFE9008D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFE9008D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9008D)),
              ),
            ),
        ],
      ),
    );
  }
}