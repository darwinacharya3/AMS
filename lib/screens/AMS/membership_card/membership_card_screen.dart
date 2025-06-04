import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems/screens/AMS/home/dashboard_screen.dart';
import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';
import 'package:ems/Providers/AMS/membership_card_providers.dart';

// Import the widgets
import 'package:ems/widgets/AMS/membership_widgets/membership_card_widget.dart';
import 'package:ems/widgets/AMS/membership_widgets/membership_form_widget.dart';

class MembershipCardScreen extends ConsumerWidget {
  const MembershipCardScreen({super.key});

  Future<bool> _onWillPop() async {
    if (Get.previousRoute.isNotEmpty) {
      Get.to(() => DashboardScreen());
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the membership data using Riverpod
    final membershipDataAsync = ref.watch(membershipDataProvider);
    final membershipCardAsync = ref.watch(membershipCardProvider);
    final membershipTypesAsync = ref.watch(membershipTypesProvider);
    
    // Get screen dimensions for responsive sizing
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    
    // Calculate responsive padding based on screen size
    final double horizontalPadding = screenWidth * 0.05;
    final double verticalPadding = screenHeight * 0.025;
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: 'Membership Card',
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
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: membershipDataAsync.when(
                data: (_) {
                  return membershipCardAsync.when(
                    data: (cardData) {
                      if (cardData != null) {
                        // User has a membership card
                        return MembershipCardDisplay(
                          cardData: cardData,
                          membershipTypes: membershipTypesAsync.value ?? [],
                        );
                      } else {
                        // User doesn't have a card, show form
                        return membershipTypesAsync.when(
                          data: (types) {
                            if (types.isNotEmpty) {
                              return MembershipForm(membershipTypes: types);
                            } else {
                              return _buildNoTypesWidget(screenHeight, screenWidth);
                            }
                          },
                          loading: () => _buildLoadingWidget(screenHeight),
                          error: (error, _) => _buildErrorWidget(
                            screenSize, 
                            'Error loading membership types: $error',
                            () => ref.refresh(membershipTypesProvider),
                          ),
                        );
                      }
                    },
                    loading: () => _buildLoadingWidget(screenHeight),
                    error: (error, _) => _buildErrorWidget(
                      screenSize, 
                      'Failed to load membership card: $error',
                      () => ref.refresh(membershipCardProvider),
                    ),
                  );
                },
                loading: () => _buildLoadingWidget(screenHeight),
                error: (error, _) => _buildErrorWidget(
                  screenSize, 
                  'Failed to load membership data: $error',
                  () => ref.refresh(membershipDataProvider),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingWidget(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.7, // 70% of screen height for centering
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF205EB5)),
        ),
      ),
    );
  }
  
  Widget _buildNoTypesWidget(double screenHeight, double screenWidth) {
    return SizedBox(
      height: screenHeight * 0.5, // 50% of screen height for centering
      child: Center(
        child: Text(
          'No membership types available. Please try again later.',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
            fontSize: screenWidth * 0.04, // Responsive text size
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  Widget _buildErrorWidget(Size screenSize, String errorMessage, VoidCallback onRetry) {
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    
    return SizedBox(
      height: screenHeight * 0.7, // 70% of screen height for centering
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.05, // 5% of screen width
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // 1% of screen height
            Container(
              width: screenWidth * 0.85, // 85% of screen width
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Text(
                errorMessage,
                style: GoogleFonts.poppins(
                  color: Colors.red[700],
                  fontSize: screenWidth * 0.035, // 3.5% of screen width
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF205EB5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.05), // 5% of screen width
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08, // 8% of screen width
                  vertical: screenHeight * 0.015, // 1.5% of screen height
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04, // 4% of screen width
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';
// import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';
// import 'package:ems/services/membership_card_services.dart';
// // import 'dart:developer' as developer;

// // Import the widgets
// import 'package:ems/widgets/AMS/membership_widgets/membership_card_widget.dart';
// import 'package:ems/widgets/AMS/membership_widgets/membership_form_widget.dart';

// class MembershipCardScreen extends StatefulWidget {
//   const MembershipCardScreen({super.key});

//   @override
//   State<MembershipCardScreen> createState() => _MembershipCardScreenState();
// }

// class _MembershipCardScreenState extends State<MembershipCardScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _membershipCard;
//   List<Map<String, dynamic>>? _membershipTypes;
//   String? _qrCode;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _checkMembershipCard();
    
//     // Print a very visible message to debug
//     debugPrint('======= MEMBERSHIP CARD SCREEN INITIALIZED =======');
//   }

//   Future<void> _checkMembershipCard() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _qrCode = null;
//     });

//     try {
//       // Get full response from API
//       final response = await MembershipCardService.getRawMembershipData();

//       // Debug - Print response using debugPrint for visibility
//       debugPrint('======= MEMBERSHIP API RESPONSE =======');
//       debugPrint('Response: $response');
//       debugPrint('Response keys: ${response.keys.toList()}');
      
//       // Check if response has qr_code at root level
//       if (response.containsKey('qr_code')) {
//         _qrCode = response['qr_code'];
//         debugPrint('QR Code: $_qrCode');
//       }
      
//       // Get membership card if available
//       Map<String, dynamic>? card;
//       if (response.containsKey('membershipCard') && response['membershipCard'] != null) {
//         card = Map<String, dynamic>.from(response['membershipCard']);
        
//         // Add the QR code to the card data if we found it
//         if (_qrCode != null) {
//           card['qr_code'] = _qrCode;
//         }
        
//         debugPrint('Membership Card: $card');
//       }
      
//       // Get membership types if available
//       List<Map<String, dynamic>>? types;
//       if (response.containsKey('membershipTypes')) {
//         types = List<Map<String, dynamic>>.from(
//           response['membershipTypes'].map((item) => Map<String, dynamic>.from(item))
//         );
//         debugPrint('Membership Types: $types');
//       }
      
//       setState(() {
//         _membershipCard = card;
//         _membershipTypes = types;
//         _isLoading = false;
//       });
      
//     } catch (e) {
//       debugPrint('======= MEMBERSHIP API ERROR =======');
//       debugPrint('Error: $e');
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
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to submit application: $e',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
     
//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions for responsive sizing
//     final Size screenSize = MediaQuery.of(context).size;
//     final double screenWidth = screenSize.width;
//     final double screenHeight = screenSize.height;
    
//     // Calculate responsive padding based on screen size
//     final double horizontalPadding = screenWidth * 0.05; // 5% of screen width
//     final double verticalPadding = screenHeight * 0.025; // 2.5% of screen height
    
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: CustomAppBar(
//           title: 'Membership Card',
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Membership Card',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: horizontalPadding,
//                 vertical: verticalPadding,
//               ),
//               child: _isLoading
//                 ? SizedBox(
//                     height: screenHeight * 0.7, // 70% of screen height for centering
//                     child: const Center(
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF205EB5)),
//                       ),
//                     ),
//                   )
//                 : _errorMessage != null
//                   ? _buildErrorWidget(screenSize)
//                   : _membershipCard != null
//                     ? MembershipCardDisplay(
//                         cardData: _membershipCard!,
//                         membershipTypes: _membershipTypes,
//                       )
//                     : _membershipTypes != null && _membershipTypes!.isNotEmpty
//                       ? MembershipForm(
//                           onSubmit: _handleFormSubmit,
//                           membershipTypes: _membershipTypes,
//                         )
//                       : SizedBox(
//                           height: screenHeight * 0.5, // 50% of screen height for centering
//                           child: Center(
//                             child: Text(
//                               'No membership types available. Please try again later.',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.grey[700],
//                                 fontSize: screenWidth * 0.04, // Responsive text size
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildErrorWidget(Size screenSize) {
//     final double screenWidth = screenSize.width;
//     final double screenHeight = screenSize.height;
    
//     return SizedBox(
//       height: screenHeight * 0.7, // 70% of screen height for centering
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Error',
//               style: GoogleFonts.poppins(
//                 fontSize: screenWidth * 0.05, // 5% of screen width
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.01), // 1% of screen height
//             Container(
//               width: screenWidth * 0.85, // 85% of screen width
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//               child: Text(
//                 _errorMessage!,
//                 style: GoogleFonts.poppins(
//                   color: Colors.red[700],
//                   fontSize: screenWidth * 0.035, // 3.5% of screen width
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
//             ElevatedButton(
//               onPressed: _checkMembershipCard,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF205EB5),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(screenWidth * 0.05), // 5% of screen width
//                 ),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: screenWidth * 0.08, // 8% of screen width
//                   vertical: screenHeight * 0.015, // 1.5% of screen height
//                 ),
//               ),
//               child: Text(
//                 'Try Again',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: screenWidth * 0.04, // 4% of screen width
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';
// import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';
// import 'package:ems/services/membership_card_services.dart';
// // import 'dart:developer' as developer;

// // Import the widgets
// import 'package:ems/widgets/AMS/membership_widgets/membership_card_widget.dart';
// import 'package:ems/widgets/AMS/membership_widgets/membership_form_widget.dart';

// class MembershipCardScreen extends StatefulWidget {
//   const MembershipCardScreen({super.key});

//   @override
//   State<MembershipCardScreen> createState() => _MembershipCardScreenState();
// }

// class _MembershipCardScreenState extends State<MembershipCardScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _membershipCard;
//   List<Map<String, dynamic>>? _membershipTypes;
//   String? _qrCode;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _checkMembershipCard();
    
//     // Print a very visible message to debug
//     debugPrint('======= MEMBERSHIP CARD SCREEN INITIALIZED =======');
//   }

//   Future<void> _checkMembershipCard() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _qrCode = null;
//     });

//     try {
//       // Get full response from API
//       final response = await MembershipCardService.getRawMembershipData();

//       // Debug - Print response using debugPrint for visibility
//       debugPrint('======= MEMBERSHIP API RESPONSE =======');
//       debugPrint('Response: $response');
//       debugPrint('Response keys: ${response.keys.toList()}');
      
//       // Check if response has qr_code at root level
//       if (response.containsKey('qr_code')) {
//         _qrCode = response['qr_code'];
//         debugPrint('QR Code: $_qrCode');
//       }
      
//       // Get membership card if available
//       Map<String, dynamic>? card;
//       if (response.containsKey('membershipCard') && response['membershipCard'] != null) {
//         card = Map<String, dynamic>.from(response['membershipCard']);
        
//         // Add the QR code to the card data if we found it
//         if (_qrCode != null) {
//           card['qr_code'] = _qrCode;
//         }
        
//         debugPrint('Membership Card: $card');
//       }
      
//       // Get membership types if available
//       List<Map<String, dynamic>>? types;
//       if (response.containsKey('membershipTypes')) {
//         types = List<Map<String, dynamic>>.from(
//           response['membershipTypes'].map((item) => Map<String, dynamic>.from(item))
//         );
//         debugPrint('Membership Types: $types');
//       }
      
//       setState(() {
//         _membershipCard = card;
//         _membershipTypes = types;
//         _isLoading = false;
//       });
      
//     } catch (e) {
//       debugPrint('======= MEMBERSHIP API ERROR =======');
//       debugPrint('Error: $e');
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
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to submit application: $e',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
     
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: CustomAppBar(
//           title: 'Membership Card',
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Membership Card',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF205EB5)),
//                     ),
//                   )
//                 : _errorMessage != null
//                   ? _buildErrorWidget()
//                   : _membershipCard != null
//                     ? MembershipCardDisplay(
//                         cardData: _membershipCard!,
//                         membershipTypes: _membershipTypes,
//                       )
//                     : _membershipTypes != null && _membershipTypes!.isNotEmpty
//                       ? MembershipForm(
//                           onSubmit: _handleFormSubmit,
//                           membershipTypes: _membershipTypes,
//                         )
//                       : Center(
//                           child: Text(
//                             'No membership types available. Please try again later.',
//                             style: GoogleFonts.poppins(
//                               color: Colors.grey[700],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Error',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage!,
//             style: GoogleFonts.poppins(
//               color: Colors.red[700],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _checkMembershipCard,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF205EB5),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             child: Text(
//               'Try Again',
//               style: GoogleFonts.poppins(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';
// import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';
// import 'package:ems/services/membership_card_services.dart';

// // Import the widgets
// import 'package:ems/widgets/AMS/membership_widgets/membership_card_widget.dart';
// import 'package:ems/widgets/AMS/membership_widgets/membership_form_widget.dart';

// class MembershipCardScreen extends StatefulWidget {
//   const MembershipCardScreen({super.key});

//   @override
//   State<MembershipCardScreen> createState() => _MembershipCardScreenState();
// }

// class _MembershipCardScreenState extends State<MembershipCardScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _membershipCard;
//   List<Map<String, dynamic>>? _membershipTypes;
//   String? _qrCode;
//   String? _errorMessage;
//   String? _membershipDescription;

//   @override
//   void initState() {
//     super.initState();
//     _checkMembershipCard();
//   }

//   Future<void> _checkMembershipCard() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _qrCode = null;
//       _membershipDescription = null;
//     });

//     try {
//       // Get full response from API
//       final response = await MembershipCardService.getRawMembershipData();

//       // Check if response has qr_code at root level
//       if (response.containsKey('qr_code')) {
//         _qrCode = response['qr_code'];
//       }
      
//       // Get membership description from API
//       if (response.containsKey('description')) {
//         _membershipDescription = response['description'];
//       }
      
//       // Get membership card if available
//       Map<String, dynamic>? card;
//       if (response.containsKey('membershipCard') && response['membershipCard'] != null) {
//         card = Map<String, dynamic>.from(response['membershipCard']);
        
//         // Add the QR code to the card data if we found it
//         if (_qrCode != null) {
//           card['qr_code'] = _qrCode;
//         }
//       }
      
//       // Get membership types if available
//       List<Map<String, dynamic>>? types;
//       if (response.containsKey('membershipTypes')) {
//         types = List<Map<String, dynamic>>.from(
//           response['membershipTypes'].map((item) => Map<String, dynamic>.from(item))
//         );
//       }
      
//       setState(() {
//         _membershipCard = card;
//         _membershipTypes = types;
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
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to submit application: $e',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
     
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: CustomAppBar(
//           title: 'Membership Card',
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Membership Card',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF205EB5)),
//                     ),
//                   )
//                 : _errorMessage != null
//                   ? _buildErrorWidget()
//                   : _membershipCard != null
//                     ? MembershipCardDisplay(
//                         cardData: _membershipCard!,
//                         membershipTypes: _membershipTypes,
//                       )
//                     : _membershipTypes != null && _membershipTypes!.isNotEmpty
//                       ? MembershipForm(
//                           onSubmit: _handleFormSubmit,
//                           membershipTypes: _membershipTypes,
//                           description: _membershipDescription,
//                         )
//                       : Center(
//                           child: Text(
//                             'No membership types available. Please try again later.',
//                             style: GoogleFonts.poppins(
//                               color: Colors.grey[700],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Error',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage!,
//             style: GoogleFonts.poppins(
//               color: Colors.red[700],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _checkMembershipCard,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF205EB5),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             child: Text(
//               'Try Again',
//               style: GoogleFonts.poppins(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';
// import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';
// import 'package:ems/services/membership_card_services.dart';

// // Import the widgets
// import 'package:ems/widgets/AMS/membership_widgets/membership_card_widget.dart';
// import 'package:ems/widgets/AMS/membership_widgets/membership_form_widget.dart';

// class MembershipCardScreen extends StatefulWidget {
//   const MembershipCardScreen({super.key});

//   @override
//   State<MembershipCardScreen> createState() => _MembershipCardScreenState();
// }

// class _MembershipCardScreenState extends State<MembershipCardScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _membershipCard;
//   List<Map<String, dynamic>>? _membershipTypes;
//   String? _qrCode;
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
//       _qrCode = null;
//     });

//     try {
//       // Get full response from API
//       final response = await MembershipCardService.getRawMembershipData();

//       // Check if response has qr_code at root level
//       if (response.containsKey('qr_code')) {
//         _qrCode = response['qr_code'];
//       }
      
//       // Get membership card if available
//       Map<String, dynamic>? card;
//       if (response.containsKey('membershipCard') && response['membershipCard'] != null) {
//         card = Map<String, dynamic>.from(response['membershipCard']);
        
//         // Add the QR code to the card data if we found it
//         if (_qrCode != null) {
//           card['qr_code'] = _qrCode;
//         }
//       }
      
//       // Get membership types if available
//       List<Map<String, dynamic>>? types;
//       if (response.containsKey('membershipTypes')) {
//         types = List<Map<String, dynamic>>.from(
//           response['membershipTypes'].map((item) => Map<String, dynamic>.from(item))
//         );
//       }
      
//       setState(() {
//         _membershipCard = card;
//         _membershipTypes = types;
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
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to submit application: $e',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
     
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.white, // Set background to white
//         appBar: CustomAppBar(
//           title: 'Membership Card',
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Membership Card',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF205EB5)),
//                     ),
//                   )
//                 : _errorMessage != null
//                   ? _buildErrorWidget()
//                   : _membershipCard != null
//                     ? MembershipCardDisplay(
//                         cardData: _membershipCard!,
//                         membershipTypes: _membershipTypes,
//                       )
//                     : _membershipTypes != null && _membershipTypes!.isNotEmpty
//                       ? MembershipForm(
//                           onSubmit: _handleFormSubmit,
//                           membershipTypes: _membershipTypes,
//                         )
//                       : Center(
//                           child: Text(
//                             'No membership types available. Please try again later.',
//                             style: GoogleFonts.poppins(
//                               color: Colors.grey[700],
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Error',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _errorMessage!,
//             style: GoogleFonts.poppins(
//               color: Colors.red[700],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _checkMembershipCard,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF205EB5),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             child: Text(
//               'Try Again',
//               style: GoogleFonts.poppins(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';
// import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';
// import 'package:ems/services/membership_card_services.dart';

// // Import the widgets
// import 'package:ems/widgets/AMS/membership_widgets/membership_card_widget.dart';
// import 'package:ems/widgets/AMS/membership_widgets/membership_form_widget.dart';

// class MembershipCardScreen extends StatefulWidget {
//   const MembershipCardScreen({super.key});

//   @override
//   State<MembershipCardScreen> createState() => _MembershipCardScreenState();
// }

// class _MembershipCardScreenState extends State<MembershipCardScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _membershipCard;
//   List<Map<String, dynamic>>? _membershipTypes;
//   String? _qrCode;
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
//       _qrCode = null;
//     });

//     try {
//       // Get full response from API
//       final response = await MembershipCardService.getRawMembershipData();

//       // Check if response has qr_code at root level
//       if (response.containsKey('qr_code')) {
//         _qrCode = response['qr_code'];
//       }
      
//       // Get membership card if available
//       Map<String, dynamic>? card;
//       if (response.containsKey('membershipCard') && response['membershipCard'] != null) {
//         card = Map<String, dynamic>.from(response['membershipCard']);
        
//         // Add the QR code to the card data if we found it
//         if (_qrCode != null) {
//           card['qr_code'] = _qrCode;
//         }
//       }
      
//       // Get membership types if available
//       List<Map<String, dynamic>>? types;
//       if (response.containsKey('membershipTypes')) {
//         types = List<Map<String, dynamic>>.from(
//           response['membershipTypes'].map((item) => Map<String, dynamic>.from(item))
//         );
//       }
      
//       setState(() {
//         _membershipCard = card;
//         _membershipTypes = types;
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
//       if (mounted){
//          ScaffoldMessenger.of(context).showSnackBar(
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

//       }
     
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: CustomAppBar(
//           title: 'Membership Card',
//           // icon: Icons.card_membership_outlined,
//           showBackButton: true,
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
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF111213),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'View your membership details or apply for a new membership card.',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Color(0xFFA1A1A1),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
                  
//                   if (_isLoading)
//                     Center(
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF205EB5)),
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
//                               backgroundColor: Color(0xFF205EB5),
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
//                     MembershipCardDisplay(
//                       cardData: _membershipCard!,
//                       membershipTypes: _membershipTypes,
//                     )
//                   else if (_membershipTypes != null && _membershipTypes!.isNotEmpty)
//                     MembershipForm(
//                       onSubmit: _handleFormSubmit,
//                       membershipTypes: _membershipTypes,
//                     )
//                   else
//                     Center(
//                       child: Text(
//                         'No membership types available. Please try again later.',
//                         style: GoogleFonts.poppins(
//                           color: Colors.grey[700],
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
                  
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








