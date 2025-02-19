import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/widgets/custom_app_bar.dart';
import 'package:ems/widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_navigation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedItem = 'General';
  DateTime? _lastBackPressed;

  Future<bool> _onWillPop() async {
    // Special handling for dashboard as it's the main screen
    if (_lastBackPressed == null || 
        DateTime.now().difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      // Show "Press back again to exit" message
      _lastBackPressed = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true; // Allow app to exit
  }

  void _onItemSelected(String item) {
    setState(() {
      _selectedItem = item;
    });
    CustomNavigation.navigateToScreen(item, context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          title: _selectedItem,
          icon: Icons.person,
          showBackButton: false,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: _selectedItem,
          onItemSelected: _onItemSelected,
        ),
        body: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to General Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Add your general dashboard content here
        ],
      ),
    );
  }
}














// // lib/screens/dashboard/dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String _selectedItem = 'General';

//   void _onItemSelected(String item) {
//     setState(() {
//       _selectedItem = item;
//     });
//     CustomNavigation.navigateToScreen(item, context);
//   }

//   Widget _buildContent() {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Welcome to General Dashboard',
//             style: GoogleFonts.poppins(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Add your general dashboard content here
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: _selectedItem,
//         icon: Icons.person,
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: _selectedItem,
//         onItemSelected: _onItemSelected,
//       ),
//       body: _buildContent(),
//     );
//   }
// }














// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// // Uncomment these imports
// import 'package:ems/screens/home/attendance_screen.dart';
// import 'package:ems/screens/home/career_screen.dart';
// import 'package:ems/screens/home/quiz_screen.dart';
// import 'package:ems/screens/material/material_screen.dart';
// import 'package:ems/screens/zoom_link/zoom_link_screen.dart';
// import 'package:ems/screens/tickets/all_tickets_screen.dart';
// import 'package:ems/screens/tickets/completed_tickets_screen.dart';
// import 'package:ems/screens/tickets/create_ticket_screen.dart';
// import 'package:ems/screens/enrollment/enrollment_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String _selectedItem = 'General';

//   void _onItemSelected(String item) {
//     // Set selected item first
//     setState(() {
//       _selectedItem = item;
//     });
    
//     // Close drawer
//     Navigator.of(context).pop();
    
//     // Add small delay to ensure drawer is closed before navigation
//     Future.delayed(const Duration(milliseconds: 100), () {
//       // Handle navigation with GetX
//       switch (item) {
//         case 'General':
//           // Already on General screen, do nothing
//           Get.to(() => const DashboardScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Attendance':
//           Get.to(() => const AttendanceScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Quiz':
//           Get.to(() => const QuizScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Career':
//           Get.to(() => const CareerScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Materials':
//           Get.to(() => const MaterialsScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Zoom Links':
//           Get.to(() => const ZoomLinksScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Create Ticket':
//           Get.to(() => const CreateTicketScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'All Tickets':
//           Get.to(() => const AllTicketsScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Completed Tickets':
//           Get.to(() => const CompletedTicketsScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Logout':
//           Get.offAll(() => const EnrollmentScreen(), transition: Transition.fade);
//           break;
//       }
//     });
//   }

