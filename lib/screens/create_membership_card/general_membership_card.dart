import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeneralMembershipCard extends StatefulWidget {
  const GeneralMembershipCard({super.key});

  @override
  _GeneralMembershipCardState createState() => _GeneralMembershipCardState();
}

class _GeneralMembershipCardState extends State<GeneralMembershipCard> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  
  
  // Dropdown values
  int? _selectedMembershipTypeId;
  int? _selectedCountryId;
  
  // Image files
  File? _citizenshipFront;
  File? _citizenshipBack;
  File? _paymentSlip;
  File? _profile;
  
  final ImagePicker _picker = ImagePicker();

  // API data storage
  List<dynamic> _membershipTypes = [];
  List<dynamic> _countries = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Colors
  final Color _primaryColor = const Color(0xFFE94E96); // Pink color 
  final Color _backgroundColor = const Color(0xFFFAE1EC); // Light pink background
  final Color _cardColor = Colors.white;
  final Color _textColor = Colors.black87;
  final Color _accentColor = const Color(0xFF4CAF50); // Green for active status

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _paidAmountController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      await Future.wait([
        _fetchMembershipTypes(),
        _fetchCountries(),
      ]);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading data: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMembershipTypes() async {
    try {
      final response = await http.get(
        Uri.parse('https://extratech.extratechweb.com/api/student/membership-types'),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey('membershipTypes')) {
          setState(() {
            _membershipTypes = List<dynamic>.from(data['membershipTypes']);
          });
        } else if (data is List) {
          setState(() {
            _membershipTypes = data;
          });
        } else {
          // Try to find any key that might contain the membership types
          if (data is Map) {
            for (final key in data.keys) {
              if (data[key] is List && (data[key] as List).isNotEmpty) {
                setState(() {
                  _membershipTypes = List<dynamic>.from(data[key]);
                });
                break;
              }
            }
          }
        }
      } else {
        throw Exception('Failed to load membership types: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching membership types: $e');
      throw e;
    }
  }

  Future<void> _fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('https://extratech.extratechweb.com/api/student/list-countries'),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey('countries')) {
          setState(() {
            _countries = List<dynamic>.from(data['countries']);
          });
        } else if (data is List) {
          setState(() {
            _countries = data;
          });
        } else {
          // Try to find any key that might contain countries
          if (data is Map) {
            for (final key in data.keys) {
              if (data[key] is List && (data[key] as List).isNotEmpty) {
                setState(() {
                  _countries = List<dynamic>.from(data[key]);
                });
                break;
              }
            }
          }
        }
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching countries: $e');
      throw e;
    }
  }

  void _updatePaidAmount(int typeId) {
    final selectedType = _membershipTypes.firstWhere(
      (type) => type['id'] == typeId,
      orElse: () => null,
    );
    
    if (selectedType != null && selectedType.containsKey('amount')) {
      setState(() {
        _paidAmountController.text = selectedType['amount'].toString();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd MMM. yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'citizenshipFront':
            _citizenshipFront = File(pickedFile.path);
            break;
          case 'citizenshipBack':
            _citizenshipBack = File(pickedFile.path);
            break;
          case 'paymentSlip':
            _paymentSlip = File(pickedFile.path);
            break;
          case 'profile':
            _profile = File(pickedFile.path);
            break;
        }
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Select Image Source',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.photo_library, color: _primaryColor),
                  title: Text(
                    'Gallery',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    _pickImage(ImageSource.gallery, type);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera, color: _primaryColor),
                  title: Text(
                    'Camera',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    _pickImage(ImageSource.camera, type);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEnlargedImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;
  
  // Check if all fields have values and documents are uploaded
  Map<String, String> emptyFields = {};
  
  // Check text fields
  if (_nameController.text.trim().isEmpty) emptyFields['Name'] = 'Please enter your name';
  if (_emailController.text.trim().isEmpty) emptyFields['Email'] = 'Please enter your email';
  if (_phoneController.text.trim().isEmpty) emptyFields['Phone'] = 'Please enter your phone number';
  if (_addressController.text.trim().isEmpty) emptyFields['Address'] = 'Please enter your address';
  if (_paidAmountController.text.trim().isEmpty) emptyFields['Paid Amount'] = 'Please enter the paid amount';
  if (_dobController.text.trim().isEmpty) emptyFields['Date of Birth'] = 'Please select your date of birth';
  
  // Check dropdown selections
  if (_selectedMembershipTypeId == null) emptyFields['Membership Type'] = 'Please select a membership type';
  if (_selectedCountryId == null) emptyFields['Country'] = 'Please select a country';
  
  // Check documents
  if (_citizenshipFront == null) emptyFields['Citizenship Front'] = 'Please upload citizenship front image';
  if (_citizenshipBack == null) emptyFields['Citizenship Back'] = 'Please upload citizenship back image';
  if (_paymentSlip == null) emptyFields['Payment Slip'] = 'Please upload payment slip';
  if (_profile == null) emptyFields['Profile Picture'] = 'Please upload profile picture';
  
  if (emptyFields.isNotEmpty) {
    // Display error for empty fields
    List<String> fieldNames = emptyFields.keys.take(3).toList();
    String additionalFields = emptyFields.length > 3 ? ' and ${emptyFields.length - 3} more' : '';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please complete all required fields: ${fieldNames.join(", ")}$additionalFields',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
    return;
  }
  
  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _primaryColor),
              SizedBox(height: 16),
              Text(
                'Submitting application...',
                style: GoogleFonts.poppins(color: _textColor),
              ),
            ],
          ),
        ),
      );
    },
  );
  
  try {
    // Create a multipart request with the correct API endpoint
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://extratech.extratechweb.com/api/student/store/general/membership'),
    );
    
    // Format DOB for API
    String formattedDob = _formatDateForAPI(_dobController.text.trim());
    
    // Get the selected membership type name
    final selectedType = _membershipTypes.firstWhere(
      (type) => type['id'] == _selectedMembershipTypeId,
      orElse: () => {'type': 'Unknown'},
    );
    
    // Add form fields with correct field names
    request.fields['name'] = _nameController.text.trim();
    request.fields['email'] = _emailController.text.trim();
    request.fields['phone'] = _phoneController.text.trim();
    request.fields['address'] = _addressController.text.trim();
    request.fields['amount'] = _paidAmountController.text.trim();  // Changed from paid_amount
    request.fields['dob'] = formattedDob; // Properly formatted date
    request.fields['country_id'] = _selectedCountryId.toString();
    request.fields['card_type_id'] = _selectedMembershipTypeId.toString(); // Changed from membership_type_id
    request.fields['card_type'] = selectedType['type']?.toString() ?? "General"; // Add card_type field
    
    // Set predefined values
    request.fields['created_by'] = 'darwinacharya3';
    request.fields['created_at'] = '2025-03-12 06:50:24'; // Hardcoded as specified
    
    // Add files
    request.files.add(await http.MultipartFile.fromPath(
      'citizenship_front', _citizenshipFront!.path));
    
    request.files.add(await http.MultipartFile.fromPath(
      'citizenship_back', _citizenshipBack!.path));
    
    request.files.add(await http.MultipartFile.fromPath(
      'payment_slip', _paymentSlip!.path));
    
    request.files.add(await http.MultipartFile.fromPath(
      'profile', _profile!.path));
    
    // Set headers
    request.headers.addAll({
      'Accept': 'application/json',
    });
    
    // Send request
    var response = await request.send();
    
    // Get response
    var responseData = await response.stream.bytesToString();
    print('API Response: $responseData');
    
    // Handle response
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Success
      // Make sure we close the loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Membership application submitted successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Clear form fields to avoid resubmission
      _clearForm();
      
      // Delay navigation to ensure the snackbar is visible
      Future.delayed(const Duration(seconds: 2), () {
        // Navigate back to previous screen
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
    } else {
      // Error
      // Make sure we close the loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Try to extract error message from response
      String errorMessage = 'Error submitting application';
      try {
        final responseJson = json.decode(responseData);
        if (responseJson.containsKey('message')) {
          errorMessage = '${responseJson['message']}';
        }
      } catch (e) {
        errorMessage = 'Error: ${response.statusCode}';
      }
      
      // Show error with details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  } catch (e) {
    // Make sure we close the loading dialog if it's still open
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error: $e',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    print('Exception: $e');
  }
}

