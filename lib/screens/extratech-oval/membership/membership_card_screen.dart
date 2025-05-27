import 'package:flutter/material.dart';
import 'package:ems/widgets/Extratech 0val/membership/membership_form_widget.dart';


class MembershipCardScreen extends StatelessWidget {
  const MembershipCardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Application'),
        backgroundColor: const Color(0xFF205EB5),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA1C7FF), // 0%
              Color(0xFFC4DCFF), // 11%
              Color(0xFFDBE7FE), // 23%
              Color(0xFFFEF9FC), // 41%
              Color(0xFFFFF4FB), // 74%
              Color(0xFFFDE8F5), // 100%
            ],
            stops: [0.0, 0.11, 0.23, 0.41, 0.74, 1.0],
          ),
        ),
        child: const SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: MembershipFormWidget(),
            ),
          ),
        ),
      ),
    );
  }
}