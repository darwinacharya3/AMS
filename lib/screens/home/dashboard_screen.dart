import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_widgets/custom_navigation.dart';
import 'package:ems/models/user_detail.dart';
import 'package:ems/models/location_model.dart';
import 'package:ems/services/secure_storage_service.dart';
import 'package:ems/widgets/dashboard_widgets/profile_information_widget.dart';
import 'package:ems/widgets/dashboard_widgets/resident_information_widget.dart';
import 'package:ems/widgets/dashboard_widgets/emergency_contact_widget.dart';
import 'package:ems/widgets/dashboard_widgets/passport_copies_widget.dart';
import 'package:ems/widgets/dashboard_widgets/terms_and_condition_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedItem = 'General';
  DateTime? _lastBackPressed;
  UserDetail? _userDetail;
  bool _isLoading = true;
  String? _error;
  List<Country> _countries = [];
  List<StateModel> _states = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  try {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Get credentials from secure storage
    final email = await SecureStorageService.getUserEmail();
    final password = await SecureStorageService.getUserPassword();
    
    debugPrint('Retrieved email from storage: $email');

    if (email == null || password == null) {
      throw Exception('Stored credentials not found');
    }
    
    // Use the secure login endpoint
    final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';
    debugPrint('Making API request to: $loginUrl');

    final loginResponse = await http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password
      }),
    );
    
    debugPrint('API Response Status Code: ${loginResponse.statusCode}');
    
    if (loginResponse.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(loginResponse.body);
      
      // Save the token to secure storage
      if (data.containsKey('token') && data['token'] != null) {
        await SecureStorageService.saveToken(data['token']);
        debugPrint('Token saved to secure storage');
      } else {
        debugPrint('Warning: Token not found in API response');
      }
      
      if (mounted) {
        setState(() {
          _userDetail = UserDetail.fromJson(data);
          
          // Parse countries and states if they're included in the response
          _countries = (data['countries'] as List?)
              ?.map((country) => Country.fromJson(country))
              .toList() ?? [];
              
          _states = (data['states'] as List?)
              ?.map((state) => StateModel.fromJson(state))
              .toList() ?? [];
              
          _isLoading = false;
        });
      }
    } else {
      // Handle various error responses
      if (loginResponse.statusCode == 401) {
        throw Exception('Invalid credentials. Please log in again.');
      } else if (loginResponse.statusCode == 403) {
        throw Exception('Access denied. You may not have permission to view this information.');
      } else {
        throw Exception('Authentication failed: ${loginResponse.statusCode}');
      }
    }
  } catch (e) {
    debugPrint('Error in _loadData: $e');
    if (mounted) {
      setState(() {
        // Provide more specific error message based on the exception
        if (e.toString().contains('credentials not found')) {
          _error = 'Your login session has expired. Please log in again.';
        } else {
          _error = 'Unable to load your information. Please try again later.';
        }
        _isLoading = false;
      });
    }
  }
}



  Future<bool> _onWillPop() async {
    if (_lastBackPressed == null ||
        DateTime.now().difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  void _onItemSelected(String item) {
    setState(() {
      _selectedItem = item;
    });
    if (item == 'Logout') {
      SecureStorageService.clearCredentials().then((_) {
        if(mounted){
          CustomNavigation.navigateToScreen(item, context);
        }
        
      });
    } else {
      CustomNavigation.navigateToScreen(item, context);
    }
  }

  void _handleRetry() {
    // Clear error and try again
    setState(() {
      _error = null;
    });
    _loadData();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 227, 10, 169),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Retry',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 227, 10, 169),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  if (_error!.contains('login')) ...[
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to login screen
                        CustomNavigation.navigateToScreen('Login', context);
                      },
                      icon: const Icon(Icons.login),
                      label: Text(
                        'Login',
                        style: GoogleFonts.poppins(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Make sure user details are available before rendering widgets
    if (_userDetail == null) {
      return Center(
        child: Text(
          'No user information available.',
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileInformationWidget(
            userDetail: _userDetail!,
          ),
          ResidentialInformationWidget(
            userDetail: _userDetail!,
            countries: _countries,
            states: _states,
          ),
          EmergencyContactWidget(
            userDetail: _userDetail!,
          ),
          PassportCopiesWidget(
            userDetail: _userDetail,
          ),
          TermsAndConditionWidget(
            userDetail: _userDetail
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop){
        if (didPop) return;
        _onWillPop;
      },
      
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(
          title: _selectedItem,
          icon: Icons.person,
          showBackButton: false,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: _selectedItem, 
          onItemSelected: _onItemSelected,
        ),
        body: SafeArea(
          child: _buildContent(),
        ),
      ),
    );
  }
}




















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_navigation.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:ems/models/location_model.dart';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:ems/widgets/profile_information_widget.dart';
// import 'package:ems/widgets/resident_information_widget.dart';
// import 'package:ems/widgets/emergency_contact_widget.dart';
// import 'package:ems/widgets/passport_copies_widget.dart';
// import 'package:ems/widgets/terms_and_condition_widget.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String _selectedItem = 'General';
//   DateTime? _lastBackPressed;
//   UserDetail? _userDetail;
//   bool _isLoading = true;
//   String? _error;
//   List<Country> _countries = [];
//   List<StateModel> _states = [];
  
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       // Get credentials from secure storage
//       final email = await SecureStorageService.getUserEmail();
//       final password = await SecureStorageService.getUserPassword();
      
//       debugPrint('Retrieved email from storage: $email');

//       if (email == null || password == null) {
//         throw Exception('Stored credentials not found');
//       }
      
//       // Use the secure login endpoint
//       final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';
//       debugPrint('Making API request to: $loginUrl');

//       final loginResponse = await http.post(
//         Uri.parse(loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode({
//           'email': email,
//           'password': password
//         }),
//       );
      

//       debugPrint('API Response Status Code: ${loginResponse.statusCode}');
//       if (loginResponse.statusCode == 200) {
//         // Successfully logged in
//         final responseData = json.decode(loginResponse.body);
//         print('Login response: $responseData');
//       }

//       if (loginResponse.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(loginResponse.body);
//         if (mounted) {
//           setState(() {
//             _userDetail = UserDetail.fromJson(data);
            
//             // Parse countries and states if they're included in the response
//             _countries = (data['countries'] as List?)
//                 ?.map((country) => Country.fromJson(country))
//                 .toList() ?? [];
                
//             _states = (data['states'] as List?)
//                 ?.map((state) => StateModel.fromJson(state))
//                 .toList() ?? [];
                
//             _isLoading = false;
//           });
//         }
//       } else {
//         // Handle various error responses
//         if (loginResponse.statusCode == 401) {
//           throw Exception('Invalid credentials. Please log in again.');
//         } else if (loginResponse.statusCode == 403) {
//           throw Exception('Access denied. You may not have permission to view this information.');
//         } else {
//           throw Exception('Authentication failed: ${loginResponse.statusCode}');
//         }
//       }
//     } catch (e) {
//       debugPrint('Error in _loadData: $e');
//       if (mounted) {
//         setState(() {
//           // Provide more specific error message based on the exception
//           if (e.toString().contains('credentials not found')) {
//             _error = 'Your login session has expired. Please log in again.';
//           } else {
//             _error = 'Unable to load your information. Please try again later.';
//           }
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (_lastBackPressed == null ||
//         DateTime.now().difference(_lastBackPressed!) > const Duration(seconds: 2)) {
//       _lastBackPressed = DateTime.now();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Press back again to exit'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return false;
//     }
//     return true;
//   }

//   void _onItemSelected(String item) {
//     setState(() {
//       _selectedItem = item;
//     });
//     if (item == 'Logout') {
//       SecureStorageService.clearCredentials().then((_) {
//         CustomNavigation.navigateToScreen(item, context);
//       });
//     } else {
//       CustomNavigation.navigateToScreen(item, context);
//     }
//   }

//   void _handleRetry() {
//     // Clear error and try again
//     setState(() {
//       _error = null;
//     });
//     _loadData();
//   }

//   Widget _buildContent() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: Color.fromARGB(255, 227, 10, 169),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.red,
//                 size: 48,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Something went wrong',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _error!,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   color: Colors.red,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _handleRetry,
//                     icon: const Icon(Icons.refresh),
//                     label: Text(
//                       'Retry',
//                       style: GoogleFonts.poppins(),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color.fromARGB(255, 227, 10, 169),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     ),
//                   ),
//                   if (_error!.contains('login')) ...[
//                     const SizedBox(width: 12),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // Navigate to login screen
//                         CustomNavigation.navigateToScreen('Login', context);
//                       },
//                       icon: const Icon(Icons.login),
//                       label: Text(
//                         'Login',
//                         style: GoogleFonts.poppins(),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // Make sure user details are available before rendering widgets
//     if (_userDetail == null) {
//       return Center(
//         child: Text(
//           'No user information available.',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//           ),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           ProfileInformationWidget(
//             userDetail: _userDetail!,
//           ),
//           ResidentialInformationWidget(
//             userDetail: _userDetail!,
//             countries: _countries,
//             states: _states,
//           ),
//           EmergencyContactWidget(
//             userDetail: _userDetail!,
//           ),
//           PassportCopiesWidget(
//             userDetail: _userDetail,
//           ),
//           TermsAndConditionWidget(
//             userDetail: _userDetail
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: CustomAppBar(
//           title: _selectedItem,
//           icon: Icons.person,
//           showBackButton: false,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: _selectedItem, 
//           onItemSelected: _onItemSelected,
//         ),
//         body: SafeArea(
//           child: _buildContent(),
//         ),
//       ),
//     );
//   }
// }


















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_navigation.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:ems/models/location_model.dart';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:ems/widgets/profile_information_widget.dart';
// import 'package:ems/widgets/resident_information_widget.dart';
// import 'package:ems/widgets/emergency_contact_widget.dart';
// import 'package:ems/widgets/passport_copies_widget.dart';


// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String _selectedItem = 'General';
//   DateTime? _lastBackPressed;
//   UserDetail? _userDetail;
//   bool _isLoading = true;
//   String? _error;
//   List<Country> _countries = [];
//   List<StateModel> _states = [];
  
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       final email = await SecureStorageService.getUserEmail();
//       debugPrint('Retrieved email from storage: $email');

//       if (email == null) {
//         throw Exception('No stored email found');
//       }
      
//       final url = 'https://extratech.extratechweb.com/api/student/detail/$email';
//       debugPrint('Making API request to: $url');

//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       debugPrint('API Response Status Code: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (mounted) {
//           setState(() {
//             _userDetail = UserDetail.fromJson(data);
            
//             _countries = (data['countries'] as List?)
//                 ?.map((country) => Country.fromJson(country))
//                 .toList() ?? [];
                
//             _states = (data['states'] as List?)
//                 ?.map((state) => StateModel.fromJson(state))
//                 .toList() ?? [];
                
//             _isLoading = false;
//           });
//         }
//       } else {
//         throw Exception('Failed to load user details: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Error in _loadData: $e');
//       if (mounted) {
//         setState(() {
//           // More user-friendly error message
//           _error = 'Unable to load your information. Please try again later.';
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (_lastBackPressed == null ||
//         DateTime.now().difference(_lastBackPressed!) > const Duration(seconds: 2)) {
//       _lastBackPressed = DateTime.now();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Press back again to exit'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return false;
//     }
//     return true;
//   }

//   void _onItemSelected(String item) {
//     setState(() {
//       _selectedItem = item;
//     });
//     if (item == 'Logout') {
//       SecureStorageService.clearCredentials().then((_) {
//         CustomNavigation.navigateToScreen(item, context);
//       });
//     } else {
//       CustomNavigation.navigateToScreen(item, context);
//     }
//   }

//   Widget _buildContent() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: Color.fromARGB(255, 227, 10, 169),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.red,
//                 size: 48,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Something went wrong',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _error!,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   color: Colors.red,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: _loadData,
//                 icon: const Icon(Icons.refresh),
//                 label: Text(
//                   'Retry',
//                   style: GoogleFonts.poppins(),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 227, 10, 169),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // Make sure user details are available before rendering widgets
//     if (_userDetail == null) {
//       return Center(
//         child: Text(
//           'No user information available.',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//           ),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           ProfileInformationWidget(
//             userDetail: _userDetail!,
//           ),
//           ResidentialInformationWidget(
//             userDetail: _userDetail!,
//             countries: _countries,
//             states: _states,
//           ),
//           EmergencyContactWidget(
//             userDetail: _userDetail!,
//           ),
//           const PassportCopiesWidget(),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: CustomAppBar(
//           title: _selectedItem,
//           icon: Icons.person,
//           showBackButton: false,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: _selectedItem, 
//           onItemSelected: _onItemSelected,
//         ),
//         body: SafeArea(
//           child: _buildContent(),
//         ),
//       ),
//     );
//   }
// }


















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_navigation.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:ems/models/location_model.dart';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:ems/widgets/profile_information_widget.dart';
// import 'package:ems/widgets/resident_information_widget.dart';
// import 'package:ems/widgets/emergency_contact_widget.dart';
// import 'package:ems/widgets/passport_copies_widget.dart';


// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   String _selectedItem = 'General';
//   DateTime? _lastBackPressed;
//   UserDetail? _userDetail;
//   bool _isLoading = true;
//   String? _error;
//    List<Country> _countries = [];
//   List<StateModel> _states = [];
  

//   @override
//   void initState() {
//     super.initState();
//     _loadUserDetails();
//     _loadCountriesAndStates();
//   }

//   Future<void> _loadCountriesAndStates() async {
//       final email = await SecureStorageService.getUserEmail();
//       debugPrint('Retrieved email from storage: $email');
//     try {
//       final url = 'https://extratech.extratechweb.com/api/student/detail/$email';
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
        
//         if (mounted) {
//           setState(() {
//             _countries = (data['countries'] as List)
//                 .map((country) => Country.fromJson(country))
//                 .toList();
                
//             _states = (data['states'] as List)
//                 .map((state) => StateModel.fromJson(state))
//                 .toList();
//           });
//         }
//       } else {
//         throw Exception('Failed to load countries and states');
//       }
//     } catch (e) {
//       debugPrint('Error loading countries and states: $e');
//       if (mounted) {
//         setState(() {
//           _error = 'Failed to load location data: $e';
//         });
//       }
//     }
//   }

//   Future<void> _loadUserDetails() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       final email = await SecureStorageService.getUserEmail();
//       debugPrint('Retrieved email from storage: $email');

//       if (email != null) {
        
//         final url = 'https://extratech.extratechweb.com/api/student/detail/$email';
//         debugPrint('Making API request to: $url');

//         final response = await http.get(
//           Uri.parse(url),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//         );

//         debugPrint('API Response Status Code: ${response.statusCode}');

//         if (response.statusCode == 200) {
//           final Map<String, dynamic> data = json.decode(response.body);
//           if (mounted) {
//             setState(() {
//               _userDetail = UserDetail.fromJson(data);
//               _isLoading = false;
//             });
//           }
//         } else {
//           throw Exception('Failed to load user details: ${response.statusCode}');
//         }
//       } else {
//         throw Exception('No stored email found');
//       }
//     } catch (e) {
//       debugPrint('Error in _loadUserDetails: $e');
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (_lastBackPressed == null ||
//         DateTime.now().difference(_lastBackPressed!) > const Duration(seconds: 2)) {
//       _lastBackPressed = DateTime.now();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Press back again to exit'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return false;
//     }
//     return true;
//   }

//   void _onItemSelected(String item) {
//     setState(() {
//       _selectedItem = item;
//     });
//     if (item == 'Logout') {
//       SecureStorageService.clearCredentials().then((_) {
//         CustomNavigation.navigateToScreen(item, context);
//       });
//     } else {
//       CustomNavigation.navigateToScreen(item, context);
//     }
//   }


//   Widget _buildContent() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           color: Color.fromARGB(255, 227, 10, 169),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.red,
//                 size: 48,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Error loading data:',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _error!,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   color: Colors.red,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: _loadUserDetails,
//                 icon: const Icon(Icons.refresh),
//                 label: Text(
//                   'Retry',
//                   style: GoogleFonts.poppins(),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 227, 10, 169),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           ProfileInformationWidget(
//             userDetail: _userDetail!,
//           ),
//           ResidentialInformationWidget(
//             userDetail: _userDetail!,
//             countries: _countries,
//             states: _states,
//           ),
//            EmergencyContactWidget(
//           userDetail: _userDetail!,
//         ),
//         PassportCopiesWidget(),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.grey[50],
//         appBar: CustomAppBar(
//           title: _selectedItem,
//           icon: Icons.person,
//           showBackButton: false,
//           ),
//           endDrawer: DashboardDrawer(
//             selectedItem: _selectedItem, 
//             onItemSelected: _onItemSelected,),

//         body: SafeArea(
//           child: _buildContent(),
//         ),
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ems/models/user_detail.dart';
// import 'package:ems/widgets/profile_information_widget.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   UserDetail? _userDetail;
//   bool _isLoading = true;
//   String? _error;
  
//   @override
//   void initState() {
//     super.initState();
//     _loadUserDetails();
//   }

//   Future<void> _loadUserDetails() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       final email = await SecureStorageService.getUserEmail();
//       if (email != null) {
//         final url = 'https://extratech.extratechweb.com/api/student/detail/$email';
//         final response = await http.get(
//           Uri.parse(url),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//         );

//         if (response.statusCode == 200) {
//           final Map<String, dynamic> data = json.decode(response.body);
//           if (mounted) {
//             setState(() {
//               _userDetail = UserDetail.fromJson(data);
//               _isLoading = false;
//             });
//           }
//         } else {
//           throw Exception('Failed to load user details');
//         }
//       } else {
//         throw Exception('No stored email found');
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Widget _buildProfileHeader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           // Profile image and name
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundImage: NetworkImage(
//                   'https://extratech.extratechweb.com/${_userDetail?.image ?? ""}',
//                 ),
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _userDetail?.name ?? '',
//                       style: GoogleFonts.poppins(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       _userDetail?.batchName ?? '',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     Text(
//                       '${_userDetail?.commencementDate ?? ""} ${_userDetail?.timeSlot ?? ""}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           // Course Materials button removed as requested
//           const SizedBox(height: 20),
//           // Download and Edit buttons
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.download, color: Colors.pink),
//                 label: Text(
//                   'Download Profile',
//                   style: GoogleFonts.poppins(color: Colors.pink),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   side: const BorderSide(color: Colors.pink),
//                 ),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.edit, color: Colors.pink),
//                 label: Text(
//                   'Edit',
//                   style: GoogleFonts.poppins(color: Colors.pink),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   side: const BorderSide(color: Colors.pink),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoSection(String title, Map<String, String> fields) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           ...fields.entries.map((entry) => _buildInfoField(entry.key, entry.value)),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoField(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const Divider(height: 16),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_error != null) {
//       return Scaffold(
//         body: Center(
//           child: Text('Error: $_error'),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Row(
//           children: [
//             const Icon(Icons.person, color: Colors.pink),
//             const SizedBox(width: 10),
//             Text(
//               'General',
//               style: GoogleFonts.poppins(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildProfileHeader(),
//             _buildInfoSection(
//               'Student Personal Information',
//               {
//                 'Name': _userDetail?.name ?? '',
//                 'Gender': _userDetail?.gender == '1' ? 'Male' : 'Female',
//                 'Phone': _userDetail?.mobileNo ?? '',
//                 'Email': _userDetail?.email ?? '',
//                 'Date of Birth': _userDetail?.dob ?? '',
//                 'Birth Country': 'Nepal', // Map from country_id
//                 'State': 'Gandaki', // Map from state_id
//                 'Home Country Address': _userDetail?.birthResidentialAddress ??  '',
//               },
//             ),
//             _buildInfoSection(
//               'Residential Information',
//               {
//                 'Current Address': _userDetail?.residentialAddress ?? '',
//                 'Post Code': _userDetail?.postCode ?? '',
//                 'Visa Type': _userDetail?.visaType ?? '',
//                 'Current State': 'Bagmati', // Map from current_state_id
//                 'Passport Number': _userDetail?.passportNumber ?? '',
//                 'Passport Expiry': _userDetail?.passportExpiryDate ?? '',
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }







