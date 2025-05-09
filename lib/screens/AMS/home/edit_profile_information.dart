import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/user_detail.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final UserDetail userDetail;

  const EditProfileScreen({
    Key? key,
    required this.userDetail,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _homeAddressController;
  late TextEditingController _commencementDateController;
  late TextEditingController _signatureController;
  
  // Additional controllers - initialized with empty strings
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _passportNumberController = TextEditingController();
  final TextEditingController _passportExpiryController = TextEditingController();
  final TextEditingController _emergencyNameController = TextEditingController();
  final TextEditingController _emergencyRelationController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  
  // Form values
  String _selectedGender = '1'; // Default to male
  bool _isAustralianResident = false;
  
  // Simple dropdowns
  String _selectedBirthCountry = 'Nepal';
  String _selectedBirthState = 'Bagmati';
  String _selectedCurrentCountry = 'Nepal';
  String _selectedCurrentState = 'Bagmati';
  String _selectedHighestEducation = 'SLC/SEE';
  String _selectedVisaType = 'None';
  
  // Simple lists for dropdowns
  final List<String> _countries = ['Nepal', 'Australia', 'India'];
  final List<String> _states = ['Bagmati', 'Gandaki', 'Province 1'];
  final List<String> _educationLevels = ['SLC/SEE', 'Higher Secondary', 'Bachelor', 'Master', 'PhD'];
  final List<String> _visaTypes = ['None', 'Student', 'Tourist', 'Business', 'Work', 'Other'];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    // Initialize with user details (only the ones we know exist)
    _nameController = TextEditingController(text: widget.userDetail.name);
    _phoneController = TextEditingController(text: widget.userDetail.mobileNo);
    _emailController = TextEditingController(text: widget.userDetail.email);
    _dobController = TextEditingController(text: widget.userDetail.dob);
    _homeAddressController = TextEditingController(text: widget.userDetail.birthResidentialAddress);
    _commencementDateController = TextEditingController(text: widget.userDetail.commencementDate);
    _signatureController = TextEditingController(text: widget.userDetail.name); // Using name as default signature
    
    _selectedGender = widget.userDetail.gender;
    
    // Note: The missing properties are already initialized with empty TextEditingControllers
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty 
          ? DateFormat('yyyy-MM-dd').parse(controller.text) 
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulating API call with a delay
      await Future.delayed(const Duration(seconds: 1));
      
      // We'll add the actual API integration later
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _homeAddressController.dispose();
    _commencementDateController.dispose();
    _signatureController.dispose();
    _postalCodeController.dispose();
    _passportNumberController.dispose();
    _passportExpiryController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Profile',
        // icon: Icons.edit,
        showBackButton: true,
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildSignatureSection(),
            const SizedBox(height: 24),
            _buildResidencyInformation(),
            const SizedBox(height: 24),
            _buildEmergencyContact(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('General Settings', widget.userDetail.commencementDate),
            _buildSectionSubtitle('Student personal information'),
            const SizedBox(height: 16),
            
            _buildTextField(
              label: 'Name',
              controller: _nameController, 
              validator: (value) => value!.isEmpty ? 'Name is required' : null,
            ),
            
            const SizedBox(height: 16),
            _buildGenderSelection(),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Phone',
              controller: _phoneController, 
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
            ),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email',
              controller: _emailController, 
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) return 'Email is required';
                final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                return !emailRegExp.hasMatch(value) ? 'Enter a valid email' : null;
              },
            ),
            
            const SizedBox(height: 16),
            _buildDatePicker(
              label: 'Date of Birth',
              controller: _dobController,
              validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
            ),
            
            const SizedBox(height: 16),
            _buildSimpleDropdown(
              label: 'Birth Country',
              value: _selectedBirthCountry,
              items: _countries,
              onChanged: (value) {
                setState(() {
                  _selectedBirthCountry = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            _buildSimpleDropdown(
              label: 'State',
              value: _selectedBirthState,
              items: _states,
              onChanged: (value) {
                setState(() {
                  _selectedBirthState = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Home Country Address',
              controller: _homeAddressController,
            ),
            
            const SizedBox(height: 16),
            _buildDatePicker(
              label: 'Commencement Date',
              controller: _commencementDateController,
              validator: (value) => value!.isEmpty ? 'Commencement date is required' : null,
            ),
            
            const SizedBox(height: 16),
            _buildSimpleDropdown(
              label: 'Highest Education',
              value: _selectedHighestEducation,
              items: _educationLevels,
              onChanged: (value) {
                setState(() {
                  _selectedHighestEducation = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            _buildImagePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Signature and Acceptance',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildSectionSubtitle("Student's full name as a signature"),
            const SizedBox(height: 16),
            
            _buildTextField(
              label: 'Signature',
              controller: _signatureController,
              validator: (value) => value!.isEmpty ? 'Signature is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidencyInformation() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Residency Information', widget.userDetail.commencementDate),
            _buildSectionSubtitle('Residential information'),
            const SizedBox(height: 16),
            
            _buildAustralianResidenceSelection(),
            
            const SizedBox(height: 16),
            _buildSimpleDropdown(
              label: 'Currently Living Country',
              value: _selectedCurrentCountry,
              items: _countries,
              onChanged: (value) {
                setState(() {
                  _selectedCurrentCountry = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            _buildSimpleDropdown(
              label: 'State',
              value: _selectedCurrentState,
              items: _states,
              onChanged: (value) {
                setState(() {
                  _selectedCurrentState = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Home Country Address',
              controller: _homeAddressController,
            ),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Postal Code',
              controller: _postalCodeController,
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            _buildSimpleDropdown(
              label: 'Visa Type',
              value: _selectedVisaType,
              items: _visaTypes,
              onChanged: (value) {
                setState(() {
                  _selectedVisaType = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Passport Number',
              controller: _passportNumberController,
            ),
            
            const SizedBox(height: 16),
            _buildDatePicker(
              label: 'Passport Expiry Date',
              controller: _passportExpiryController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Emergency Contact',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildSectionSubtitle('Emergency contact of student'),
            const SizedBox(height: 16),
            
            _buildTextField(
              label: 'Full Name',
              controller: _emergencyNameController,
              validator: (value) => value!.isEmpty ? 'Emergency contact name is required' : null,
            ),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Relation to Student',
              controller: _emergencyRelationController,
              validator: (value) => value!.isEmpty ? 'Relation is required' : null,
            ),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Contact No',
              controller: _emergencyContactController,
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? 'Emergency contact number is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Start | Added On',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              date,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color.fromARGB(255, 227, 10, 169),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color.fromARGB(255, 227, 10, 169),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSimpleDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  'Select ${label}',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                items: items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: onChanged,
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio(
              value: '1',
              groupValue: _selectedGender,
              activeColor: const Color.fromARGB(255, 227, 10, 169),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value as String;
                });
              },
            ),
            const Text('Male'),
            const SizedBox(width: 16),
            Radio(
              value: '2',
              groupValue: _selectedGender,
              activeColor: const Color.fromARGB(255, 227, 10, 169),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value as String;
                });
              },
            ),
            const Text('Female'),
            const SizedBox(width: 16),
            Radio(
              value: '3',
              groupValue: _selectedGender,
              activeColor: const Color.fromARGB(255, 227, 10, 169),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value as String;
                });
              },
            ),
            const Text('Other'),
          ],
        ),
      ],
    );
  }

  Widget _buildAustralianResidenceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Are you an Australian permanent residence?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio(
              value: true,
              groupValue: _isAustralianResident,
              activeColor: const Color.fromARGB(255, 227, 10, 169),
              onChanged: (value) {
                setState(() {
                  _isAustralianResident = value as bool;
                });
              },
            ),
            const Text('Yes'),
            const SizedBox(width: 16),
            Radio(
              value: false,
              groupValue: _isAustralianResident,
              activeColor: const Color.fromARGB(255, 227, 10, 169),
              onChanged: (value) {
                setState(() {
                  _isAustralianResident = value as bool;
                });
              },
            ),
            const Text('No'),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // To be implemented with image_picker
                // For now we just show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image picker will be integrated later')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Text('Choose File'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'No file chosen',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
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
        backgroundColor: const Color(0xFF1976D2), // Blue color from the image
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}