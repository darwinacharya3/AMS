import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/Providers/Extratech_oval/membership_oval_providers.dart';
import 'package:ems/services/Extratech_oval/membership_card_oval_services.dart';
import 'package:ems/services/secure_storage_service.dart';
import 'package:ems/widgets/Extratech 0val/membership_oval_form_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ems/screens/extratech-oval/login/login_screen.dart';

class GeneralMembershipScreen extends ConsumerStatefulWidget {
  const GeneralMembershipScreen({super.key});

  @override
  ConsumerState<GeneralMembershipScreen> createState() => _GeneralMembershipScreenState();
}

class _GeneralMembershipScreenState extends ConsumerState<GeneralMembershipScreen> {
  bool _isLoading = true;
  bool _hasExistingMembership = false;
  Map<String, dynamic>? _membershipData;

  @override
  void initState() {
    super.initState();
    _checkMembershipStatus();
  }

  // Check if the user already has a membership
  Future<void> _checkMembershipStatus() async {
    try {
      // Get user email from storage
      final userEmail = await SecureStorageService.getUserEmail();
      
      if (userEmail == null) {
        // If no email is saved, the user isn't properly logged in
        if (mounted) {
          _redirectToLogin();
        }
        return;
      }
      
      // Check if user has a membership card
      final membershipData = await GeneralMembershipCardService.getMembershipCard();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExistingMembership = membershipData != null;
          _membershipData = membershipData;
        });
      }
    } catch (e) {
      debugPrint('Error checking membership status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasExistingMembership = false;
        });
      }
    }
  }

  // Complete logout function (Firebase + Google Sign-In)
  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF205EB5),
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF205EB5),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
      
      setState(() {
        _isLoading = true;
      });
      
      // Sign out from Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        debugPrint('Signed out from Google');
      }
      
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      debugPrint('Signed out from Firebase');
      
      // Clear stored credentials
      await SecureStorageService.clearCredentials();
      debugPrint('Cleared secure storage');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _redirectToLogin();
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Navigate back to login screen
  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ExtratechOvalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingView()
            : _hasExistingMembership
                ? _buildMembershipCardView(_membershipData!)
                : const MembershipFormContainer(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMembershipCardView(Map<String, dynamic> membershipData) {
    // Get screen dimensions for responsive sizing
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Membership Card',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF205EB5),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            
            // Membership card container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF205EB5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Card header with logo
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/Oval Logo.png',
                          height: screenWidth * 0.12,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Extratech Oval',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'International Cricket Stadium',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Member photo and details
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      children: [
                        // Member photo
                        Container(
                          width: screenWidth * 0.25,
                          height: screenWidth * 0.25,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF205EB5), width: 2),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(
                                membershipData['photo_url'] ?? 'https://via.placeholder.com/150',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Member name
                        Text(
                          '${membershipData['first_name'] ?? ''} ${membershipData['middle_name'] ?? ''} ${membershipData['last_name'] ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        
                        // Membership type
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF205EB5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            membershipData['membership_type'] ?? 'Member',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.034,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF205EB5),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        
                        // Divider
                        const Divider(),
                        SizedBox(height: screenHeight * 0.01),
                        
                        // Membership details
                        _buildMembershipDetail(screenWidth, 'Membership ID', membershipData['membership_id']?.toString() ?? 'N/A'),
                        SizedBox(height: screenHeight * 0.01),
                        _buildMembershipDetail(screenWidth, 'Valid From', membershipData['start_date'] ?? 'N/A'),
                        SizedBox(height: screenHeight * 0.01),
                        _buildMembershipDetail(screenWidth, 'Valid Until', membershipData['expiry_date'] ?? 'N/A'),
                        SizedBox(height: screenHeight * 0.01),
                        _buildMembershipDetail(screenWidth, 'Status', membershipData['status'] == 1 ? 'Active' : 'Inactive'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            // Membership benefits
            Text(
              'Membership Benefits',
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF205EB5),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            
            _buildBenefitItem(screenWidth, screenHeight, 'Free access to all national and international games'),
            _buildBenefitItem(screenWidth, screenHeight, 'Priority booking for premium seats'),
            _buildBenefitItem(screenWidth, screenHeight, 'Access to exclusive members lounge'),
            _buildBenefitItem(screenWidth, screenHeight, 'Discounts on merchandise'),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipDetail(double screenWidth, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.035,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(double screenWidth, double screenHeight, String benefit) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: const Color(0xFF205EB5),
            size: screenWidth * 0.05,
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              benefit,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.035,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}






