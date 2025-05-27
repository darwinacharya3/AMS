import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ems/models/edit_user_details.dart';
import 'package:ems/services/edit_profile_service.dart';
import 'package:ems/widgets/AMS/edit_profile_widget/residency_section.dart';
import 'package:ems/widgets/AMS/edit_profile_widget/general_info_section.dart';
import 'package:ems/widgets/AMS/edit_profile_widget/signature_section.dart';
import 'package:ems/widgets/AMS/edit_profile_widget/emergency_contact_section.dart';
import 'package:ems/utils/responsive_utils.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  // Modified constructor to accept userDetail parameter
  final EditUserDetail? userDetail;

  const EditProfileScreen({
    Key? key, 
    this.userDetail,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  bool _isSubmitting = false;
  bool _isLoading = true;
  EditUserDetail? _userDetail;
  File? _profileImage;

  // Form data
  String _name = '';
  String _gender = '1';
  String _phone = '';
  String _email = '';
  String _dob = '';
  String _birthCountry = '';
  String _birthState = '';
  String _homeAddress = '';
  String _commencementDate = '';
  String _signature = '';
  String _isAusPermanentResident = '0';
  String _countryOfLiving = '';
  String _currentStateId = '';
  String _residentialAddress = '';
  String _postCode = '';
  String _visaType = '';
  String _passportNumber = '';
  String _passportExpiryDate = '';
  String _eContactName = '';
  String _relation = '';
  String _eContactNo = '';
  String _highestEducation = '';

  // Dynamic data from API
  Map<String, String> _countriesMap = {};
  Map<String, String> _statesMap = {};
  List<String> _educationLevels = [];
  List<String> _visaTypes = [];

  @override
  void initState() {
    super.initState();
    
    // If widget.userDetail is provided, use it directly
    if (widget.userDetail != null) {
      _userDetail = widget.userDetail;
    }
    
    // Log current user and date information for debugging
    _logUserInfo();
    
    // Load all data on startup
    _loadAllData();
  }
  
  void _logUserInfo() {
    final DateTime now = DateTime.now().toUtc();
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    
    debugPrint('==========================================================');
    debugPrint('Current Date and Time (UTC): $formattedDate');
    debugPrint('Current User\'s Login: darwinacharya3');
    debugPrint('==========================================================');
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Log the start of data loading
      debugPrint('Starting to load profile data...');
      
      // If we don't already have user detail from constructor, fetch it from API
      if (_userDetail == null) {
        await _fetchProfileData();
      } else {
        debugPrint('Using provided userDetail from constructor');
      }
      
      // Then load all the supporting data in parallel
      await Future.wait([
        _fetchCountries(),
        _fetchStates(),
        _fetchEducationLevels(),
        _fetchVisaTypes(),
      ]);
      
      // Once all data is loaded, initialize the form
      _initializeFormData();
      
      debugPrint('Successfully loaded all profile data');
    } catch (e) {
      // Log error to console instead of showing snackbar
      debugPrint('Error loading data: $e');
      
      if (mounted) {
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeFormData() {
    if (_userDetail == null) {
      debugPrint('Cannot initialize form data: User detail is null');
      return;
    }
    
    _name = _userDetail!.name;
    _gender = _userDetail!.gender;
    _phone = _userDetail!.mobileNo;
    _email = _userDetail!.email;
    _dob = _userDetail!.dob;
    _birthCountry = _userDetail!.countryOfBirth;
    _birthState = _userDetail!.birthStateId;
    _homeAddress = _userDetail!.birthResidentialAddress;
    _commencementDate = _userDetail!.commencementDate;
    _signature = _userDetail!.signature;
    _isAusPermanentResident = _userDetail!.isAusPermanentResident;
    _countryOfLiving = _userDetail!.countryOfLiving;
    _currentStateId = _userDetail!.currentStateId;
    _residentialAddress = _userDetail!.residentialAddress;
    _postCode = _userDetail!.postCode;
    _visaType = _userDetail!.visaType;
    _passportNumber = _userDetail!.passportNumber;
    _passportExpiryDate = _userDetail!.passportExpiryDate;
    _eContactName = _userDetail!.eContactName;
    _relation = _userDetail!.relation;
    _eContactNo = _userDetail!.eContactNo;
    _highestEducation = _userDetail!.highestEducation;
    
    // Log form data for debugging
    debugPrint('Form data initialized:');
    debugPrint('Name: $_name');
    debugPrint('Email: $_email');
    debugPrint('Gender: $_gender');
    debugPrint('Editable fields: ${_userDetail!.editableFields}');
  }

  Future<void> _fetchProfileData() async {
    try {
      debugPrint('Fetching user profile data...');
      final userDetail = await _profileService.getUserProfile();
      
      if (mounted) {
        setState(() {
          _userDetail = userDetail;
        });
        debugPrint('User profile data received successfully');
      }
    } catch (e) {
      debugPrint('Failed to fetch profile: $e');
      rethrow; // Re-throw to be caught by the caller
    }
  }

  Future<void> _fetchCountries() async {
    try {
      debugPrint('Fetching countries data...');
      final countries = await _profileService.getCountries();
      
      if (mounted) {
        setState(() {
          _countriesMap = countries;
        });
        debugPrint('Countries data received: ${countries.length} countries');
      }
    } catch (e) {
      debugPrint('Failed to fetch countries: $e');
      rethrow;
    }
  }

  Future<void> _fetchStates() async {
    try {
      debugPrint('Fetching states data...');
      final states = await _profileService.getStates();
      
      if (mounted) {
        setState(() {
          _statesMap = states;
        });
        debugPrint('States data received: ${states.length} states');
      }
    } catch (e) {
      debugPrint('Failed to fetch states: $e');
      rethrow;
    }
  }

  Future<void> _fetchEducationLevels() async {
    try {
      debugPrint('Fetching education levels...');
      final educationLevels = await _profileService.getEducationLevels();
      
      if (mounted) {
        setState(() {
          _educationLevels = educationLevels;
        });
        debugPrint('Education levels received: ${educationLevels.length} levels');
      }
    } catch (e) {
      debugPrint('Failed to fetch education levels: $e');
      rethrow;
    }
  }

  Future<void> _fetchVisaTypes() async {
    try {
      debugPrint('Fetching visa types...');
      final visaTypes = await _profileService.getVisaTypes();
      
      if (mounted) {
        setState(() {
          _visaTypes = visaTypes;
        });
        debugPrint('Visa types received: ${visaTypes.length} types');
      }
    } catch (e) {
      debugPrint('Failed to fetch visa types: $e');
      rethrow;
    }
  }

  Future<void> _saveProfile() async {
    if (_userDetail == null) {
      debugPrint('Cannot save profile: User detail is null');
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      debugPrint('==== SUBMITTING PROFILE DATA ====');
      final DateTime now = DateTime.now().toUtc();
      final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      debugPrint('Current Date and Time (UTC): $formattedDate');
      debugPrint('Current User\'s Login: darwinacharya3');
      
      // Log all form data for debugging
      debugPrint('User ID: ${_userDetail!.userId}');
      debugPrint('Student ID: ${_userDetail!.studentId}');
      debugPrint('Name: $_name');
      debugPrint('Email: $_email');
      debugPrint('Gender: $_gender');
      debugPrint('Phone: $_phone');
      debugPrint('Date of Birth: $_dob');
      debugPrint('Country of Birth: $_birthCountry');
      debugPrint('Birth State: $_birthState');
      debugPrint('Home Address: $_homeAddress');
      debugPrint('Commencement Date: $_commencementDate');
      debugPrint('Signature: $_signature');
      debugPrint('Highest Education: $_highestEducation');
      debugPrint('Is AUS Permanent Resident: $_isAusPermanentResident');
      debugPrint('Country of Living: $_countryOfLiving');
      debugPrint('Residential Address: $_residentialAddress');
      debugPrint('Post Code: $_postCode');
      debugPrint('Visa Type: $_visaType');
      debugPrint('Current State: $_currentStateId');
      debugPrint('Passport Number: $_passportNumber');
      debugPrint('Passport Expiry Date: $_passportExpiryDate');
      debugPrint('Emergency Contact Name: $_eContactName');
      debugPrint('Relation: $_relation');
      debugPrint('Emergency Contact Number: $_eContactNo');
      debugPrint('Profile Image: ${_profileImage?.path ?? "No new image"}');
      
      final success = await _profileService.updateUserProfile(
        name: _name,
        email: _email,
        status: _userDetail!.status,
        userId: _userDetail!.userId,
        studentId: _userDetail!.studentId,
        gender: _gender,
        mobileNo: _phone,
        dob: _dob,
        countryOfBirth: _birthCountry,
        birthStateId: _birthState,
        birthResidentialAddress: _homeAddress,
        commencementDate: _commencementDate,
        signature: _signature,
        isAusPermanentResident: _isAusPermanentResident,
        countryOfLiving: _countryOfLiving,
        residentialAddress: _residentialAddress,
        postCode: _postCode,
        visaType: _visaType,
        currentStateId: _currentStateId,
        passportNumber: _passportNumber,
        passportExpiryDate: _passportExpiryDate,
        eContactName: _eContactName,
        relation: _relation,
        eContactNo: _eContactNo,
        highestEducation: _highestEducation,
        profileImage: _profileImage,
      );
      
      if (mounted) {
        if (success) {
          debugPrint('Profile updated successfully');
          
          // Show subtle success indicator
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back after successful update
          Navigator.pop(context, true);
        } else {
          debugPrint('Failed to update profile: API returned unsuccessful status');
          setState(() {
            _isSubmitting = false;
          });
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile. Please try again.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateGeneralInfo(
    String name,
    String gender,
    String phone,
    String email,
    String dob,
    String birthCountry,
    String birthState,
    String homeAddress,
    String commencementDate,
    String highestEducation,
    File? profileImage,
  ) {
    setState(() {
      _name = name;
      _gender = gender;
      _phone = phone;
      _email = email;
      _dob = dob;
      _birthCountry = birthCountry;
      _birthState = birthState;
      _homeAddress = homeAddress;
      _commencementDate = commencementDate;
      _highestEducation = highestEducation;
      if (profileImage != null) {
        _profileImage = profileImage;
        debugPrint('Profile image updated in parent: ${profileImage.path}');
      }
    });
  }

  void _updateSignature(String signature) {
    setState(() {
      _signature = signature;
    });
  }

  void _updateResidencyInfo(
    String isAusPermanentResident,
    String countryOfLiving,
    String currentStateId,
    String residentialAddress,
    String postCode,
    String visaType,
    String passportNumber,
    String passportExpiryDate,
  ) {
    setState(() {
      _isAusPermanentResident = isAusPermanentResident;
      _countryOfLiving = countryOfLiving;
      _currentStateId = currentStateId;
      _residentialAddress = residentialAddress;
      _postCode = postCode;
      _visaType = visaType;
      _passportNumber = passportNumber;
      _passportExpiryDate = passportExpiryDate;
    });
  }

  void _updateEmergencyContact(
    String eContactName,
    String relation,
    String eContactNo,
  ) {
    setState(() {
      _eContactName = eContactName;
      _relation = relation;
      _eContactNo = eContactNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Profile',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile data...'),
                ],
              ),
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    // Check if we have all required data before rendering the form
    if (_userDetail == null) {
      debugPrint('User detail is null, cannot render form');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error: Could not load profile data',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final bool hasRequiredData = 
        _countriesMap.isNotEmpty && 
        _statesMap.isNotEmpty && 
        _educationLevels.isNotEmpty && 
        _visaTypes.isNotEmpty;

    if (!hasRequiredData) {
      debugPrint('Required data missing, cannot render form');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Warning: Some reference data could not be loaded',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getFormWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Debug timestamp - only visible in debug mode
                if (kDebugMode)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug Info (${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc())})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('User: darwinacharya3'),
                        Text('ID: ${_userDetail!.id}'),
                        Text('API: ${ProfileService.baseUrl}'),
                      ],
                    ),
                  ),
                
                GeneralInfoSection(
                  edituserDetail: _userDetail!,
                  onSave: _updateGeneralInfo,
                  countriesMap: _countriesMap,
                  statesMap: _statesMap,
                  educationLevels: _educationLevels,
                ),
                const SizedBox(height: 24),
                SignatureSection(
                  edituserDetail: _userDetail!,
                  onSave: _updateSignature,
                ),
                const SizedBox(height: 24),
                ResidencySection(
                  edituserDetail: _userDetail!,
                  onSave: _updateResidencyInfo,
                  countriesMap: _countriesMap,
                  statesMap: _statesMap,
                  visaTypes: _visaTypes,
                ),
                const SizedBox(height: 24),
                EmergencyContactSection(
                  edituserDetail: _userDetail!,
                  onSave: _updateEmergencyContact,
                ),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _saveProfile,
      icon: _isSubmitting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.check),
      label: Text(
        'Save & Continue',
        style: GoogleFonts.poppins(
          fontSize: 16, 
          fontWeight: FontWeight.w500
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2), // Blue color
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}


















// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:ems/models/edit_user_details.dart';
// import 'package:ems/services/edit_profile_service.dart';
// import 'package:ems/widgets/AMS/edit_profile_widget/residency_section.dart';
// import 'package:ems/widgets/AMS/edit_profile_widget/general_info_section.dart';
// import 'package:ems/widgets/AMS/edit_profile_widget/signature_section.dart';
// import 'package:ems/widgets/AMS/edit_profile_widget/emergency_contact_section.dart';
// import 'package:ems/utils/responsive_utils.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';

// class EditProfileScreen extends StatefulWidget {
//   // Modified constructor to accept userDetail parameter
//   final EditUserDetail? userDetail;

//   const EditProfileScreen({
//     Key? key, 
//     this.userDetail,
//   }) : super(key: key);

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _profileService = ProfileService();
//   bool _isSubmitting = false;
//   bool _isLoading = true;
//   EditUserDetail? _userDetail;
//   File? _profileImage;

//   // Form data
//   String _name = '';
//   String _gender = '1';
//   String _phone = '';
//   String _email = '';
//   String _dob = '';
//   String _birthCountry = '';
//   String _birthState = '';
//   String _homeAddress = '';
//   String _commencementDate = '';
//   String _signature = '';
//   String _isAusPermanentResident = '0';
//   String _countryOfLiving = '';
//   String _currentStateId = '';
//   String _residentialAddress = '';
//   String _postCode = '';
//   String _visaType = '';
//   String _passportNumber = '';
//   String _passportExpiryDate = '';
//   String _eContactName = '';
//   String _relation = '';
//   String _eContactNo = '';
//   String _highestEducation = '';

//   // Dynamic data from API
//   Map<String, String> _countriesMap = {};
//   Map<String, String> _statesMap = {};
//   List<String> _educationLevels = [];
//   List<String> _visaTypes = [];

//   @override
//   void initState() {
//     super.initState();
    
//     // If widget.userDetail is provided, use it directly
//     if (widget.userDetail != null) {
//       _userDetail = widget.userDetail;
//     }
    
//     // Log current user and date information for debugging
//     _logUserInfo();
    
//     // Load all data on startup
//     _loadAllData();
//   }
  
//   void _logUserInfo() {
//     final DateTime now = DateTime.now().toUtc();
//     final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    
//     debugPrint('==========================================================');
//     debugPrint('Current Date and Time (UTC): $formattedDate');
//     debugPrint('Current User\'s Login: darwinacharya3');
//     debugPrint('==========================================================');
//   }

//   Future<void> _loadAllData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Log the start of data loading
//       debugPrint('Starting to load profile data...');
      
//       // If we don't already have user detail from constructor, fetch it from API
//       if (_userDetail == null) {
//         await _fetchProfileData();
//       } else {
//         debugPrint('Using provided userDetail from constructor');
//       }
      
//       // Then load all the supporting data in parallel
//       await Future.wait([
//         _fetchCountries(),
//         _fetchStates(),
//         _fetchEducationLevels(),
//         _fetchVisaTypes(),
//       ]);
      
//       // Once all data is loaded, initialize the form
//       _initializeFormData();
      
//       debugPrint('Successfully loaded all profile data');
//     } catch (e) {
//       // Log error to console instead of showing snackbar
//       debugPrint('Error loading data: $e');
      
//       if (mounted) {
//         // Show error message to user
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error loading data: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _initializeFormData() {
//     if (_userDetail == null) {
//       debugPrint('Cannot initialize form data: User detail is null');
//       return;
//     }
    
//     _name = _userDetail!.name;
//     _gender = _userDetail!.gender;
//     _phone = _userDetail!.mobileNo;
//     _email = _userDetail!.email;
//     _dob = _userDetail!.dob;
//     _birthCountry = _userDetail!.countryOfBirth;
//     _birthState = _userDetail!.birthStateId;
//     _homeAddress = _userDetail!.birthResidentialAddress;
//     _commencementDate = _userDetail!.commencementDate;
//     _signature = _userDetail!.signature;
//     _isAusPermanentResident = _userDetail!.isAusPermanentResident;
//     _countryOfLiving = _userDetail!.countryOfLiving;
//     _currentStateId = _userDetail!.currentStateId;
//     _residentialAddress = _userDetail!.residentialAddress;
//     _postCode = _userDetail!.postCode;
//     _visaType = _userDetail!.visaType;
//     _passportNumber = _userDetail!.passportNumber;
//     _passportExpiryDate = _userDetail!.passportExpiryDate;
//     _eContactName = _userDetail!.eContactName;
//     _relation = _userDetail!.relation;
//     _eContactNo = _userDetail!.eContactNo;
//     _highestEducation = _userDetail!.highestEducation;
    
//     // Log form data for debugging
//     debugPrint('Form data initialized:');
//     debugPrint('Name: $_name');
//     debugPrint('Email: $_email');
//     debugPrint('Gender: $_gender');
//     debugPrint('Editable fields: ${_userDetail!.editableFields}');
//   }

//   Future<void> _fetchProfileData() async {
//     try {
//       debugPrint('Fetching user profile data...');
//       final userDetail = await _profileService.getUserProfile();
      
//       if (mounted) {
//         setState(() {
//           _userDetail = userDetail;
//         });
//         debugPrint('User profile data received successfully');
//       }
//     } catch (e) {
//       debugPrint('Failed to fetch profile: $e');
//       rethrow; // Re-throw to be caught by the caller
//     }
//   }

//   Future<void> _fetchCountries() async {
//     try {
//       debugPrint('Fetching countries data...');
//       final countries = await _profileService.getCountries();
      
//       if (mounted) {
//         setState(() {
//           _countriesMap = countries;
//         });
//         debugPrint('Countries data received: ${countries.length} countries');
//       }
//     } catch (e) {
//       debugPrint('Failed to fetch countries: $e');
//       rethrow;
//     }
//   }

//   Future<void> _fetchStates() async {
//     try {
//       debugPrint('Fetching states data...');
//       final states = await _profileService.getStates();
      
//       if (mounted) {
//         setState(() {
//           _statesMap = states;
//         });
//         debugPrint('States data received: ${states.length} states');
//       }
//     } catch (e) {
//       debugPrint('Failed to fetch states: $e');
//       rethrow;
//     }
//   }

//   Future<void> _fetchEducationLevels() async {
//     try {
//       debugPrint('Fetching education levels...');
//       final educationLevels = await _profileService.getEducationLevels();
      
//       if (mounted) {
//         setState(() {
//           _educationLevels = educationLevels;
//         });
//         debugPrint('Education levels received: ${educationLevels.length} levels');
//       }
//     } catch (e) {
//       debugPrint('Failed to fetch education levels: $e');
//       rethrow;
//     }
//   }

//   Future<void> _fetchVisaTypes() async {
//     try {
//       debugPrint('Fetching visa types...');
//       final visaTypes = await _profileService.getVisaTypes();
      
//       if (mounted) {
//         setState(() {
//           _visaTypes = visaTypes;
//         });
//         debugPrint('Visa types received: ${visaTypes.length} types');
//       }
//     } catch (e) {
//       debugPrint('Failed to fetch visa types: $e');
//       rethrow;
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (_userDetail == null) {
//       debugPrint('Cannot save profile: User detail is null');
//       return;
//     }
    
//     if (!_formKey.currentState!.validate()) {
//       debugPrint('Form validation failed');
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       debugPrint('==== SUBMITTING PROFILE DATA ====');
//       final DateTime now = DateTime.now().toUtc();
//       final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
//       debugPrint('Current Date and Time (UTC): $formattedDate');
//       debugPrint('Current User\'s Login: darwinacharya3');
      
//       // Log all form data for debugging
//       debugPrint('User ID: ${_userDetail!.userId}');
//       debugPrint('Student ID: ${_userDetail!.studentId}');
//       debugPrint('Name: $_name');
//       debugPrint('Email: $_email');
//       debugPrint('Gender: $_gender');
//       debugPrint('Phone: $_phone');
//       debugPrint('Date of Birth: $_dob');
//       debugPrint('Country of Birth: $_birthCountry');
//       debugPrint('Birth State: $_birthState');
//       debugPrint('Home Address: $_homeAddress');
//       debugPrint('Commencement Date: $_commencementDate');
//       debugPrint('Signature: $_signature');
//       debugPrint('Highest Education: $_highestEducation');
//       debugPrint('Is AUS Permanent Resident: $_isAusPermanentResident');
//       debugPrint('Country of Living: $_countryOfLiving');
//       debugPrint('Residential Address: $_residentialAddress');
//       debugPrint('Post Code: $_postCode');
//       debugPrint('Visa Type: $_visaType');
//       debugPrint('Current State: $_currentStateId');
//       debugPrint('Passport Number: $_passportNumber');
//       debugPrint('Passport Expiry Date: $_passportExpiryDate');
//       debugPrint('Emergency Contact Name: $_eContactName');
//       debugPrint('Relation: $_relation');
//       debugPrint('Emergency Contact Number: $_eContactNo');
//       debugPrint('Profile Image: ${_profileImage?.path ?? "No new image"}');
      
//       final success = await _profileService.updateUserProfile(
//         name: _name,
//         email: _email,
//         status: _userDetail!.status,
//         userId: _userDetail!.userId,
//         studentId: _userDetail!.studentId,
//         gender: _gender,
//         mobileNo: _phone,
//         dob: _dob,
//         countryOfBirth: _birthCountry,
//         birthStateId: _birthState,
//         birthResidentialAddress: _homeAddress,
//         commencementDate: _commencementDate,
//         signature: _signature,
//         isAusPermanentResident: _isAusPermanentResident,
//         countryOfLiving: _countryOfLiving,
//         residentialAddress: _residentialAddress,
//         postCode: _postCode,
//         visaType: _visaType,
//         currentStateId: _currentStateId,
//         passportNumber: _passportNumber,
//         passportExpiryDate: _passportExpiryDate,
//         eContactName: _eContactName,
//         relation: _relation,
//         eContactNo: _eContactNo,
//         highestEducation: _highestEducation,
//         profileImage: _profileImage,
//       );
      
//       if (mounted) {
//         if (success) {
//           debugPrint('Profile updated successfully');
          
//           // Show subtle success indicator
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Profile updated successfully'),
//               duration: Duration(seconds: 2),
//               backgroundColor: Colors.green,
//             ),
//           );
          
//           // Navigate back after successful update
//           Navigator.pop(context, true);
//         } else {
//           debugPrint('Failed to update profile: API returned unsuccessful status');
//           setState(() {
//             _isSubmitting = false;
//           });
          
//           // Show error message
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Failed to update profile. Please try again.'),
//               duration: Duration(seconds: 2),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error updating profile: $e');
      
//       if (mounted) {
//         setState(() {
//           _isSubmitting = false;
//         });
        
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             duration: const Duration(seconds: 3),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Rest of the code remains the same...
  
//   void _updateGeneralInfo(
//     String name,
//     String gender,
//     String phone,
//     String email,
//     String dob,
//     String birthCountry,
//     String birthState,
//     String homeAddress,
//     String commencementDate,
//     String highestEducation,
//     File? profileImage,
//   ) {
//     setState(() {
//       _name = name;
//       _gender = gender;
//       _phone = phone;
//       _email = email;
//       _dob = dob;
//       _birthCountry = birthCountry;
//       _birthState = birthState;
//       _homeAddress = homeAddress;
//       _commencementDate = commencementDate;
//       _highestEducation = highestEducation;
//       if (profileImage != null) {
//         _profileImage = profileImage;
//         debugPrint('Profile image updated in parent: ${profileImage.path}');
//       }
//     });
//   }

//   void _updateSignature(String signature) {
//     setState(() {
//       _signature = signature;
//     });
//   }

//   void _updateResidencyInfo(
//     String isAusPermanentResident,
//     String countryOfLiving,
//     String currentStateId,
//     String residentialAddress,
//     String postCode,
//     String visaType,
//     String passportNumber,
//     String passportExpiryDate,
//   ) {
//     setState(() {
//       _isAusPermanentResident = isAusPermanentResident;
//       _countryOfLiving = countryOfLiving;
//       _currentStateId = currentStateId;
//       _residentialAddress = residentialAddress;
//       _postCode = postCode;
//       _visaType = visaType;
//       _passportNumber = passportNumber;
//       _passportExpiryDate = passportExpiryDate;
//     });
//   }

//   void _updateEmergencyContact(
//     String eContactName,
//     String relation,
//     String eContactNo,
//   ) {
//     setState(() {
//       _eContactName = eContactName;
//       _relation = relation;
//       _eContactNo = eContactNo;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Edit Profile',
//         showBackButton: true,
//       ),
//       body: _isLoading
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading profile data...'),
//                 ],
//               ),
//             )
//           : _buildForm(),
//     );
//   }

//   Widget _buildForm() {
//     // Check if we have all required data before rendering the form
//     if (_userDetail == null) {
//       debugPrint('User detail is null, cannot render form');
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 48, color: Colors.red),
//             const SizedBox(height: 16),
//             const Text(
//               'Error: Could not load profile data',
//               style: TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadAllData,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       );
//     }

//     final bool hasRequiredData = 
//         _countriesMap.isNotEmpty && 
//         _statesMap.isNotEmpty && 
//         _educationLevels.isNotEmpty && 
//         _visaTypes.isNotEmpty;

//     if (!hasRequiredData) {
//       debugPrint('Required data missing, cannot render form');
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 48, color: Colors.amber),
//             const SizedBox(height: 16),
//             const Text(
//               'Warning: Some reference data could not be loaded',
//               style: TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadAllData,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: ResponsiveUtils.getScreenPadding(context),
//         child: Center(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxWidth: ResponsiveUtils.getFormWidth(context),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Debug timestamp - only visible in debug mode
//                 if (kDebugMode)
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Debug Info (${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc())})',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text('User: darwinacharya3'),
//                         Text('ID: ${_userDetail!.id}'),
//                         Text('API: ${ProfileService.baseUrl}'),
//                       ],
//                     ),
//                   ),
                
//                 GeneralInfoSection(
//                   edituserDetail: _userDetail!,
//                   onSave: _updateGeneralInfo,
//                   countriesMap: _countriesMap,
//                   statesMap: _statesMap,
//                   educationLevels: _educationLevels,
//                 ),
//                 const SizedBox(height: 24),
//                 SignatureSection(
//                   edituserDetail: _userDetail!,
//                   onSave: _updateSignature,
//                 ),
//                 const SizedBox(height: 24),
//                 ResidencySection(
//                   edituserDetail: _userDetail!,
//                   onSave: _updateResidencyInfo,
//                   countriesMap: _countriesMap,
//                   statesMap: _statesMap,
//                   visaTypes: _visaTypes,
//                 ),
//                 const SizedBox(height: 24),
//                 EmergencyContactSection(
//                   edituserDetail: _userDetail!,
//                   onSave: _updateEmergencyContact,
//                 ),
//                 const SizedBox(height: 32),
//                 _buildSaveButton(),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSaveButton() {
//     return ElevatedButton.icon(
//       onPressed: _isSubmitting ? null : _saveProfile,
//       icon: _isSubmitting
//           ? const SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 2,
//               ),
//             )
//           : const Icon(Icons.check),
//       label: Text(
//         'Save & Continue',
//         style: GoogleFonts.poppins(
//           fontSize: 16, 
//           fontWeight: FontWeight.w500
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF1976D2), // Blue color
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }

















// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/edit_user_details.dart';
// import 'package:ems/services/edit_profile_service.dart';
// import 'package:ems/widgets/AMS/edit_profile_widget/residency_section.dart';
// import 'package:ems/widgets/AMS/edit_profile_widget/general_info_section.dart';
// import 'package:ems/widgets/AMS/edit_profile_widget/signature_section.dart';
// import 'package:ems/widgets/AMS/edit_profile_widget/emergency_contact_section.dart';
// import 'package:ems/utils/responsive_utils.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';

// class EditProfileScreen extends StatefulWidget {
//   final EditUserDetail userDetail;

//   const EditProfileScreen({
//     Key? key,
//     required this.userDetail,
//   }) : super(key: key);

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _profileService = ProfileService();
//   bool _isSubmitting = false;
//   bool _isLoading = true;
//   late EditUserDetail _userDetail;
//   File? _profileImage;

//   // Form data
//   String _name = '';
//   String _gender = '1';
//   String _phone = '';
//   String _email = '';
//   String _dob = '';
//   String _birthCountry = '';
//   String _birthState = '';
//   String _homeAddress = '';
//   String _commencementDate = '';
//   String _signature = '';
//   String _isAusPermanentResident = '0';
//   String _countryOfLiving = '';
//   String _currentStateId = '';
//   String _residentialAddress = '';
//   String _postCode = '';
//   String _visaType = '';
//   String _passportNumber = '';
//   String _passportExpiryDate = '';
//   String _eContactName = '';
//   String _relation = '';
//   String _eContactNo = '';
//   String _highestEducation = '';

//   // Dynamic data from API
//   Map<String, String> _countriesMap = {};
//   Map<String, String> _statesMap = {};
//   List<String> _educationLevels = [];
//   List<String> _visaTypes = [];

//   @override
//   void initState() {
//     super.initState();
//     _userDetail = widget.userDetail;
//     _loadAllData();
//   }

//   Future<void> _loadAllData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Load all required data in parallel
//       await Future.wait([
//         _fetchProfileData(),
//         _fetchCountries(),
//         _fetchStates(),
//         _fetchEducationLevels(),
//         _fetchVisaTypes(),
//       ]);
      
//       // Once all data is loaded, initialize the form
//       _initializeFormData();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading data: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _initializeFormData() {
//     _name = _userDetail.name;
//     _gender = _userDetail.gender;
//     _phone = _userDetail.mobileNo;
//     _email = _userDetail.email;
//     _dob = _userDetail.dob;
//     _birthCountry = _userDetail.countryOfBirth;
//     _birthState = _userDetail.birthStateId;
//     _homeAddress = _userDetail.birthResidentialAddress;
//     _commencementDate = _userDetail.commencementDate;
//     _signature = _userDetail.signature;
//     _isAusPermanentResident = _userDetail.isAusPermanentResident;
//     _countryOfLiving = _userDetail.countryOfLiving;
//     _currentStateId = _userDetail.currentStateId;
//     _residentialAddress = _userDetail.residentialAddress;
//     _postCode = _userDetail.postCode;
//     _visaType = _userDetail.visaType;
//     _passportNumber = _userDetail.passportNumber;
//     _passportExpiryDate = _userDetail.passportExpiryDate;
//     _eContactName = _userDetail.eContactName;
//     _relation = _userDetail.relation;
//     _eContactNo = _userDetail.eContactNo;
//     _highestEducation = _userDetail.highestEducation;
//   }

//   Future<void> _fetchProfileData() async {
//     try {
//       final userDetail = await _profileService.getUserProfile();
//       if (mounted) {
//         setState(() {
//           _userDetail = userDetail;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch profile: ${e.toString()}')),
//         );
//       }
//       rethrow; // Re-throw to be caught by the caller
//     }
//   }

//   Future<void> _fetchCountries() async {
//     try {
//       final countries = await _profileService.getCountries();
//       if (mounted) {
//         setState(() {
//           _countriesMap = countries;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch countries: ${e.toString()}')),
//         );
//       }
//       rethrow;
//     }
//   }

//   Future<void> _fetchStates() async {
//     try {
//       final states = await _profileService.getStates();
//       if (mounted) {
//         setState(() {
//           _statesMap = states;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch states: ${e.toString()}')),
//         );
//       }
//       rethrow;
//     }
//   }

//   Future<void> _fetchEducationLevels() async {
//     try {
//       final educationLevels = await _profileService.getEducationLevels();
//       if (mounted) {
//         setState(() {
//           _educationLevels = educationLevels;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch education levels: ${e.toString()}')),
//         );
//       }
//       rethrow;
//     }
//   }

//   Future<void> _fetchVisaTypes() async {
//     try {
//       final visaTypes = await _profileService.getVisaTypes();
//       if (mounted) {
//         setState(() {
//           _visaTypes = visaTypes;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to fetch visa types: ${e.toString()}')),
//         );
//       }
//       rethrow;
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) {
//       // Form validation failed
//       return;
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     try {
//       final success = await _profileService.updateUserProfile(
//         name: _name,
//         email: _email,
//         status: _userDetail.status,
//         userId: _userDetail.userId,
//         studentId: _userDetail.studentId,
//         gender: _gender,
//         mobileNo: _phone,
//         dob: _dob,
//         countryOfBirth: _birthCountry,
//         birthStateId: _birthState,
//         birthResidentialAddress: _homeAddress,
//         commencementDate: _commencementDate,
//         signature: _signature,
//         isAusPermanentResident: _isAusPermanentResident,
//         countryOfLiving: _countryOfLiving,
//         residentialAddress: _residentialAddress,
//         postCode: _postCode,
//         visaType: _visaType,
//         currentStateId: _currentStateId,
//         passportNumber: _passportNumber,
//         passportExpiryDate: _passportExpiryDate,
//         eContactName: _eContactName,
//         relation: _relation,
//         eContactNo: _eContactNo,
//         highestEducation: _highestEducation,
//         profileImage: _profileImage,
//       );
      
//       if (mounted) {
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//           Navigator.pop(context, true);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to update profile')),
//           );
//           setState(() {
//             _isSubmitting = false;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
//         );
//         setState(() {
//           _isSubmitting = false;
//         });
//       }
//     }
//   }

//   void _updateGeneralInfo(
//     String name,
//     String gender,
//     String phone,
//     String email,
//     String dob,
//     String birthCountry,
//     String birthState,
//     String homeAddress,
//     String commencementDate,
//     String highestEducation,
//     File? profileImage,
//   ) {
//     setState(() {
//       _name = name;
//       _gender = gender;
//       _phone = phone;
//       _email = email;
//       _dob = dob;
//       _birthCountry = birthCountry;
//       _birthState = birthState;
//       _homeAddress = homeAddress;
//       _commencementDate = commencementDate;
//       _highestEducation = highestEducation;
//       if (profileImage != null) {
//         _profileImage = profileImage;
//       }
//     });
//   }

//   void _updateSignature(String signature) {
//     setState(() {
//       _signature = signature;
//     });
//   }

//   void _updateResidencyInfo(
//     String isAusPermanentResident,
//     String countryOfLiving,
//     String currentStateId,
//     String residentialAddress,
//     String postCode,
//     String visaType,
//     String passportNumber,
//     String passportExpiryDate,
//   ) {
//     setState(() {
//       _isAusPermanentResident = isAusPermanentResident;
//       _countryOfLiving = countryOfLiving;
//       _currentStateId = currentStateId;
//       _residentialAddress = residentialAddress;
//       _postCode = postCode;
//       _visaType = visaType;
//       _passportNumber = passportNumber;
//       _passportExpiryDate = passportExpiryDate;
//     });
//   }

//   void _updateEmergencyContact(
//     String eContactName,
//     String relation,
//     String eContactNo,
//   ) {
//     setState(() {
//       _eContactName = eContactName;
//       _relation = relation;
//       _eContactNo = eContactNo;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Edit Profile',
//         showBackButton: true,
//       ),
//       body: _isLoading
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading profile data...'),
//                 ],
//               ),
//             )
//           : _buildForm(),
//     );
//   }

//   Widget _buildForm() {
//     // Check if we have all required data before rendering the form
//     final bool hasRequiredData = 
//         _countriesMap.isNotEmpty && 
//         _statesMap.isNotEmpty && 
//         _educationLevels.isNotEmpty && 
//         _visaTypes.isNotEmpty;

//     if (!hasRequiredData) {
//       return const Center(
//         child: Text('Error: Could not load required data'),
//       );
//     }

//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: ResponsiveUtils.getScreenPadding(context),
//         child: Center(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               maxWidth: ResponsiveUtils.getFormWidth(context),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 GeneralInfoSection(
//                   edituserDetail: _userDetail,
//                   onSave: _updateGeneralInfo,
//                   countriesMap: _countriesMap,
//                   statesMap: _statesMap,
//                   educationLevels: _educationLevels,
//                 ),
//                 const SizedBox(height: 24),
//                 SignatureSection(
//                   edituserDetail: _userDetail,
//                   onSave: _updateSignature,
//                 ),
//                 const SizedBox(height: 24),
//                 ResidencySection(
//                   edituserDetail: _userDetail,
//                   onSave: _updateResidencyInfo,
//                   countriesMap: _countriesMap,
//                   statesMap: _statesMap,
//                   visaTypes: _visaTypes,
//                 ),
//                 const SizedBox(height: 24),
//                 EmergencyContactSection(
//                   edituserDetail: _userDetail,
//                   onSave: _updateEmergencyContact,
//                 ),
//                 const SizedBox(height: 32),
//                 _buildSaveButton(),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSaveButton() {
//     return ElevatedButton.icon(
//       onPressed: _isSubmitting ? null : _saveProfile,
//       icon: _isSubmitting
//           ? const SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 2,
//               ),
//             )
//           : const Icon(Icons.check),
//       label: Text(
//         'Save & Continue',
//         style: GoogleFonts.poppins(
//           fontSize: 16, 
//           fontWeight: FontWeight.w500
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xFF1976D2), // Blue color
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }