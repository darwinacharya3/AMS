import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:ems/screens/AMS/home/dashboard_screen.dart';
import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';
import 'package:ems/services/membership_card_services.dart';

// Import the widgets
import 'package:ems/widgets/AMS/membership_widgets/membership_card_widget.dart';
import 'package:ems/widgets/AMS/membership_widgets/membership_form_widget.dart';

class MembershipCardScreen extends StatefulWidget {
  const MembershipCardScreen({super.key});

  @override
  State<MembershipCardScreen> createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends State<MembershipCardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _membershipCard;
  List<Map<String, dynamic>>? _membershipTypes;
  String? _qrCode;
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
      _qrCode = null;
    });

    try {
      // Get full response from API
      final response = await MembershipCardService.getRawMembershipData();

      // Check if response has qr_code at root level
      if (response.containsKey('qr_code')) {
        _qrCode = response['qr_code'];
      }
      
      // Get membership card if available
      Map<String, dynamic>? card;
      if (response.containsKey('membershipCard') && response['membershipCard'] != null) {
        card = Map<String, dynamic>.from(response['membershipCard']);
        
        // Add the QR code to the card data if we found it
        if (_qrCode != null) {
          card['qr_code'] = _qrCode;
        }
      }
      
      // Get membership types if available
      List<Map<String, dynamic>>? types;
      if (response.containsKey('membershipTypes')) {
        types = List<Map<String, dynamic>>.from(
          response['membershipTypes'].map((item) => Map<String, dynamic>.from(item))
        );
      }
      
      setState(() {
        _membershipCard = card;
        _membershipTypes = types;
        _isLoading = false;
      });
      
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
      if (mounted){
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
                    MembershipCardDisplay(
                      cardData: _membershipCard!,
                      membershipTypes: _membershipTypes,
                    )
                  else if (_membershipTypes != null && _membershipTypes!.isNotEmpty)
                    MembershipForm(
                      onSubmit: _handleFormSubmit,
                      membershipTypes: _membershipTypes,
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