// Helper method to clear form after successful submission
void _clearForm() {
  setState(() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _paidAmountController.clear();
    _dobController.clear();
    _selectedCountryId = null;
    _selectedMembershipTypeId = null;
    _citizenshipFront = null;
    _citizenshipBack = null;
    _paymentSlip = null;
    _profile = null;
  });
  _formKey.currentState?.reset();
}

// Helper method to format the date for the API
String _formatDateForAPI(String displayDate) {
  try {
    // Parse the display date format (e.g., "12 Mar. 2025")
    final DateFormat displayFormat = DateFormat('dd MMM. yyyy');
    final DateTime parsedDate = displayFormat.parse(displayDate);
    
    // Format to API required format (YYYY-MM-DD)
    final DateFormat apiFormat = DateFormat('yyyy-MM-dd');
    return apiFormat.format(parsedDate);
  } catch (e) {
    print('Error formatting date: $e');
    // Return current date as fallback
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}

  Widget _buildImageUploadField(String label, String type, File? imageFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showImageSourceActionSheet(context, type),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            height: 120,
            width: double.infinity,
            child: imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        color: _primaryColor,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose File',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () => _showEnlargedImage(context, imageFile),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Row(
                            children: [
                              // Zoom button
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Delete button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    switch (type) {
                                      case 'citizenshipFront':
                                        _citizenshipFront = null;
                                        break;
                                      case 'citizenshipBack':
                                        _citizenshipBack = null;
                                        break;
                                      case 'paymentSlip':
                                        _paymentSlip = null;
                                        break;
                                      case 'profile':
                                        _profile = null;
                                        break;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey.shade700,
      ),
      prefixIcon: Icon(icon, color: _primaryColor),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Helper method to format membership type display text
  String _getMembershipTypeDisplay(dynamic type) {
    try {
      String displayText = type['type'] ?? 'Unknown';
      
      if (type.containsKey('currency') && type.containsKey('amount')) {
        displayText += ' - ${type['currency']} ${type['amount']}';
      } else if (type.containsKey('amount')) {
        displayText += ' - ${type['amount']}';
      }
      
      return displayText;
    } catch (e) {
      return 'Unknown Membership Type';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.computer, color: _primaryColor),
            const SizedBox(width: 8),
            Text(
              'Membership Card',
              style: GoogleFonts.poppins(
                color: _primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: _textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Create Membership Card',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            Text(
              'Fill in the details to create a new membership card',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Show loading indicator if data is loading
            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: _primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Loading data...',
                      style: GoogleFonts.poppins(color: _primaryColor),
                    )
                  ],
                ),
              )
            else if (_hasError)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: GoogleFonts.poppins(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                      ),
                      child: Text('Retry', style: GoogleFonts.poppins()),
                    )
                  ],
                ),
              )
            else
              // Card Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // General tab indicator
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: _primaryColor, width: 2),
                          ),
                        ),
                        child: Text(
                          'General',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: _getInputDecoration('Name', Icons.person),
                        style: GoogleFonts.poppins(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: _getInputDecoration('Email', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        decoration: _getInputDecoration('Phone', Icons.phone),
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.poppins(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Address field
                      TextFormField(
                        controller: _addressController,
                        decoration: _getInputDecoration('Address', Icons.location_on),
                        style: GoogleFonts.poppins(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Membership Type dropdown - FIXED
                      DropdownButtonFormField<int>(
                        decoration: _getInputDecoration('Membership Type', Icons.card_membership),
                        value: _selectedMembershipTypeId,
                        hint: Text('Select Type', style: GoogleFonts.poppins()),
                                                style: GoogleFonts.poppins(color: _textColor),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                        isExpanded: true, // Prevents overflow
                        menuMaxHeight: 300, // Limits menu height
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedMembershipTypeId = newValue;
                              _updatePaidAmount(newValue);
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a membership type';
                          }
                          return null;
                        },
                        items: _membershipTypes.map<DropdownMenuItem<int>>((dynamic type) {
                          return DropdownMenuItem<int>(
                            value: type['id'] as int,
                            child: Text(
                              _getMembershipTypeDisplay(type),
                              style: GoogleFonts.poppins(color: _textColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Paid Amount field
                      TextFormField(
                        controller: _paidAmountController,
                        decoration: _getInputDecoration('Paid Amount', Icons.payment),
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the paid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // DOB field
                      TextFormField(
                        controller: _dobController,
                        decoration: _getInputDecoration('Date of Birth', Icons.calendar_today),
                        style: GoogleFonts.poppins(),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Country dropdown - FIXED
                      DropdownButtonFormField<int>(
                        decoration: _getInputDecoration('Select Country', Icons.public),
                        value: _selectedCountryId,
                        hint: Text('Select Country', style: GoogleFonts.poppins(color: _textColor)),
                        style: GoogleFonts.poppins(color: _textColor),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                        isExpanded: true, // Prevents overflow
                        menuMaxHeight: 300, // Limits menu height
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedCountryId = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a country';
                          }
                          return null;
                        },
                        items: _countries.map<DropdownMenuItem<int>>((dynamic country) {
                          final countryId = country['id'] is String 
                              ? int.tryParse(country['id']) 
                              : country['id'] as int;
                          
                          return DropdownMenuItem<int>(
                            value: countryId,
                            child: Text(
                              country['name'].toString(),
                              style: GoogleFonts.poppins(color: _textColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                   
                      const SizedBox(height: 24),
                      
                      // Image upload fields
                      Text(
                        'Upload Documents',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildImageUploadField('Citizenship Front', 'citizenshipFront', _citizenshipFront),
                      _buildImageUploadField('Citizenship Back', 'citizenshipBack', _citizenshipBack),
                      _buildImageUploadField('Payment Slip', 'paymentSlip', _paymentSlip),
                      _buildImageUploadField('Profile', 'profile', _profile),
                      
                      // // Divider
                      // Divider(color: Colors.grey.shade300, thickness: 1),
                      // const SizedBox(height: 16),
                      
                      // Submit button - Updated with full validation
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Create Membership Card',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class GeneralMembershipCard extends StatefulWidget {
//   const GeneralMembershipCard({super.key});

//   @override
//   _GeneralMembershipCardState createState() => _GeneralMembershipCardState();
// }

// class _GeneralMembershipCardState extends State<GeneralMembershipCard> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Form controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _paidAmountController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
  
  
//   // Dropdown values
//   int? _selectedMembershipTypeId;
//   int? _selectedCountryId;
  
//   // Image files
//   File? _citizenshipFront;
//   File? _citizenshipBack;
//   File? _paymentSlip;
//   File? _profile;
  
//   final ImagePicker _picker = ImagePicker();

//   // API data storage
//   List<dynamic> _membershipTypes = [];
//   List<dynamic> _countries = [];
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';
  
//   // Colors
//   final Color _primaryColor = const Color(0xFFE94E96); // Pink color 
//   final Color _backgroundColor = const Color(0xFFFAE1EC); // Light pink background
//   final Color _cardColor = Colors.white;
//   final Color _textColor = Colors.black87;
//   final Color _accentColor = const Color(0xFF4CAF50); // Green for active status

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _paidAmountController.dispose();
//     _dobController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });
    
//     try {
//       await Future.wait([
//         _fetchMembershipTypes(),
//         _fetchCountries(),
//       ]);
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _errorMessage = 'Error loading data: $e';
//       });
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error loading data: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchMembershipTypes() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://extratech.extratechweb.com/api/student/membership-types'),
//         headers: {
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
        
//         if (data is Map && data.containsKey('membershipTypes')) {
//           setState(() {
//             _membershipTypes = List<dynamic>.from(data['membershipTypes']);
//           });
//         } else if (data is List) {
//           setState(() {
//             _membershipTypes = data;
//           });
//         } else {
//           // Try to find any key that might contain the membership types
//           if (data is Map) {
//             for (final key in data.keys) {
//               if (data[key] is List && (data[key] as List).isNotEmpty) {
//                 setState(() {
//                   _membershipTypes = List<dynamic>.from(data[key]);
//                 });
//                 break;
//               }
//             }
//           }
//         }
//       } else {
//         throw Exception('Failed to load membership types: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching membership types: $e');
//       throw e;
//     }
//   }

//   Future<void> _fetchCountries() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://extratech.extratechweb.com/api/student/list-countries'),
//         headers: {
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
        
//         if (data is Map && data.containsKey('countries')) {
//           setState(() {
//             _countries = List<dynamic>.from(data['countries']);
//           });
//         } else if (data is List) {
//           setState(() {
//             _countries = data;
//           });
//         } else {
//           // Try to find any key that might contain countries
//           if (data is Map) {
//             for (final key in data.keys) {
//               if (data[key] is List && (data[key] as List).isNotEmpty) {
//                 setState(() {
//                   _countries = List<dynamic>.from(data[key]);
//                 });
//                 break;
//               }
//             }
//           }
//         }
//       } else {
//         throw Exception('Failed to load countries: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching countries: $e');
//       throw e;
//     }
//   }

//   void _updatePaidAmount(int typeId) {
//     final selectedType = _membershipTypes.firstWhere(
//       (type) => type['id'] == typeId,
//       orElse: () => null,
//     );
    
//     if (selectedType != null && selectedType.containsKey('amount')) {
//       setState(() {
//         _paidAmountController.text = selectedType['amount'].toString();
//       });
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: _primaryColor,
//               onPrimary: Colors.white,
//               onSurface: _textColor,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: _primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         _dobController.text = DateFormat('dd MMM. yyyy').format(picked);
//       });
//     }
//   }

//   Future<void> _pickImage(ImageSource source, String type) async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: source,
//       imageQuality: 80,
//     );
    
//     if (pickedFile != null) {
//       setState(() {
//         switch (type) {
//           case 'citizenshipFront':
//             _citizenshipFront = File(pickedFile.path);
//             break;
//           case 'citizenshipBack':
//             _citizenshipBack = File(pickedFile.path);
//             break;
//           case 'paymentSlip':
//             _paymentSlip = File(pickedFile.path);
//             break;
//           case 'profile':
//             _profile = File(pickedFile.path);
//             break;
//         }
//       });
//     }
//   }

//   void _showImageSourceActionSheet(BuildContext context, String type) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Text(
//                   'Select Image Source',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: _textColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ListTile(
//                   leading: Icon(Icons.photo_library, color: _primaryColor),
//                   title: Text(
//                     'Gallery',
//                     style: GoogleFonts.poppins(),
//                   ),
//                   onTap: () {
//                     _pickImage(ImageSource.gallery, type);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.photo_camera, color: _primaryColor),
//                   title: Text(
//                     'Camera',
//                     style: GoogleFonts.poppins(),
//                   ),
//                   onTap: () {
//                     _pickImage(ImageSource.camera, type);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showEnlargedImage(BuildContext context, File imageFile) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           insetPadding: const EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Stack(
//                 alignment: Alignment.topRight,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.file(
//                       imageFile,
//                       fit: BoxFit.contain,
//                       height: MediaQuery.of(context).size.height * 0.6,
//                       width: double.infinity,
//                     ),
//                   ),
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: InkWell(
//                       onTap: () => Navigator.of(context).pop(),
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.black45,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildImageUploadField(String label, String type, File? imageFile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: _textColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () => _showImageSourceActionSheet(context, type),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             height: 120,
//             width: double.infinity,
//             child: imageFile == null
//                 ? Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.add_photo_alternate,
//                         color: _primaryColor,
//                         size: 36,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Choose File',
//                         style: GoogleFonts.poppins(
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   )
//                 : GestureDetector(
//                     onTap: () => _showEnlargedImage(context, imageFile),
//                     child: Stack(
//                       alignment: Alignment.bottomRight,
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.file(
//                             imageFile,
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: double.infinity,
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 8,
//                           right: 8,
//                           child: Row(
//                             children: [
//                               // Zoom button
//                               Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black45,
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: const Icon(
//                                   Icons.zoom_in,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // Delete button
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     switch (type) {
//                                       case 'citizenshipFront':
//                                         _citizenshipFront = null;
//                                         break;
//                                       case 'citizenshipBack':
//                                         _citizenshipBack = null;
//                                         break;
//                                       case 'paymentSlip':
//                                         _paymentSlip = null;
//                                         break;
//                                       case 'profile':
//                                         _profile = null;
//                                         break;
//                                     }
//                                   });
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(4),
//                                   decoration: BoxDecoration(
//                                     color: Colors.black45,
//                                     borderRadius: BorderRadius.circular(16),
//                                   ),
//                                   child: const Icon(
//                                     Icons.delete,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   InputDecoration _getInputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: GoogleFonts.poppins(
//         color: Colors.grey.shade700,
//       ),
//       prefixIcon: Icon(icon, color: _primaryColor),
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: _primaryColor, width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: _textColor,
//         elevation: 0,
//         title: Row(
//           children: [
//             Icon(Icons.computer, color: _primaryColor),
//             const SizedBox(width: 8),
//             Text(
//               'Membership Card',
//               style: GoogleFonts.poppins(
//                 color: _primaryColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: _primaryColor),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.menu, color: _textColor),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Text(
//               'Create Membership Card',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: _textColor,
//               ),
//             ),
//             Text(
//               'Fill in the details to create a new membership card',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 24),
            
//             // Show loading indicator if data is loading
//             if (_isLoading)
//               Center(
//                 child: Column(
//                   children: [
//                     CircularProgressIndicator(color: _primaryColor),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Loading data...',
//                       style: GoogleFonts.poppins(color: _primaryColor),
//                     )
//                   ],
//                 ),
//               )
//             else if (_hasError)
//               Center(
//                 child: Column(
//                   children: [
//                     Icon(Icons.error_outline, color: Colors.red, size: 48),
//                     const SizedBox(height: 16),
//                     Text(
//                       _errorMessage,
//                       style: GoogleFonts.poppins(color: Colors.red),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _fetchData,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _primaryColor,
//                       ),
//                       child: Text('Retry', style: GoogleFonts.poppins()),
//                     )
//                   ],
//                 ),
//               )
//             else
//               // Card Container
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: _cardColor,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 0,
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // General tab indicator
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         decoration: BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(color: _primaryColor, width: 2),
//                           ),
//                         ),
//                         child: Text(
//                           'General',
//                           style: GoogleFonts.poppins(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: _primaryColor,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
                      
//                       // Name field
//                       TextFormField(
//                         controller: _nameController,
//                         decoration: _getInputDecoration('Name', Icons.person),
//                         style: GoogleFonts.poppins(),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your name';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Email field
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: _getInputDecoration('Email', Icons.email),
//                         keyboardType: TextInputType.emailAddress,
//                         style: GoogleFonts.poppins(),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                             return 'Please enter a valid email address';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Phone field
//                       TextFormField(
//                         controller: _phoneController,
//                         decoration: _getInputDecoration('Phone', Icons.phone),
//                         keyboardType: TextInputType.phone,
//                         style: GoogleFonts.poppins(),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your phone number';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Address field
//                       TextFormField(
//                         controller: _addressController,
//                         decoration: _getInputDecoration('Address', Icons.location_on),
//                         style: GoogleFonts.poppins(),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your address';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Membership Type dropdown - FIXED
//                       DropdownButtonFormField<int>(
//                         decoration: _getInputDecoration('Membership Type', Icons.card_membership),
//                         value: _selectedMembershipTypeId,
//                         hint: Text('Select Type', style: GoogleFonts.poppins()),
//                         style: GoogleFonts.poppins(color: _textColor),
//                         dropdownColor: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
//                         isExpanded: true, // Prevents overflow
//                         menuMaxHeight: 300, // Limits menu height
//                         onChanged: (int? newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               _selectedMembershipTypeId = newValue;
//                               _updatePaidAmount(newValue);
//                             });
//                           }
//                         },
//                         validator: (value) {
//                           if (value == null) {
//                             return 'Please select a membership type';
//                           }
//                           return null;
//                         },
//                         items: _membershipTypes.map<DropdownMenuItem<int>>((dynamic type) {
//                           return DropdownMenuItem<int>(
//                             value: type['id'] as int,
//                             child: Text(
//                               _getMembershipTypeDisplay(type),
//                               style: GoogleFonts.poppins(color: _textColor),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Paid Amount field
//                       TextFormField(
//                         controller: _paidAmountController,
//                         decoration: _getInputDecoration('Paid Amount(AUD/NPR)', Icons.payment),
//                         keyboardType: TextInputType.number,
//                         style: GoogleFonts.poppins(),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter the paid amount(AUD/NPR)';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // DOB field
//                       TextFormField(
//                         controller: _dobController,
//                         decoration: _getInputDecoration('Date of Birth', Icons.calendar_today),
//                         style: GoogleFonts.poppins(),
//                         readOnly: true,
//                         onTap: () => _selectDate(context),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please select your date of birth';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
                      
//                       // Country dropdown - FIXED
//                       DropdownButtonFormField<int>(
//                         decoration: _getInputDecoration('Select Country', Icons.public),
//                         value: _selectedCountryId,
//                         hint: Text('Select Country', style: GoogleFonts.poppins(color: _textColor)),
//                         style: GoogleFonts.poppins(color: _textColor),
//                         dropdownColor: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
//                         isExpanded: true, // Prevents overflow
//                         menuMaxHeight: 300, // Limits menu height
//                         onChanged: (int? newValue) {
//                           setState(() {
//                             _selectedCountryId = newValue;
//                           });
//                         },
//                         validator: (value) {
//                           if (value == null) {
//                             return 'Please select a country';
//                           }
//                           return null;
//                         },
//                         items: _countries.map<DropdownMenuItem<int>>((dynamic country) {
//                           final countryId = country['id'] is String 
//                               ? int.tryParse(country['id']) 
//                               : country['id'] as int;
                          
//                           return DropdownMenuItem<int>(
//                             value: countryId,
//                             child: Text(
//                               country['name'].toString(),
//                               style: GoogleFonts.poppins(color: _textColor),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           );
//                         }).toList(),
//                       ),
                   
//                       const SizedBox(height: 24),
                      
//                       // Image upload fields
//                       Text(
//                         'Upload Documents',
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: _textColor,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildImageUploadField('Citizenship Front', 'citizenshipFront', _citizenshipFront),
//                       _buildImageUploadField('Citizenship Back', 'citizenshipBack', _citizenshipBack),
//                       _buildImageUploadField('Payment Slip', 'paymentSlip', _paymentSlip),
//                       _buildImageUploadField('Profile', 'profile', _profile),
                      
//                       // Divider
//                       Divider(color: Colors.grey.shade300, thickness: 1),
//                       const SizedBox(height: 16),

//                      // Replace your current Submit button code with this:

//                     // Submit button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // First check form field validation
//                           bool isFormValid = _formKey.currentState!.validate();
                          
//                           // Check if all fields have values
//                           Map<String, String> emptyFields = {};
                          
//                           // Check text fields
//                           if (_nameController.text.trim().isEmpty) emptyFields['Name'] = 'Please enter your name';
//                           if (_emailController.text.trim().isEmpty) emptyFields['Email'] = 'Please enter your email';
//                           if (_phoneController.text.trim().isEmpty) emptyFields['Phone'] = 'Please enter your phone number';
//                           if (_addressController.text.trim().isEmpty) emptyFields['Address'] = 'Please enter your address';
//                           if (_paidAmountController.text.trim().isEmpty) emptyFields['Paid Amount'] = 'Please enter the paid amount';
//                           if (_dobController.text.trim().isEmpty) emptyFields['Date of Birth'] = 'Please select your date of birth';
                          
//                           // Check dropdown selections
//                           if (_selectedMembershipTypeId == null) emptyFields['Membership Type'] = 'Please select a membership type';
//                           if (_selectedCountryId == null) emptyFields['Country'] = 'Please select a country';
                          
//                           // Check documents
//                           if (_citizenshipFront == null) emptyFields['Citizenship Front'] = 'Please upload citizenship front image';
//                           if (_citizenshipBack == null) emptyFields['Citizenship Back'] = 'Please upload citizenship back image';
//                           if (_paymentSlip == null) emptyFields['Payment Slip'] = 'Please upload payment slip';
//                           if (_profile == null) emptyFields['Profile Picture'] = 'Please upload profile picture';
                          
//                           // Show error if any fields are empty
//                           if (emptyFields.isNotEmpty) {
//                             // Get the first few field names that are empty
//                             List<String> fieldNames = emptyFields.keys.take(3).toList();
//                             String additionalFields = emptyFields.length > 3 ? ' and ${emptyFields.length - 3} more' : '';
                            
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'Please complete all required fields: ${fieldNames.join(", ")}$additionalFields',
//                                   style: GoogleFonts.poppins(),
//                                 ),
//                                 backgroundColor: Colors.red,
//                                 behavior: SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 duration: const Duration(seconds: 4),
//                                 action: SnackBarAction(
//                                   label: 'DISMISS',
//                                   textColor: Colors.white,
//                                   onPressed: () {},
//                                 ),
//                               ),
//                             );
//                             return;
//                           }
                          
//                           // If we get here, all validations passed
//                           if (isFormValid) {
//                             // All fields are valid and all documents are uploaded, handle submission logic
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'Membership card created successfully!',
//                                   style: GoogleFonts.poppins(),
//                                 ),
//                                 backgroundColor: _accentColor,
//                                 behavior: SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             );
                            
//                             // Here you would normally call your API to submit the form
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _primaryColor,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: Text(
//                           'Create Membership Card',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
                      
//                       //  // Submit button
//                       // SizedBox(
//                       //   width: double.infinity,
//                       //   child: ElevatedButton(
//                       //     onPressed: () {
//                       //       if (_formKey.currentState!.validate()) {
//                       //         // Form is valid, handle submission logic later
//                       //         ScaffoldMessenger.of(context).showSnackBar(
//                       //           SnackBar(
//                       //             content: Text(
//                       //               'Membership card created successfully!',
//                       //               style: GoogleFonts.poppins(),
//                       //             ),
//                       //             backgroundColor: _accentColor,
//                       //             behavior: SnackBarBehavior.floating,
//                       //             shape: RoundedRectangleBorder(
//                       //               borderRadius: BorderRadius.circular(10),
//                       //             ),
//                       //           ),
//                       //         );
//                       //       }
//                       //     },
//                       //     style: ElevatedButton.styleFrom(
//                       //       backgroundColor: _primaryColor,
//                       //       foregroundColor: Colors.white,
//                       //       padding: const EdgeInsets.symmetric(vertical: 16),
//                       //       shape: RoundedRectangleBorder(
//                       //         borderRadius: BorderRadius.circular(12),
//                       //       ),
//                       //       elevation: 0,
//                       //     ),
//                       //     child: Text(
//                       //       'Create Membership Card',
//                       //       style: GoogleFonts.poppins(
//                       //         fontSize: 16,
//                       //         fontWeight: FontWeight.w600,
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//                ],
//         ),
//       ),
//     );
//   }

//   // Helper method to format membership type display text
//   String _getMembershipTypeDisplay(dynamic type) {
//     try {
//       String displayText = type['type'] ?? 'Unknown';
      
//       if (type.containsKey('currency') && type.containsKey('amount')) {
//         displayText += ' - ${type['currency']} ${type['amount']}';
//       } else if (type.containsKey('amount')) {
//         displayText += ' - ${type['amount']}';
//       }
      
//       return displayText;
//     } catch (e) {
//       return 'Unknown Membership Type';
//     }
//   }
// }
          


















// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class GeneralMembershipCard extends StatefulWidget {
//   const GeneralMembershipCard({super.key});

//   @override
//   _GeneralMembershipCardState createState() => _GeneralMembershipCardState();
// }

// class _GeneralMembershipCardState extends State<GeneralMembershipCard> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Form controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _paidAmountController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
  
//   // Dropdown values
//   int? _selectedMembershipTypeId;
//   int? _selectedCountryId;
  
//   // Image files
//   File? _citizenshipFront;
//   File? _citizenshipBack;
//   File? _paymentSlip;
//   File? _profile;
  
//   final ImagePicker _picker = ImagePicker();

//   // API data storage
//   List<dynamic> _membershipTypes = [];
//   List<dynamic> _countries = [];
//   bool _isLoading = true;

//   // Colors
//   final Color _primaryColor = const Color(0xFFE94E96); // Pink color 
//   final Color _backgroundColor = const Color(0xFFFAE1EC); // Light pink background
//   final Color _cardColor = Colors.white;
//   final Color _textColor = Colors.black87;
//   final Color _accentColor = const Color(0xFF4CAF50); // Green for active status

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _paidAmountController.dispose();
//     _dobController.dispose();
//     super.dispose();
//   }

//   @override
// void initState() {
//   super.initState();
//   _fetchData();
// }

// Future<void> _fetchData() async {
//   setState(() {
//     _isLoading = true;
//   });
  
//   try {
//     await Future.wait([
//       _fetchMembershipTypes(),
//       _fetchCountries(),
//     ]);
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Error loading data: $e'),
//         backgroundColor: Colors.red,
//       ),
//     );
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

// Future<void> _fetchMembershipTypes() async {
//   final response = await http.get(
//     Uri.parse('https://extratech.extratechweb.com/api/student/membership-types'),
//     headers: {
//       'Accept': 'application/json',
//     },
//   );
  
//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     setState(() {
//       if (data is Map && data.containsKey('types')) {
//         _membershipTypes = data['types'];
//       } else if (data is List) {
//         _membershipTypes = data;
//       }
//     });
//   } else {
//     throw Exception('Failed to load membership types: ${response.statusCode}');
//   }
// }

// Future<void> _fetchCountries() async {
//   final response = await http.get(
//     Uri.parse('https://extratech.extratechweb.com/api/student/list-countries'),
//     headers: {
//       'Accept': 'application/json',
//     },
//   );
  
//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     setState(() {
//       if (data is Map && data.containsKey('countries')) {
//         _countries = data['countries'];
//       } else if (data is List) {
//         _countries = data;
//       }
//     });
//   } else {
//     throw Exception('Failed to load countries: ${response.statusCode}');
//   }
// }

// // Helper method to update paid amount when membership type is selected
// void _updatePaidAmount(int typeId) {
//   final selectedType = _membershipTypes.firstWhere(
//     (type) => type['id'] == typeId,
//     orElse: () => null,
//   );
  
//   if (selectedType != null && selectedType.containsKey('amount')) {
//     setState(() {
//       _paidAmountController.text = selectedType['amount'].toString();
//     });
//   }
// }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: _primaryColor,
//               onPrimary: Colors.white,
//               onSurface: _textColor,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: _primaryColor,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         _dobController.text = DateFormat('dd MMM. yyyy').format(picked);
//       });
//     }
//   }

//   Future<void> _pickImage(ImageSource source, String type) async {
//     final XFile? pickedFile = await _picker.pickImage(
//       source: source,
//       imageQuality: 80,
//     );
    
//     if (pickedFile != null) {
//       setState(() {
//         switch (type) {
//           case 'citizenshipFront':
//             _citizenshipFront = File(pickedFile.path);
//             break;
//           case 'citizenshipBack':
//             _citizenshipBack = File(pickedFile.path);
//             break;
//           case 'paymentSlip':
//             _paymentSlip = File(pickedFile.path);
//             break;
//           case 'profile':
//             _profile = File(pickedFile.path);
//             break;
//         }
//       });
//     }
//   }

//   void _showImageSourceActionSheet(BuildContext context, String type) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Text(
//                   'Select Image Source',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: _textColor,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ListTile(
//                   leading: Icon(Icons.photo_library, color: _primaryColor),
//                   title: Text(
//                     'Gallery',
//                     style: GoogleFonts.poppins(),
//                   ),
//                   onTap: () {
//                     _pickImage(ImageSource.gallery, type);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.photo_camera, color: _primaryColor),
//                   title: Text(
//                     'Camera',
//                     style: GoogleFonts.poppins(),
//                   ),
//                   onTap: () {
//                     _pickImage(ImageSource.camera, type);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showEnlargedImage(BuildContext context, File imageFile) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           insetPadding: const EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Stack(
//                 alignment: Alignment.topRight,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.file(
//                       imageFile,
//                       fit: BoxFit.contain,
//                       height: MediaQuery.of(context).size.height * 0.6,
//                       width: double.infinity,
//                     ),
//                   ),
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: InkWell(
//                       onTap: () => Navigator.of(context).pop(),
//                       child: Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: Colors.black45,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Icon(
//                           Icons.close,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildImageUploadField(String label, String type, File? imageFile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//             color: _textColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () => _showImageSourceActionSheet(context, type),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             height: 120,
//             width: double.infinity,
//             child: imageFile == null
//                 ? Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.add_photo_alternate,
//                         color: _primaryColor,
//                         size: 36,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Choose File',
//                         style: GoogleFonts.poppins(
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   )
//                 : GestureDetector(
//   onTap: () => _showEnlargedImage(context, imageFile),
//   child: Stack(
//     alignment: Alignment.bottomRight,
//     children: [
//       ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Image.file(
//           imageFile,
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: double.infinity,
//         ),
//       ),
//       Positioned(
//         bottom: 8,
//         right: 8,
//         child: Row(
//           children: [
//             // Zoom button
//             Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: Colors.black45,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Icon(
//                 Icons.zoom_in,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 8),
//             // Delete button
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   switch (type) {
//                     case 'citizenshipFront':
//                       _citizenshipFront = null;
//                       break;
//                     case 'citizenshipBack':
//                       _citizenshipBack = null;
//                       break;
//                     case 'paymentSlip':
//                       _paymentSlip = null;
//                       break;
//                     case 'profile':
//                       _profile = null;
//                       break;
//                   }
//                 });
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Colors.black45,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: const Icon(
//                   Icons.delete,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   ),
// )
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   InputDecoration _getInputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: GoogleFonts.poppins(
//         color: Colors.grey.shade700,
//       ),
//       prefixIcon: Icon(icon, color: _primaryColor),
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: _primaryColor, width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: _textColor,
//         elevation: 0,
//         title: Row(
//           children: [
//             Icon(Icons.computer, color: _primaryColor),
//             const SizedBox(width: 8),
//             Text(
//               'Membership Card',
//               style: GoogleFonts.poppins(
//                 color: _primaryColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: _primaryColor),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.menu, color: _textColor),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Text(
//               'Create Membership Card',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: _textColor,
//               ),
//             ),
//             Text(
//               'Fill in the details to create a new membership card',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (_isLoading)
//               Center(
//                 child: CircularProgressIndicator(color: _primaryColor),
//               )
//             else
            
//             // Card Container
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: _cardColor,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 0,
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // General tab indicator
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(color: _primaryColor, width: 2),
//                         ),
//                       ),
//                       child: Text(
//                         'General',
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: _primaryColor,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // Name field
//                     TextFormField(
//                       controller: _nameController,
//                       decoration: _getInputDecoration('Name', Icons.person),
//                       style: GoogleFonts.poppins(),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your name';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Email field
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: _getInputDecoration('Email', Icons.email),
//                       keyboardType: TextInputType.emailAddress,
//                       style: GoogleFonts.poppins(),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                           return 'Please enter a valid email address';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Phone field
//                     TextFormField(
//                       controller: _phoneController,
//                       decoration: _getInputDecoration('Phone', Icons.phone),
//                       keyboardType: TextInputType.phone,
//                       style: GoogleFonts.poppins(),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                       ],
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your phone number';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // Address field
//                     TextFormField(
//                       controller: _addressController,
//                       decoration: _getInputDecoration('Address', Icons.location_on),
//                       style: GoogleFonts.poppins(),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your address';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     // Membership Type dropdown
//                     DropdownButtonFormField<int>(
//                       decoration: _getInputDecoration('Membership Type', Icons.card_membership),
//                       value: _selectedMembershipTypeId,
//                       hint: Text('Select Type', style: GoogleFonts.poppins()),
//                       style: GoogleFonts.poppins(),
//                       dropdownColor: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
//                       onChanged: (int? newValue) {
//                         setState(() {
//                           _selectedMembershipTypeId = newValue;
//                           if (newValue != null) {
//                             _updatePaidAmount(newValue);
//                           }
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null) {
//                           return 'Please select a membership type';
//                         }
//                         return null;
//                       },
//                       items: _membershipTypes.map<DropdownMenuItem<int>>((dynamic type) {
//                         return DropdownMenuItem<int>(
//                           value: type['id'],
//                           child: Text(
//                             '${type['type']} - ${type['currency']} ${type['amount']}',
//                             style: GoogleFonts.poppins(),
//                           ),
//                         );
//                       }).toList(),
//                     ),
                    
//                     // Paid Amount field
//                     TextFormField(
//                       controller: _paidAmountController,
//                       decoration: _getInputDecoration('Paid Amount', Icons.monetization_on),
//                       keyboardType: TextInputType.number,
//                       style: GoogleFonts.poppins(),
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                       ],
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter the paid amount';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
                    
//                     // DOB field
//                     TextFormField(
//                       controller: _dobController,
//                       decoration: _getInputDecoration('Date of Birth', Icons.calendar_today),
//                       style: GoogleFonts.poppins(),
//                       readOnly: true,
//                       onTap: () => _selectDate(context),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select your date of birth';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     // Country dropdown
//                     DropdownButtonFormField<int>(
//                       decoration: _getInputDecoration('Select Country', Icons.public),
//                       value: _selectedCountryId,
//                       hint: Text('Select Country', style: GoogleFonts.poppins()),
//                       style: GoogleFonts.poppins(),
//                       dropdownColor: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
//                       onChanged: (int? newValue) {
//                         setState(() {
//                           _selectedCountryId = newValue;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null) {
//                           return 'Please select a country';
//                         }
//                         return null;
//                       },
//                       items: _countries.map<DropdownMenuItem<int>>((dynamic country) {
//                         return DropdownMenuItem<int>(
//                           value: country['id'],
//                           child: Text(
//                             country['name'].toString(),
//                             style: GoogleFonts.poppins(),
//                           ),
//                         );
//                       }).toList(),
//                     ),
               
//                     const SizedBox(height: 24),
                    
//                     // Image upload fields
//                     Text(
//                       'Upload Documents',
//                       style: GoogleFonts.poppins(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: _textColor,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildImageUploadField('Citizenship Front', 'citizenshipFront', _citizenshipFront),
//                     _buildImageUploadField('Citizenship Back', 'citizenshipBack', _citizenshipBack),
//                     _buildImageUploadField('Payment Slip', 'paymentSlip', _paymentSlip),
//                     _buildImageUploadField('Profile', 'profile', _profile),
                    
//                     // Divider
//                     Divider(color: Colors.grey.shade300, thickness: 1),
//                     const SizedBox(height: 16),
//                      // Submit button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             // Form is valid, handle submission logic later
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'Membership card created successfully!',
//                                   style: GoogleFonts.poppins(),
//                                 ),
//                                 backgroundColor: _accentColor,
//                                 behavior: SnackBarBehavior.floating,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _primaryColor,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: Text(
//                           'Create Membership Card',
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
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
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';

// class GeneralMembershipCard extends StatefulWidget {
//   const GeneralMembershipCard({super.key});

//   @override
//   _GeneralMembershipCardState createState() => _GeneralMembershipCardState();
// }

// class _GeneralMembershipCardState extends State<GeneralMembershipCard> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Form controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _paidAmountController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _remarksController = TextEditingController();
  
//   // Dropdown values
//   String? _membershipType;
//   String? _country;
//   String? _membershipStatus = 'Active';
//   String? _status = 'Pending';
  
//   // Image files
//   File? _citizenshipFront;
//   File? _citizenshipBack;
//   File? _paymentSlip;
//   File? _profile;
  
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _paidAmountController.dispose();
//     _dobController.dispose();
//     _remarksController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }

//   Future<void> _pickImage(ImageSource source, String type) async {
//     final XFile? pickedFile = await _picker.pickImage(source: source);
    
//     if (pickedFile != null) {
//       setState(() {
//         switch (type) {
//           case 'citizenshipFront':
//             _citizenshipFront = File(pickedFile.path);
//             break;
//           case 'citizenshipBack':
//             _citizenshipBack = File(pickedFile.path);
//             break;
//           case 'paymentSlip':
//             _paymentSlip = File(pickedFile.path);
//             break;
//           case 'profile':
//             _profile = File(pickedFile.path);
//             break;
//         }
//       });
//     }
//   }

//   void _showImageSourceActionSheet(BuildContext context, String type) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   _pickImage(ImageSource.gallery, type);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   _pickImage(ImageSource.camera, type);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildImageUploadField(String label, String type, File? imageFile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () => _showImageSourceActionSheet(context, type),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             height: 100,
//             width: double.infinity,
//             child: imageFile == null
//                 ? const Center(child: Text('Choose File'))
//                 : Image.file(imageFile, fit: BoxFit.cover),
//           ),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Membership Card'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // General tab indicator
//               Container(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: Colors.blue, width: 2),
//                   ),
//                 ),
//                 child: const Text(
//                   'General',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
              
//               // Name field
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.person),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
              
//               // Email field
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                     return 'Please enter a valid email address';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
              
//               // Phone field
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.phone),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
              
//               // Address field
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(
//                   labelText: 'Address',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.location_on),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your address';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
              
//               // Membership Type dropdown
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Membership Type',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.card_membership),
//                 ),
//                 value: _membershipType,
//                 hint: const Text('Select Type'),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _membershipType = newValue;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select a membership type';
//                   }
//                   return null;
//                 },
//                 items: <String>['Type 1', 'Type 2', 'Type 3'] // Replace with API data later
//                     .map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),
              
//               // Paid Amount field
//               TextFormField(
//                 controller: _paidAmountController,
//                 decoration: const InputDecoration(
//                   labelText: 'Paid Amount',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.monetization_on),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the paid amount';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
              
//               // DOB field
//               TextFormField(
//                 controller: _dobController,
//                 decoration: const InputDecoration(
//                   labelText: 'DOB',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.calendar_today),
//                 ),
//                 readOnly: true,
//                 onTap: () => _selectDate(context),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select your date of birth';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
              
//               // Country dropdown
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Select Country',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.public),
//                 ),
//                 value: _country,
//                 hint: const Text('Select Type'),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _country = newValue;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select a country';
//                   }
//                   return null;
//                 },
//                 items: <String>['Country 1', 'Country 2', 'Country 3'] // Replace with API data later
//                     .map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),
              
//               // Membership Status dropdown
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Membership Status',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.check_circle),
//                 ),
//                 value: _membershipStatus,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _membershipStatus = newValue;
//                   });
//                 },
//                 items: <String>['Active', 'Inactive'] // Replace with API data later
//                     .map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),
              
//               // Status dropdown
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Status',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.info),
//                 ),
//                 value: _status,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _status = newValue;
//                   });
//                 },
//                 items: <String>['Pending', 'Approved', 'Rejected'] // Replace with API data later
//                     .map<DropdownMenuItem<String>>((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),
              
//               // Image upload fields
//               _buildImageUploadField('Citizenship Front', 'citizenshipFront', _citizenshipFront),
//               _buildImageUploadField('Citizenship Back', 'citizenshipBack', _citizenshipBack),
//               _buildImageUploadField('Payment Slip', 'paymentSlip', _paymentSlip),
//               _buildImageUploadField('Profile', 'profile', _profile),
              
//               // Remarks field
//               TextFormField(
//                 controller: _remarksController,
//                 decoration: const InputDecoration(
//                   labelText: 'Remarks',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.comment),
//                 ),
//                 maxLines: 4,
//               ),
//               const SizedBox(height: 24),
              
//               // Submit button
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Form is valid, handle submission logic later
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Processing Data')),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                   ),
//                   child: const Text('Submit', style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }