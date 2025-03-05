import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ems/screens/home/dashboard_screen.dart';
import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/custom_widgets/custom_navigation.dart';
import 'package:ems/services/membership_card_services.dart';

// Import the widgets
import 'package:ems/widgets/membership_widgets/membership_card_widget.dart';
import 'package:ems/widgets/membership_widgets/membership_form_widget.dart';

class MembershipCardScreen extends StatefulWidget {
  const MembershipCardScreen({super.key});

  @override
  State<MembershipCardScreen> createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends State<MembershipCardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _membershipCard;
  List<Map<String, dynamic>>? _membershipTypes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkMembershipCard();
  }

  Future<void> _checkMembershipCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get membership card data
      final card = await MembershipCardService.getMembershipCard();
      
      // Get membership types for the form if needed
      final types = await MembershipCardService.getMembershipTypes();
      
      setState(() {
        _membershipCard = card;
        _membershipTypes = types;
        _isLoading = false;
      });
      
      // Debug prints
      print('Membership card data: $_membershipCard');
      print('Membership types: $_membershipTypes');
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check membership status: $e';
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (Get.previousRoute.isNotEmpty) {
      Get.to(() => DashboardScreen());
      return false;
    }
    return true;
  }

  void _handleFormSubmit(Map<String, dynamic> formData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await MembershipCardService.submitMembershipApplication(formData);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Membership application submitted successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh to check for the new card
        _checkMembershipCard();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to submit application: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit application: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.pink[50],
        appBar: CustomAppBar(
          title: 'Membership Card',
          icon: Icons.card_membership_outlined,
          showBackButton: true,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Membership Card',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context);
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Membership Card',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View your membership details or apply for a new membership card.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[700]!),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Error',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                              color: Colors.red[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _checkMembershipCard,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Try Again',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_membershipCard != null)
                    MembershipCardDisplay(cardData: _membershipCard!)
                  else if (_membershipTypes != null && _membershipTypes!.isNotEmpty)
                    MembershipForm(
                      onSubmit: _handleFormSubmit,
                      // membershipTypes: _membershipTypes!,
                    )
                  else
                    Center(
                      child: Text(
                        'No membership types available. Please try again later.',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_widgets/custom_navigation.dart';
// import 'package:ems/services/membership_card_services.dart';

// // Import the new widgets
// import 'package:ems/widgets/membership_widgets/membership_card_widget.dart';
// import 'package:ems/widgets/membership_widgets/membership_form_widget.dart';


// class MembershipCardScreen extends StatefulWidget {
//   const MembershipCardScreen({super.key});

//   @override
//   State<MembershipCardScreen> createState() => _MembershipCardScreenState();
// }

// class _MembershipCardScreenState extends State<MembershipCardScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _membershipCard;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _checkMembershipCard();
//   }

//   Future<void> _checkMembershipCard() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final card = await MembershipCardService.getMembershipCard();
//       setState(() {
//         _membershipCard = card;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to check membership status: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       Get.to(() => DashboardScreen());
//       return false;
//     }
//     return true;
//   }

//   void _handleFormSubmit(Map<String, dynamic> formData) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final success = await MembershipCardService.submitMembershipApplication(formData);
      
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Membership application submitted successfully!',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Refresh to check for the new card
//         _checkMembershipCard();
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Failed to submit application: $e';
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to submit application: $e',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.pink[50],
//         appBar: CustomAppBar(
//           title: 'Membership Card',
//           icon: Icons.card_membership_outlined,
//           showBackButton: true,
//           // titleStyle: GoogleFonts.poppins(
//           //   color: Colors.pink[700],
//           //   fontWeight: FontWeight.bold,
//           // ),
//           // backgroundColor: Colors.white,
//           // iconColor: Colors.pink[700],
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Membership Card',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Container(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Membership Card',
//                     style: GoogleFonts.poppins(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'View your membership details or apply for a new membership card.',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
                  
//                   if (_isLoading)
//                     Center(
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[700]!),
//                       ),
//                     )
//                   else if (_errorMessage != null)
//                     Center(
//                       child: Column(
//                         children: [
//                           Text(
//                             'Error',
//                             style: GoogleFonts.poppins(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _errorMessage!,
//                             style: GoogleFonts.poppins(
//                               color: Colors.red[700],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: _checkMembershipCard,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.pink[700],
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                             child: Text(
//                               'Try Again',
//                               style: GoogleFonts.poppins(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   else if (_membershipCard != null)
//                     MembershipCardDisplay(cardData: _membershipCard!)
//                   else
//                     MembershipForm(onSubmit: _handleFormSubmit),
                  
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }












// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_widgets/custom_navigation.dart';
// import 'package:ems/services/membership_card_services.dart';

// // Import the new widgets
// import 'package:ems/widgets/membership_widgets/membership_card_widget.dart';
// import 'package:ems/widgets/membership_widgets/membership_form_widget.dart';

// class MembershipCardScreen extends StatefulWidget {
//   const MembershipCardScreen({super.key});

//   @override
//   State<MembershipCardScreen> createState() => _MembershipCardScreenState();
// }

// class _MembershipCardScreenState extends State<MembershipCardScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _membershipCard;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _checkMembershipCard();
//   }

//   Future<void> _checkMembershipCard() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final card = await MembershipCardService.getMembershipCard();
//       setState(() {
//         _membershipCard = card;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to check membership status: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       Get.to(() => DashboardScreen());
//       return false;
//     }
//     return true;
//   }

//   void _handleFormSubmit(Map<String, dynamic> formData) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final success = await MembershipCardService.submitMembershipApplication(formData);
      
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Membership application submitted successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Refresh to check for the new card
//         _checkMembershipCard();
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Failed to submit application: $e';
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to submit application: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Membership Card',
//           icon: Icons.card_membership_outlined,
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Membership Card',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Membership Card',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'View your membership details or apply for a new membership card.',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
                
//                 if (_isLoading)
//                   const Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 else if (_errorMessage != null)
//                   Center(
//                     child: Column(
//                       children: [
//                         Text(
//                           'Error',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _errorMessage!,
//                           style: GoogleFonts.poppins(
//                             color: Colors.red[700],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _checkMembershipCard,
//                           child: const Text('Try Again'),
//                         ),
//                       ],
//                     ),
//                   )
//                 else if (_membershipCard != null)
//                   MembershipCardDisplay(cardData: _membershipCard!)
//                 else
//                   MembershipForm(onSubmit: _handleFormSubmit),
                
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';

// class MembershipCardScreen extends StatelessWidget {
//     const MembershipCardScreen({super.key});

//    Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       // Get.back();
//       Get.to(()=>DashboardScreen());
//       return false;
//     }
//     // If no previous route, let the system handle the back button
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Membership Card',
//           icon: Icons.card_membership_outlined,
//           showBackButton: true,  // Explicitly show back button
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Membership Card',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Membership Card Overview',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add attendance-specific content here
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
