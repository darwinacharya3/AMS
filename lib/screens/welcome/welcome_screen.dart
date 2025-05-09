import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ems/screens/AMS/enrollment/enrollment_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Row(
          children: [
            // Empty row as requested
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildServicesSection(),
          Expanded(
            child: _buildServicesGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Extratech',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Please select a service to continue',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        physics: BouncingScrollPhysics(),
        children: [
          _buildServiceItem(
            context: context,
            icon: Icons.school,
            title: 'Student',
            onTap: () => _navigateToStudentScreen(context),
          ),
          _buildServiceItem(
            context: context,
            icon: Icons.business,
            title: 'Extratech Oval',
            onTap: () => _showComingSoonMessage(context),
          ),
          _buildServiceItem(
            context: context,
            icon: Icons.dashboard,
            title: 'Ticketing',
            onTap: () => _showComingSoonMessage(context),
          ),
          _buildServiceItem(
            context: context,
            icon: Icons.contact_support,
            title: 'Support',
            onTap: () => _showComingSoonMessage(context),
          ),
          _buildServiceItem(
            context: context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => _showComingSoonMessage(context),
          ),
          _buildServiceItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => _showComingSoonMessage(context),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToStudentScreen(BuildContext context) async {
    // Add a small delay to show the tap effect before navigation
    await Future.delayed(Duration(milliseconds: 150));
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EnrollmentScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _showComingSoonMessage(BuildContext context) {
    // Add haptic feedback for better response
    HapticFeedback.lightImpact();
    
    // Clear previous snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Show new snackbar with animation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.access_time, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        backgroundColor: Color(0xFFE9008D),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.easeOutCirc,
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Hero(
      tag: title, // For smooth transitions
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Color(0xFFE9008D).withOpacity(0.1),
          highlightColor: Color(0xFFE9008D).withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFE9008D).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: Color(0xFFE9008D),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}























// // import 'package:ems/screens/extratech-oval/login/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:ems/screens/AMS/enrollment/enrollment_screen.dart';
// import 'package:ems/screens/extratech-oval/home/home_screen.dart';

// class SelectionScreen extends StatelessWidget {
//   const SelectionScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Row(
//           children: [
           
            
//           ],
//         ),
        
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 20),
//             Text(
//               'Welcome to Extratech',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Please select your role to continue',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.black54,
//               ),
//             ),
//             SizedBox(height: 40),
//             _buildOptionCard(
//               context,
//               title: 'Student',
//               description: 'Attendance Management System',
//               icon: Icons.school,
//               onTap: () {
//                 // Navigate to AMS EnrollmentScreen
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => EnrollmentScreen(),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: 20),
//             _buildOptionCard(
//               context,
//               title: 'Other',
//               description: 'Extratech Oval Portal',
//               icon: Icons.business,
//               onTap: () {
//                 // Navigate to Extratech Oval WebView
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ExtratechOvalScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOptionCard(
//     BuildContext context, {
//     required String title,
//     required String description,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, 5),
//             ),
//           ],
//           border: Border.all(
//             color: Color(0xFFE9008D).withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Color(0xFFE9008D).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 icon,
//                 size: 30,
//                 color: Color(0xFFE9008D),
//               ),
//             ),
//             SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               color: Color(0xFFE9008D),
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }