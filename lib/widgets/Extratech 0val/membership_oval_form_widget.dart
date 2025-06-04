import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems/Providers/Extratech_oval/membership_oval_providers.dart';
import 'package:ems/widgets/Extratech 0val/membership_document.dart';
import 'package:ems/widgets/Extratech 0val/membership_personal_details.dart';
import 'package:ems/services/secure_storage_service.dart';

class MembershipFormContainer extends ConsumerStatefulWidget {
  const MembershipFormContainer({Key? key}) : super(key: key);

  @override
  ConsumerState<MembershipFormContainer> createState() => _MembershipFormContainerState();
}

class _MembershipFormContainerState extends ConsumerState<MembershipFormContainer> {
  int _currentStep = 0;
  final _personalDetailsFormKey = GlobalKey<FormState>();
  bool _isLoadingMembershipTypes = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _membershipTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchMembershipTypes();
    _loadUserEmail();
  }

  Future<void> _fetchMembershipTypes() async {
    setState(() {
      _isLoadingMembershipTypes = true;
      _errorMessage = '';
    });

    try {
      final membershipTypesAsync = ref.read(generalMembershipTypesProvider.future);
      final types = await membershipTypesAsync;
      
      setState(() {
        _membershipTypes = types;
        _isLoadingMembershipTypes = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load membership types: ${e.toString()}';
        _isLoadingMembershipTypes = false;
      });
    }
  }

  Future<void> _loadUserEmail() async {
    try {
      final userEmail = await SecureStorageService.getUserEmail();
      if (userEmail != null && userEmail.isNotEmpty) {
        ref.read(emailProvider.notifier).state = userEmail;
      }
    } catch (e) {
      debugPrint('Error loading user email: $e');
    }
  }

  void _handleNext() {
    if (_currentStep == 0) {
      // Validate the personal details form
      if (_personalDetailsFormKey.currentState!.validate()) {
        // Save form explicitly before moving to next step
        _personalDetailsFormKey.currentState!.save();
        
        // Log the values being passed to the next step for debugging
        debugPrint('Moving to next step with values:');
        debugPrint('First Name: ${ref.read(firstNameProvider)}');
        debugPrint('Last Name: ${ref.read(lastNameProvider)}');
        debugPrint('Email: ${ref.read(emailProvider)}');
        debugPrint('Paid Amount: ${ref.read(generalPaidAmountProvider)}');
        debugPrint('DOB: ${ref.read(dobProvider)}');
        debugPrint('Phone: ${ref.read(phoneProvider)}');
        debugPrint('Address: ${ref.read(addressProvider)}');
        debugPrint('Country ID: ${ref.read(selectedCountryIdProvider)}');
        debugPrint('State ID: ${ref.read(selectedStateIdProvider)}');
        debugPrint('Card Type ID: ${ref.read(selectedGeneralMembershipTypeProvider)}');
        
        setState(() {
          _currentStep = 1;
        });
      } else {
        // Form validation failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields correctly'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePrevious() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoadingMembershipTypes 
        ? _buildLoadingView()
        : _errorMessage.isNotEmpty
            ? _buildErrorView()
            : _buildContentView();
  }

  // Loading View
  Widget _buildLoadingView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading Membership Types...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error View
  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMembershipTypes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF205EB5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Main content view
  Widget _buildContentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Membership Registration',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF205EB5),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentStep >= 0
                        ? const Color(0xFF205EB5)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentStep >= 1
                        ? const Color(0xFF205EB5)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Step labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Personal Details',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: _currentStep == 0 ? FontWeight.w600 : FontWeight.normal,
                    color: _currentStep == 0
                        ? const Color(0xFF205EB5)
                        : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Documents',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: _currentStep == 1 ? FontWeight.w600 : FontWeight.normal,
                    color: _currentStep == 1
                        ? const Color(0xFF205EB5)
                        : Colors.grey[600],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Content based on current step
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _currentStep == 0
                  ? MembershipPersonalDetails(
                      membershipTypes: _membershipTypes,
                      formKey: _personalDetailsFormKey,
                      onNext: _handleNext,
                    )
                  : MembershipDocuments(
                      onPrevious: _handlePrevious,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}