//   // Build content based on selected item
//   Widget _buildContent() {
//     switch (_selectedItem) {
//       case 'General':
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Welcome to General Dashboard',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add your general dashboard content here
//             ],
//           ),
//         );
//       default:
//         return Center(
//           child: Text(
//             'Selected Item: $_selectedItem',
//             style: GoogleFonts.roboto(
//               fontSize: 18,
//               color: Colors.black87,
//             ),
//           ),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             const Icon(
//               Icons.person,
//               color: Color.fromARGB(255, 227, 10, 169),
//               size: 24,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               _selectedItem,  // Use the selected item in the app bar title
//               style: GoogleFonts.poppins(
//                 color: Color.fromARGB(255, 227, 10, 169),
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         actions: [
//           Builder(
//             builder: (context) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.menu,
//                     size: 32,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: _selectedItem,
//         onItemSelected: _onItemSelected,
//       ),
//       body: _buildContent(),
//     );
//   }
// }











// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/screens/home/attendance_screen.dart';
// import 'package:ems/screens/home/career_screen.dart';
// import 'package:ems/screens/home/quiz_screen.dart';
// import 'package:ems/screens/material/material_screen.dart';
// import 'package:ems/screens/zoom_link/zoom_link_screen.dart';
// import 'package:ems/screens/tickets/all_tickets_screen.dart';
// import 'package:ems/screens/tickets/completed_tickets_screen.dart';
// import 'package:ems/screens/tickets/create_ticket_screen.dart';
// import 'package:ems/screens/enrollment/enrollment_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   // Changed default selected item to 'General'
//   String _selectedItem = 'General';

//   void _onItemSelected(String item) {
//     // Close the drawer first
//     // Get.back();
    
//     setState(() {
//       _selectedItem = item;
//     });
    
//     // Navigation logic implementation with GetX
//     switch (item) {
//       case 'General':
//         // Already on dashboard/general screen, drawer is already closed above
//         break;
//       case 'Attendance':
//         Get.to(() => const AttendanceScreen());
//         break;
//       case 'Quiz':
//         Get.to(() => const QuizScreen());
//         break;
//       case 'Career':
//         Get.to(() => const CareerScreen());
//         break;
//       case 'Materials':
//         Get.to(() => const MaterialsScreen());
//         break;
//       case 'Zoom Links':
//         Get.to(() => const ZoomLinksScreen());
//         break;
//       case 'Create Ticket':
//         Get.to(() => const CreateTicketScreen());
//         break;
//       case 'All Tickets':
//         Get.to(() => const AllTicketsScreen());
//         break;
//       case 'Completed Tickets':
//         Get.to(() => const CompletedTicketsScreen());
//         break;
//       case 'Logout':
//         // For logout, navigate back to enrollment screen and clear all routes
//         Get.offAll(() => const EnrollmentScreen());
//         break;
//       default:
//         // Default case if you add more items later
//         break;
//     }
//   }

//   // Add method to build the content based on selected item
//   Widget _buildContent() {
//     switch (_selectedItem) {
//       case 'General':
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Welcome to General Dashboard',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add your general dashboard content here
//             ],
//           ),
//         );
//       default:
//         return Center(
//           child: Text(
//             'Selected Item: $_selectedItem',
//             style: GoogleFonts.roboto(
//               fontSize: 18,
//               color: Colors.black87,
//             ),
//           ),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             const Icon(
//               Icons.person,
//               color: Color.fromARGB(255, 227, 10, 169),
//               size: 24,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'General',
//               style: GoogleFonts.poppins(
//                 color: Color.fromARGB(255, 227, 10, 169),
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         actions: [
//           Builder(
//             builder: (context) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.menu,
//                     size: 32,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: _selectedItem,
//         onItemSelected: _onItemSelected,
//       ),
//       body: _buildContent(),
//     );
//   }
// }















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/home/attendance_screen.dart';
// import 'package:ems/screens/home/career_screen.dart';
// import 'package:ems/screens/home/quiz_screen.dart';
// import 'package:ems/screens/material/material_screen.dart';
// import 'package:ems/screens/zoom_link/zoom_link_screen.dart';
// import 'package:ems/screens/tickets/all_tickets_screen.dart';
// import 'package:ems/screens/tickets/completed_tickets_screen.dart';
// import 'package:ems/screens/tickets/create_ticket_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   // Changed default selected item to 'General'
//   String _selectedItem = 'General';

//   void _onItemSelected(String item) {

//     Get.back();
//     setState(() {
//       _selectedItem = item;
//     });
//     // TODO: Implement navigation logic here
//   }

  



  

  

//   // Add method to build the content based on selected item
//   Widget _buildContent() {
//     switch (_selectedItem) {
//       case 'General':
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Welcome to General Dashboard',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add your general dashboard content here
//             ],
//           ),
//         );
//       default:
//         return Center(
//           child: Text(
//             'Selected Item: $_selectedItem',
//             style: GoogleFonts.roboto(
//               fontSize: 18,
//               color: Colors.black87,
//             ),
//           ),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             const Icon(
//               Icons.person,
//               color: Color.fromARGB(255, 227, 10, 169),
//               size: 24,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'General',
//               style: GoogleFonts.poppins(
//                 color: Color.fromARGB(255, 227, 10, 169),
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         actions: [
//           Builder(
//             builder: (context) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.menu,
//                     size: 32,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: _selectedItem,
//         onItemSelected: _onItemSelected,
//       ),
//       body: _buildContent(),
//     );
//   }
// }

















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/screens/home/attendance_screen.dart';
// import 'package:ems/screens/home/career_screen.dart';
// import 'package:ems/screens/home/quiz_screen.dart';
// import 'package:ems/screens/material/material_screen.dart';
// import 'package:ems/screens/zoom_link/zoom_link_screen.dart';
// import 'package:ems/screens/tickets/all_tickets_screen.dart';
// import 'package:ems/screens/tickets/completed_tickets_screen.dart';
// import 'package:ems/screens/tickets/create_ticket_screen.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   // Changed default selected item to 'General'
//   String _selectedItem = 'General';

//   void _onItemSelected(String item) {
//     setState(() {
//       _selectedItem = item;
//     });
//     // TODO: Implement navigation logic here
//   }

  

  

//   // Add method to build the content based on selected item
//   Widget _buildContent() {
//     switch (_selectedItem) {
//       case 'General':
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Welcome to General Dashboard',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add your general dashboard content here
//             ],
//           ),
//         );
//       default:
//         return Center(
//           child: Text(
//             'Selected Item: $_selectedItem',
//             style: GoogleFonts.roboto(
//               fontSize: 18,
//               color: Colors.black87,
//             ),
//           ),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             const Icon(
//               Icons.person,
//               color: Color.fromARGB(255, 227, 10, 169),
//               size: 24,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'General',
//               style: GoogleFonts.poppins(
//                 color: Color.fromARGB(255, 227, 10, 169),
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         actions: [
//           Builder(
//             builder: (context) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.menu,
//                     size: 32,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: _selectedItem,
//         onItemSelected: _onItemSelected,
//       ),
//       body: _buildContent(),
//     );
//   }
// }



















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String _selectedItem = 'Dashboard';

//   void _onItemSelected(String item) {
//     setState(() {
//       _selectedItem = item;
//     });
//     // TODO: Implement navigation logic here
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'AMS',
//           style: GoogleFonts.poppins(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         actions: [
//           Builder(
//             builder: (context) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.menu,
//                     size: 32,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: _selectedItem,
//         onItemSelected: _onItemSelected,
//       ),
//       body: Center(
//         child: Text(
//           'Selected Item: $_selectedItem',
//           style: GoogleFonts.roboto(
//             fontSize: 18,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
// }




















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String _selectedItem = 'Dashboard';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Dashboard',
//           style: GoogleFonts.poppins(  // Using Poppins font
//             color: const Color.fromARGB(255, 0, 0, 0),
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         actions: [
//           Builder(
//             builder: (context) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.menu,
//                     size: 32,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       endDrawer: Drawer(
//         backgroundColor: Colors.blue,
//         child: Column(
//           children: [
//             const SizedBox(height: 80),
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   _buildExpansionTile(
//                     'Dashboard',
//                     Icons.dashboard,
//                     [
//                       _buildSubListTile('General', Icons.person),
//                       _buildSubListTile('Attendance', Icons.calendar_today),
//                       _buildSubListTile('Quiz', Icons.quiz),
//                       _buildSubListTile('Career', Icons.work),
//                     ],
//                   ),
//                   _buildListTile('Materials', Icons.library_books),
//                   _buildListTile('Zoom Links', Icons.videocam),
//                   _buildExpansionTile(
//                     'Tickets',
//                     Icons.confirmation_number,
//                     [
//                       _buildSubListTile('Create Ticket', Icons.add_circle_outline),
//                       _buildSubListTile('All Tickets', Icons.list_alt),
//                       _buildSubListTile('Completed Tickets', Icons.check_circle_outline),
//                     ],
//                   ),
//                   _buildListTile('Logout', Icons.logout),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Text(
//           'Selected Item: $_selectedItem',
//           style: GoogleFonts.roboto(  // Using Roboto font
//             fontSize: 18,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildExpansionTile(String title, IconData icon, List<Widget> children) {
//     return ExpansionTile(
//       leading: Icon(icon, color: Colors.white),
//       title: Text(
//         title,
//         style: GoogleFonts.inter(  // Using Inter font
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       backgroundColor: _selectedItem == title ? Colors.white : Colors.blue,
//       collapsedIconColor: Colors.white,
//       iconColor: _selectedItem == title ? Colors.blue : Colors.white,
//       children: children,
//     );
//   }

//   Widget _buildListTile(String title, IconData icon) {
//     bool isSelected = _selectedItem == title;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       color: isSelected ? Colors.white : Colors.blue,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//         ),
//         title: Text(
//           title,
//           style: GoogleFonts.inter(  // Using Inter font
//             color: isSelected ? Colors.blue : Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         onTap: () {
//           setState(() {
//             _selectedItem = title;
//           });
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   Widget _buildSubListTile(String title, IconData icon) {
//     bool isSelected = _selectedItem == title;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       color: isSelected ? Colors.blue[50] : Colors.blue,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//           size: 24,
//         ),
//         title: Text(
//           title,
//           style: GoogleFonts.inter(  // Using Inter font
//             color: isSelected ? Colors.blue : Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         onTap: () {
//           setState(() {
//             _selectedItem = title;
//           });
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   // Track the currently selected menu item
//   String _selectedItem = 'Dashboard';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // AppBar configuration
//       appBar: AppBar(
//         title: const Text(
//           'DASHBOARD',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
            
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         actions: [
//           Builder(
//             builder: (context) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.menu,
//                     size: 32,
//                     color: Colors.black,
//                   ),
//                   onPressed: () {
//                     Scaffold.of(context).openEndDrawer();
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),

//       // Drawer configuration
//       endDrawer: Drawer(
//         backgroundColor: Colors.blue,
//         child: Column(
//           children: [
//             const SizedBox(height: 80), // Add space at the top
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   // Dashboard section with subsections
//                   _buildExpansionTile(
//                     'Dashboard',
//                     Icons.dashboard,
//                     [
//                       _buildSubListTile('General', Icons.person),
//                       _buildSubListTile('Attendance', Icons.calendar_today),
//                       _buildSubListTile('Quiz', Icons.quiz),
//                       _buildSubListTile('Career', Icons.work),
//                     ],
//                   ),

//                   // Regular menu items
//                   _buildListTile('Materials', Icons.library_books),
//                   _buildListTile('Zoom Links', Icons.videocam),

//                   // Tickets section with subsections
//                   _buildExpansionTile(
//                     'Tickets',
//                     Icons.confirmation_number,
//                     [
//                       _buildSubListTile('Create Ticket', Icons.add_circle_outline),
//                       _buildSubListTile('All Tickets', Icons.list_alt),
//                       _buildSubListTile('Completed Tickets', Icons.check_circle_outline),
//                     ],
//                   ),

//                   // Logout option
//                   _buildListTile('Logout', Icons.logout),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),

//       // Main content area
//       body: _buildBody(),
//     );
//   }

//   // Build the main content area
//   Widget _buildBody() {
//     return Center(
//       child: Text('Selected Item: $_selectedItem'),
//     );
//   }

//   // Build expansion tile for sections with subsections
//   Widget _buildExpansionTile(String title, IconData icon, List<Widget> children) {
//     return ExpansionTile(
//       leading: Icon(icon, color: Colors.white),
//       title: Text(
//         title,
//         style: const TextStyle(color: Colors.white),
//       ),
//       backgroundColor: _selectedItem == title ? Colors.white : Colors.blue,
//       collapsedIconColor: Colors.white,
//       iconColor: _selectedItem == title ? Colors.blue : Colors.white,
//       children: children,
//     );
//   }

//   // Build list tile for main menu items
//   Widget _buildListTile(String title, IconData icon) {
//     bool isSelected = _selectedItem == title;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       color: isSelected ? Colors.white : Colors.blue,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? Colors.blue : Colors.white,
//             fontSize: 16,
//           ),
//         ),
//         onTap: () {
//           setState(() {
//             _selectedItem = title;
//           });
//           Navigator.pop(context);
//           // TODO: Implement navigation logic here
//         },
//       ),
//     );
//   }

//   // Build list tile for subsections
//   Widget _buildSubListTile(String title, IconData icon) {
//     bool isSelected = _selectedItem == title;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       color: isSelected ? Colors.blue[50] : Colors.blue,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//           size: 24,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? Colors.blue : Colors.white,
//             fontSize: 16,
//           ),
//         ),
//         onTap: () {
//           setState(() {
//             _selectedItem = title;
//           });
//           Navigator.pop(context);
//           // TODO: Implement navigation logic here
//         },
//       ),
//     );
//   }
// }





















// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String _selectedItem = 'Dashboard';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AMS Home'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         automaticallyImplyLeading: false,
//         actions: [
//           Builder(
//             builder: (context) {
//               return IconButton(
//                 icon: const Icon(Icons.menu),
//                 onPressed: () {
//                   Scaffold.of(context).openEndDrawer();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       endDrawer: Drawer(
//         backgroundColor: Colors.blue,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             // Dashboard with expandable subsections
//             ExpansionTile(
//               leading: const Icon(Icons.dashboard, color: Colors.white),
//               title: const Text('Dashboard', 
//                 style: TextStyle(color: Colors.white)),
//               backgroundColor: _selectedItem == 'Dashboard' ? Colors.white : Colors.blue,
//               collapsedIconColor: Colors.white,
//               iconColor: _selectedItem == 'Dashboard' ? Colors.blue : Colors.white,
//               children: [
//                 _buildSubListTile('General', Icons.person),
//                 _buildSubListTile('Attendance', Icons.calendar_today),
//                 _buildSubListTile('Quiz', Icons.quiz),
//                 _buildSubListTile('Career', Icons.work),
//               ],
//             ),
//             _buildListTile('Materials', Icons.library_books),
//             _buildListTile('Zoom Links', Icons.videocam),
//             // Tickets with subsections
//             ExpansionTile(
//               leading: const Icon(Icons.confirmation_number, color: Colors.white),
//               title: const Text('Tickets', 
//                 style: TextStyle(color: Colors.white)),
//               backgroundColor: _selectedItem == 'Tickets' ? Colors.white : Colors.blue,
//               collapsedIconColor: Colors.white,
//               iconColor: _selectedItem == 'Tickets' ? Colors.blue : Colors.white,
//               children: [
//                 _buildSubListTile('Create Ticket', Icons.add_circle_outline),
//                 _buildSubListTile('All Tickets', Icons.list_alt),
//                 _buildSubListTile('Completed Tickets', Icons.check_circle_outline),
//               ],
//             ),
//             _buildListTile('Logout', Icons.logout),
//           ],
//         ),
//       ),
//       body: const Center(
//         child: Text('Welcome to AMS!'),
//       ),
//     );
//   }

//   Widget _buildListTile(String title, IconData icon) {
//     bool isSelected = _selectedItem == title;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       color: isSelected ? Colors.white : Colors.blue,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? Colors.blue : Colors.white,
//           ),
//         ),
//         onTap: () {
//           setState(() {
//             _selectedItem = title;
//           });
//           // TODO: Add navigation logic here
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   Widget _buildSubListTile(String title, IconData icon) {
//     bool isSelected = _selectedItem == title;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       color: isSelected ? Colors.blue[50] : Colors.blue,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? Colors.blue : Colors.white,
//           ),
//         ),
//         onTap: () {
//           setState(() {
//             _selectedItem = title;
//           });
//           // TODO: Add navigation logic here
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
// }












// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AMS Home'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         automaticallyImplyLeading: false, // Disable back button
//         actions: [
//           Builder(
//             builder: (context) {
//               return IconButton(
//                 icon: const Icon(Icons.menu),
//                 onPressed: () {
//                   Scaffold.of(context).openEndDrawer();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       endDrawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             // Drawer Header with white text and transparent background
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.transparent,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text(
//                     'Dashboard',
//                     style: TextStyle(
//                       color: Colors.black54,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Dashboard with expandable subsections
//             ExpansionTile(
//               leading: const Icon(Icons.dashboard, color: Colors.black54),
//               title: const Text('Dashboard', 
//                 style: TextStyle(color: Colors.black54)),
//               backgroundColor: Colors.blue,
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.person, color: Colors.white),
//                   title: const Text('General',
//                     style: TextStyle(color: Colors.white)),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.calendar_today, color: Colors.white),
//                   title: const Text('Attendance',
//                     style: TextStyle(color: Colors.white)),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.quiz, color: Colors.white),
//                   title: const Text('Quiz',
//                     style: TextStyle(color: Colors.white)),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.work, color: Colors.white),
//                   title: const Text('Career',
//                     style: TextStyle(color: Colors.white)),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//             ListTile(
//               leading: const Icon(Icons.library_books),
//               title: const Text('Materials'),
//               tileColor: Colors.blue,
//               textColor: Colors.white,
//               iconColor: Colors.white,
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.videocam),
//               title: const Text('Zoom Links'),
//               tileColor: Colors.blue[50],
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             // Tickets with subsections
//             ExpansionTile(
//               leading: const Icon(Icons.confirmation_number),
//               title: const Text('Tickets'),
//               backgroundColor: Colors.blue,
//               textColor: Colors.white,
//               iconColor: Colors.white,
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.add_circle_outline, color: Colors.white),
//                   title: const Text('Create Ticket',
//                     style: TextStyle(color: Colors.white)),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.list_alt, color: Colors.white),
//                   title: const Text('All Tickets',
//                     style: TextStyle(color: Colors.white)),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.check_circle_outline, color: Colors.white),
//                   title: const Text('Completed Tickets',
//                     style: TextStyle(color: Colors.white)),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               tileColor: Colors.blue,
//               textColor: Colors.white,
//               iconColor: Colors.white,
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: const Center(
//         child: Text('Welcome to AMS!'),
//       ),
//     );
//   }
// }














// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AMS Home'),
//         automaticallyImplyLeading: false, // Disable back button
//         actions: [
//           // Wrap the IconButton in a Builder to get the correct context for opening the drawer.
//           Builder(
//             builder: (context) {
//               return IconButton(
//                 icon: const Icon(Icons.menu),
//                 onPressed: () {
//                   Scaffold.of(context).openEndDrawer();
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       // endDrawer shows the drawer from the right side
//       endDrawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             // Drawer Header
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: const Text(
//                 'AMS Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             // Dashboard with expandable subsections
//             ExpansionTile(
//               title: const Text('Dashboard'),
//               children: [
//                 ListTile(
//                   title: const Text('General'),
//                   onTap: () {
//                     // TODO: Navigate to General section
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Attendance'),
//                   onTap: () {
//                     // TODO: Navigate to Attendance section
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Quiz'),
//                   onTap: () {
//                     // TODO: Navigate to Quiz section
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   title: const Text('Career'),
//                   onTap: () {
//                     // TODO: Navigate to Career section
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//             // Other menu items
//             ListTile(
//               title: const Text('Material'),
//               onTap: () {
//                 // TODO: Navigate to Material screen
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Zoom-link'),
//               onTap: () {
//                 // TODO: Navigate to Zoom-link screen
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Tickets'),
//               onTap: () {
//                 // TODO: Navigate to Tickets screen
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Logout'),
//               onTap: () {
//                 // TODO: Handle logout action
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: const Center(
//         child: Text('Welcome to AMS!'),
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AMS Home'),
//         automaticallyImplyLeading: false,  // Disable back button
//       ),
//       body: const Center(
//         child: Text('Welcome to AMS!'),
//       ),
//     );
//   }
// }