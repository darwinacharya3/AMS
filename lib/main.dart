import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ems/screens/welcome/welcome_screen.dart';
// import 'screens/AMS/enrollment/enrollment_screen.dart';
// import 'package:ems/screens/sign_in/signin_screen.dart';
// import 'package:ems/screens/create_membership_card/general_membership_card.dart';

// Import our new screens and constants
import 'package:ems/core/app_colors.dart';
import 'package:ems/screens/welcome/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ProviderScope(
      child: EMSApp(),
    ),
  );
}

class EMSApp extends StatelessWidget {
  const EMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Extratech AMS',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.lightBlueBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    HomeScreen(),
    Center(child: Text('Events Screen')),
    Center(child: Text('Alerts Screen')),
    Center(child: Text('Profile Screen')),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 24,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}








// // import 'package:ems/screens/enrollment/enrollment_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // import 'screens/AMS/enrollment/enrollment_screen.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ems/screens/welcome/welcome_screen.dart';
// // import 'package:ems/screens/sign_in/signin_screen.dart';
// // import 'package:ems/screens/create_membership_card/general_membership_card.dart';

// void main() {
//   runApp(
    
//      ProviderScope(
//       child: EMSApp(),
//     ),
//   );
// }

// class EMSApp extends StatelessWidget {
//   const EMSApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'EMS Enrollment',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: HomeScreen(),
//       // home: GeneralMembershipCard(),
//     );
//   }
// }







