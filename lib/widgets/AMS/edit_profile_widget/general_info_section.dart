import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ems/models/edit_user_details.dart';
import 'package:ems/utils/responsive_utils.dart';

class GeneralInfoSection extends StatefulWidget {
  final EditUserDetail edituserDetail;
  final Function(
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
  ) onSave;

  final Map<String, String> countriesMap;
  final Map<String, String> statesMap;
  final List<String> educationLevels;

  const GeneralInfoSection({
    Key? key,
    required this.edituserDetail,
    required this.onSave,
    required this.countriesMap,
    required this.statesMap,
    required this.educationLevels,
  }) : super(key: key);

  @override
  State<GeneralInfoSection> createState() => _GeneralInfoSectionState();
}

class _GeneralInfoSectionState extends State<GeneralInfoSection> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _homeAddressController;
  late TextEditingController _commencementDateController;
  late String _selectedGender;
  late String _selectedBirthCountry;
  late String _selectedBirthState;
  late String _selectedHighestEducation;
  File? _profileImage;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.edituserDetail.name);
    _phoneController = TextEditingController(text: widget.edituserDetail.mobileNo);
    _emailController = TextEditingController(text: widget.edituserDetail.email);
    _dobController = TextEditingController(text: widget.edituserDetail.dob);
    _homeAddressController = TextEditingController(text: widget.edituserDetail.birthResidentialAddress);
    _commencementDateController = TextEditingController(text: widget.edituserDetail.commencementDate);
    _selectedGender = widget.edituserDetail.gender;
    _selectedBirthCountry = widget.edituserDetail.countryOfBirth;
    _selectedBirthState = widget.edituserDetail.birthStateId;
    _selectedHighestEducation = widget.edituserDetail.highestEducation;
    _profileImagePath = widget.edituserDetail.profileImage.isNotEmpty ? widget.edituserDetail.profileImage : null;
    
    // Add listeners to controllers to save data when text changes
    _nameController.addListener(_saveData);
    _phoneController.addListener(_saveData);
    _emailController.addListener(_saveData);
    _homeAddressController.addListener(_saveData);
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
        _saveData(); // Save data after date selection
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _profileImagePath = pickedFile.path;
        _saveData(); // Save data after image selection
      });
    }
  }

  void _saveData() {
    widget.onSave(
      _nameController.text,
      _selectedGender,
      _phoneController.text,
      _emailController.text,
      _dobController.text,
      _selectedBirthCountry,
      _selectedBirthState,
      _homeAddressController.text,
      _commencementDateController.text,
      _selectedHighestEducation,
      _profileImage,
    );
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _nameController.removeListener(_saveData);
    _phoneController.removeListener(_saveData);
    _emailController.removeListener(_saveData);
    _homeAddressController.removeListener(_saveData);
    
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _homeAddressController.dispose();
    _commencementDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('General Settings', widget.edituserDetail.commencementDate),
            _buildSectionSubtitle('Student personal information'),
            const SizedBox(height: 16),
            
            // For desktop, show two columns
            if (isDesktop || isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Name',
                          controller: _nameController, 
                          validator: (value) => value!.isEmpty ? 'Name is required' : null,
                          isEditable: widget.edituserDetail.editableFields['name'] ?? false,
                        ),
                        const SizedBox(height: 16),
                        _buildGenderSelection(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Phone',
                          controller: _phoneController, 
                          keyboardType: TextInputType.phone,
                          validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
                          isEditable: widget.edituserDetail.editableFields['mobileNo'] ?? true,
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
                          isEditable: widget.edituserDetail.editableFields['email'] ?? false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right column
                  Expanded(
                    child: Column(
                      children: [
                        _buildDatePicker(
                          label: 'Date of Birth',
                          controller: _dobController,
                          validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
                          isEditable: widget.edituserDetail.editableFields['dob'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'Birth Country',
                          items: widget.countriesMap,
                          selectedValue: _selectedBirthCountry,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedBirthCountry = value;
                                _saveData(); // Save data when dropdown value changes
                              });
                            }
                          },
                          isEditable: widget.edituserDetail.editableFields['countryOfBirth'] ?? false,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'State',
                          items: widget.statesMap,
                          selectedValue: _selectedBirthState,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedBirthState = value;
                                _saveData(); // Save data when dropdown value changes
                              });
                            }
                          },
                          isEditable: widget.edituserDetail.editableFields['birthStateId'] ?? true,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              // For mobile, show single column
              Column(
                children: [
                  _buildTextField(
                    label: 'Name',
                    controller: _nameController, 
                    validator: (value) => value!.isEmpty ? 'Name is required' : null,
                    isEditable: widget.edituserDetail.editableFields['name'] ?? false,
                  ),
                  const SizedBox(height: 16),
                  _buildGenderSelection(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Phone',
                    controller: _phoneController, 
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
                    isEditable: widget.edituserDetail.editableFields['mobileNo'] ?? true,
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
                    isEditable: widget.edituserDetail.editableFields['email'] ?? false,
                  ),
                  const SizedBox(height: 16),
                  _buildDatePicker(
                    label: 'Date of Birth',
                    controller: _dobController,
                    validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
                    isEditable: widget.edituserDetail.editableFields['dob'] ?? true,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Birth Country',
                    items: widget.countriesMap,
                    selectedValue: _selectedBirthCountry,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedBirthCountry = value;
                          _saveData(); // Save data when dropdown value changes
                        });
                      }
                    },
                    isEditable: widget.edituserDetail.editableFields['countryOfBirth'] ?? false,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'State',
                    items: widget.statesMap,
                    selectedValue: _selectedBirthState,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedBirthState = value;
                          _saveData(); // Save data when dropdown value changes
                        });
                      }
                    },
                    isEditable: widget.edituserDetail.editableFields['birthStateId'] ?? true,
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Home Country Address',
              controller: _homeAddressController,
              isEditable: widget.edituserDetail.editableFields['birthResidentialAddress'] ?? true,
            ),
            
            const SizedBox(height: 16),
            _buildDatePicker(
              label: 'Commencement Date',
              controller: _commencementDateController,
              validator: (value) => value!.isEmpty ? 'Commencement date is required' : null,
              isEditable: widget.edituserDetail.editableFields['commencementDate'] ?? true,
            ),
            
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Highest Education',
              items: {for (var e in widget.educationLevels) e: e},
              selectedValue: _selectedHighestEducation,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedHighestEducation = value;
                    _saveData(); // Save data when dropdown value changes
                  });
                }
              },
              isEditable: widget.edituserDetail.editableFields['highestEducation'] ?? true,
            ),
            
            const SizedBox(height: 16),
            _buildImagePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String date) {
    return ResponsiveUtils.isDesktop(context) 
      ? Row(
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
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Start | Added On: $date',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color.fromARGB(255, 227, 10, 169),
                fontWeight: FontWeight.w500,
              ),
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
    required bool isEditable,
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
          readOnly: !isEditable,
          enabled: isEditable,
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
            fillColor: isEditable ? Colors.white : Colors.grey[100], // Grey bg for non-editable fields
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
    required bool isEditable,
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
          onTap: isEditable ? () => _selectDate(context, controller) : null,
          enabled: isEditable,
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
            fillColor: isEditable ? Colors.white : Colors.grey[100], // Grey bg for non-editable fields
            suffixIcon: isEditable ? const Icon(Icons.calendar_today_outlined) : null,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required Map<String, String> items,
    required String selectedValue,
    required void Function(String?)? onChanged,
    required bool isEditable,
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
            color: isEditable ? Colors.white : Colors.grey[100], // Grey bg for non-editable fields
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.containsKey(selectedValue) ? selectedValue : (items.isNotEmpty ? items.keys.first : null),
                isExpanded: true,
                hint: Text(
                  'Select ${label}',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                items: items.entries
                    .map((entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: isEditable ? onChanged : null, // Disable interaction if not editable
                icon: isEditable ? const Icon(Icons.keyboard_arrow_down) : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    final bool isEditable = widget.edituserDetail.editableFields['gender'] ?? true;
    
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
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isEditable ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Wrap(
            spacing: 8,
            children: [
              SizedBox(
                width: ResponsiveUtils.isMobile(context) ? null : 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(
                      value: '1',
                      groupValue: _selectedGender,
                      activeColor: const Color.fromARGB(255, 227, 10, 169),
                      onChanged: isEditable ? (value) {
                        setState(() {
                          _selectedGender = value as String;
                          _saveData(); // Save data when gender changes
                        });
                      } : null,
                    ),
                    const Text('Male'),
                  ],
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.isMobile(context) ? null : 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(
                      value: '2',
                      groupValue: _selectedGender,
                      activeColor: const Color.fromARGB(255, 227, 10, 169),
                      onChanged: isEditable ? (value) {
                        setState(() {
                          _selectedGender = value as String;
                          _saveData(); // Save data when gender changes
                        });
                      } : null,
                    ),
                    const Text('Female'),
                  ],
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.isMobile(context) ? null : 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(
                      value: '3',
                      groupValue: _selectedGender,
                      activeColor: const Color.fromARGB(255, 227, 10, 169),
                      onChanged: isEditable ? (value) {
                        setState(() {
                          _selectedGender = value as String;
                          _saveData(); // Save data when gender changes
                        });
                      } : null,
                    ),
                    const Text('Other'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final bool isEditable = widget.edituserDetail.editableFields['profileImage'] ?? true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Image',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isEditable ? _pickImage : null,
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
                _profileImagePath != null ? _profileImagePath!.split('/').last : 'No file chosen',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_profileImage != null || _profileImagePath != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _profileImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _profileImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _profileImagePath!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ],
    );
  }
}














// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:ems/models/edit_user_details.dart';
// import 'package:ems/utils/responsive_utils.dart';

// class GeneralInfoSection extends StatefulWidget {
//   final EditUserDetail edituserDetail;
//   final Function(
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
//   ) onSave;

//   final Map<String, String> countriesMap;
//   final Map<String, String> statesMap;
//   final List<String> educationLevels;

//   const GeneralInfoSection({
//     Key? key,
//     required this.edituserDetail,
//     required this.onSave,
//     required this.countriesMap,
//     required this.statesMap,
//     required this.educationLevels,
//   }) : super(key: key);

//   @override
//   State<GeneralInfoSection> createState() => _GeneralInfoSectionState();
// }

// class _GeneralInfoSectionState extends State<GeneralInfoSection> {
//   late TextEditingController _nameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _emailController;
//   late TextEditingController _dobController;
//   late TextEditingController _homeAddressController;
//   late TextEditingController _commencementDateController;
//   late String _selectedGender;
//   late String _selectedBirthCountry;
//   late String _selectedBirthState;
//   late String _selectedHighestEducation;
//   File? _profileImage;
//   String? _profileImagePath;

//   // Define fields that cannot be edited (will be determined by API response)
//   Map<String, bool> get _editableFields => widget.edituserDetail.editableFields;

//   @override
//   void initState() {
//     super.initState();
//     _initControllers();
//     // Debug log for editable fields
//     debugPrint('Editable fields for GeneralInfoSection: $_editableFields');
//   }

//   void _initControllers() {
//     _nameController = TextEditingController(text: widget.edituserDetail.name);
//     _phoneController = TextEditingController(text: widget.edituserDetail.mobileNo);
//     _emailController = TextEditingController(text: widget.edituserDetail.email);
//     _dobController = TextEditingController(text: widget.edituserDetail.dob);
//     _homeAddressController = TextEditingController(text: widget.edituserDetail.birthResidentialAddress);
//     _commencementDateController = TextEditingController(text: widget.edituserDetail.commencementDate);
//     _selectedGender = widget.edituserDetail.gender;
//     _selectedBirthCountry = widget.edituserDetail.countryOfBirth;
//     _selectedBirthState = widget.edituserDetail.birthStateId;
//     _selectedHighestEducation = widget.edituserDetail.highestEducation;
//     _profileImagePath = widget.edituserDetail.profileImage.isNotEmpty ? widget.edituserDetail.profileImage : null;
    
//     // Only add listeners to editable fields
//     if (isFieldEditable('name')) {
//       _nameController.addListener(_saveData);
//     }
//     if (isFieldEditable('mobileNo')) {
//       _phoneController.addListener(_saveData);
//     }
//     if (isFieldEditable('email')) {
//       _emailController.addListener(_saveData);
//     }
//     if (isFieldEditable('birthResidentialAddress')) {
//       _homeAddressController.addListener(_saveData);
//     }
//   }

//   bool isFieldEditable(String fieldName) {
//     return _editableFields[fieldName] ?? false;
//   }

//   Future<void> _selectDate(BuildContext context, TextEditingController controller, String fieldName) async {
//     if (!isFieldEditable(fieldName)) {
//       debugPrint('Cannot edit $fieldName - field is not editable');
//       return;
//     }
    
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: controller.text.isNotEmpty 
//           ? DateFormat('yyyy-MM-dd').parse(controller.text) 
//           : DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//     );
    
//     if (picked != null) {
//       setState(() {
//         controller.text = DateFormat('yyyy-MM-dd').format(picked);
//         _saveData(); // Save data after date selection
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     if (!isFieldEditable('profileImage')) {
//       debugPrint('Cannot edit profile image - field is not editable');
//       return;
//     }
    
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//         _profileImagePath = pickedFile.path;
//         debugPrint('Selected image: ${pickedFile.path}');
//         _saveData(); // Save data after image selection
//       });
//     }
//   }

//   void _saveData() {
//     widget.onSave(
//       _nameController.text,
//       _selectedGender,
//       _phoneController.text,
//       _emailController.text,
//       _dobController.text,
//       _selectedBirthCountry,
//       _selectedBirthState,
//       _homeAddressController.text,
//       _commencementDateController.text,
//       _selectedHighestEducation,
//       _profileImage,
//     );
//   }

//   @override
//   void dispose() {
//     // Remove listeners before disposing controllers
//     if (isFieldEditable('name')) {
//       _nameController.removeListener(_saveData);
//     }
//     if (isFieldEditable('mobileNo')) {
//       _phoneController.removeListener(_saveData);
//     }
//     if (isFieldEditable('email')) {
//       _emailController.removeListener(_saveData);
//     }
//     if (isFieldEditable('birthResidentialAddress')) {
//       _homeAddressController.removeListener(_saveData);
//     }
    
//     _nameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     _dobController.dispose();
//     _homeAddressController.dispose();
//     _commencementDateController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = ResponsiveUtils.isDesktop(context);
//     final isTablet = ResponsiveUtils.isTablet(context);

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildSectionHeader('General Settings', widget.edituserDetail.commencementDate),
//             _buildSectionSubtitle('Student personal information'),
//             const SizedBox(height: 16),
            
//             // For desktop, show two columns
//             if (isDesktop || isTablet)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Left column
//                   Expanded(
//                     child: Column(
//                       children: [
//                         _buildTextField(
//                           label: 'Name',
//                           controller: _nameController, 
//                           validator: (value) => value!.isEmpty ? 'Name is required' : null,
//                           fieldName: 'name',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildGenderSelection(fieldName: 'gender'),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           label: 'Phone',
//                           controller: _phoneController, 
//                           keyboardType: TextInputType.phone,
//                           validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
//                           fieldName: 'mobileNo',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           label: 'Email',
//                           controller: _emailController, 
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (value) {
//                             if (value!.isEmpty) return 'Email is required';
//                             final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//                             return !emailRegExp.hasMatch(value) ? 'Enter a valid email' : null;
//                           },
//                           fieldName: 'email',
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   // Right column
//                   Expanded(
//                     child: Column(
//                       children: [
//                         _buildDatePicker(
//                           label: 'Date of Birth',
//                           controller: _dobController,
//                           validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
//                           fieldName: 'dob',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildDropdown(
//                           label: 'Birth Country',
//                           items: widget.countriesMap,
//                           selectedValue: _selectedBirthCountry,
//                           onChanged: (value) {
//                             if (value != null) {
//                               setState(() {
//                                 _selectedBirthCountry = value;
//                                 _saveData(); // Save data when dropdown value changes
//                               });
//                             }
//                           },
//                           fieldName: 'countryOfBirth',
//                         ),
//                         const SizedBox(height: 16),
//                         _buildDropdown(
//                           label: 'State',
//                           items: widget.statesMap,
//                           selectedValue: _selectedBirthState,
//                           onChanged: (value) {
//                             if (value != null) {
//                               setState(() {
//                                 _selectedBirthState = value;
//                                 _saveData(); // Save data when dropdown value changes
//                               });
//                             }
//                           },
//                           fieldName: 'birthStateId',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               )
//             else
//               // For mobile, show single column
//               Column(
//                 children: [
//                   _buildTextField(
//                     label: 'Name',
//                     controller: _nameController, 
//                     validator: (value) => value!.isEmpty ? 'Name is required' : null,
//                     fieldName: 'name',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildGenderSelection(fieldName: 'gender'),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     label: 'Phone',
//                     controller: _phoneController, 
//                     keyboardType: TextInputType.phone,
//                     validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
//                     fieldName: 'mobileNo',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     label: 'Email',
//                     controller: _emailController, 
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value!.isEmpty) return 'Email is required';
//                       final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//                       return !emailRegExp.hasMatch(value) ? 'Enter a valid email' : null;
//                     },
//                     fieldName: 'email',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDatePicker(
//                     label: 'Date of Birth',
//                     controller: _dobController,
//                     validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
//                     fieldName: 'dob',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDropdown(
//                     label: 'Birth Country',
//                     items: widget.countriesMap,
//                     selectedValue: _selectedBirthCountry,
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           _selectedBirthCountry = value;
//                           _saveData(); // Save data when dropdown value changes
//                         });
//                       }
//                     },
//                     fieldName: 'countryOfBirth',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDropdown(
//                     label: 'State',
//                     items: widget.statesMap,
//                     selectedValue: _selectedBirthState,
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           _selectedBirthState = value;
//                           _saveData(); // Save data when dropdown value changes
//                         });
//                       }
//                     },
//                     fieldName: 'birthStateId',
//                   ),
//                 ],
//               ),
            
//             const SizedBox(height: 16),
//             _buildTextField(
//               label: 'Home Country Address',
//               controller: _homeAddressController,
//               fieldName: 'birthResidentialAddress',
//             ),
            
//             const SizedBox(height: 16),
//             _buildDatePicker(
//               label: 'Commencement Date',
//               controller: _commencementDateController,
//               validator: (value) => value!.isEmpty ? 'Commencement date is required' : null,
//               fieldName: 'commencementDate',
//             ),
            
//             const SizedBox(height: 16),
//             _buildDropdown(
//               label: 'Highest Education',
//               items: {for (var e in widget.educationLevels) e: e},
//               selectedValue: _selectedHighestEducation,
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     _selectedHighestEducation = value;
//                     _saveData(); // Save data when dropdown value changes
//                   });
//                 }
//               },
//               fieldName: 'highestEducation',
//             ),
            
//             const SizedBox(height: 16),
//             _buildImagePicker(fieldName: 'profileImage'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, String date) {
//     return ResponsiveUtils.isDesktop(context) 
//       ? Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'Start | Added On',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//                 Text(
//                   date,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: const Color.fromARGB(255, 227, 10, 169),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         )
//       : Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               'Start | Added On: $date',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: const Color.fromARGB(255, 227, 10, 169),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         );
//   }

//   Widget _buildSectionSubtitle(String subtitle) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(
//         subtitle,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           color: const Color.fromARGB(255, 227, 10, 169),
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label, 
//     required TextEditingController controller,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//     required String fieldName,
//   }) {
//     // Check editability based on field name
//     final bool isEditable = isFieldEditable(fieldName);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (!isEditable)
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Icon(
//                   Icons.lock_outline,
//                   size: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           enabled: isEditable, // Disable if not editable
//           style: TextStyle(
//             color: isEditable ? Colors.black : Colors.grey[700],
//           ),
//           decoration: InputDecoration(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             disabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.red),
//             ),
//             filled: true,
//             fillColor: isEditable ? Colors.white : Colors.grey[100],
//           ),
//           validator: isEditable ? validator : null, // Only validate if editable
//         ),
//       ],
//     );
//   }

//   Widget _buildDatePicker({
//     required String label,
//     required TextEditingController controller,
//     String? Function(String?)? validator,
//     required String fieldName,
//   }) {
//     // Check editability based on field name
//     final bool isEditable = isFieldEditable(fieldName);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (!isEditable)
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Icon(
//                   Icons.lock_outline,
//                   size: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           readOnly: true,
//           enabled: isEditable, // Disable if not editable
//           onTap: () => _selectDate(context, controller, fieldName),
//           style: TextStyle(
//             color: isEditable ? Colors.black : Colors.grey[700],
//           ),
//           decoration: InputDecoration(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             disabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.red),
//             ),
//             filled: true,
//             fillColor: isEditable ? Colors.white : Colors.grey[100],
//             suffixIcon: isEditable 
//                 ? const Icon(Icons.calendar_today_outlined) 
//                 : Icon(Icons.lock_outline, color: Colors.grey[600]),
//           ),
//           validator: isEditable ? validator : null, // Only validate if editable
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required Map<String, String> items,
//     required String selectedValue,
//     required void Function(String?) onChanged,
//     required String fieldName,
//   }) {
//     // Check editability based on field name
//     final bool isEditable = isFieldEditable(fieldName);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (!isEditable)
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Icon(
//                   Icons.lock_outline,
//                   size: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         DecoratedBox(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(8),
//             color: isEditable ? Colors.white : Colors.grey[100],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: items.containsKey(selectedValue) ? selectedValue : null,
//                 isExpanded: true,
//                 hint: Text(
//                   'Select ${label}',
//                   style: GoogleFonts.poppins(color: Colors.grey[600]),
//                 ),
//                 items: items.entries
//                     .map((entry) => DropdownMenuItem<String>(
//                           value: entry.key,
//                           child: Text(entry.value),
//                         ))
//                     .toList(),
//                 onChanged: isEditable ? onChanged : null, // Disable if not editable
//                 icon: Icon(
//                   isEditable ? Icons.keyboard_arrow_down : Icons.lock_outline,
//                   color: isEditable ? null : Colors.grey[600],
//                 ),
//                 style: TextStyle(
//                   color: isEditable ? Colors.black : Colors.grey[700],
//                   fontSize: 16,
//                 ),
//                 dropdownColor: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildGenderSelection({required String fieldName}) {
//     // Check editability based on field name
//     final bool isEditable = isFieldEditable(fieldName);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               'Gender',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (!isEditable)
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Icon(
//                   Icons.lock_outline,
//                   size: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(8),
//             color: isEditable ? Colors.white : Colors.grey[100],
//           ),
//           child: Wrap(
//             spacing: 8,
//             children: [
//               SizedBox(
//                 width: ResponsiveUtils.isMobile(context) ? null : 120,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Radio(
//                       value: '1',
//                       groupValue: _selectedGender,
//                       activeColor: const Color.fromARGB(255, 227, 10, 169),
//                       onChanged: isEditable 
//                         ? (value) {
//                             setState(() {
//                               _selectedGender = value as String;
//                               _saveData(); // Save data when gender changes
//                             });
//                           } 
//                         : null,
//                     ),
//                     const Text('Male'),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: ResponsiveUtils.isMobile(context) ? null : 120,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Radio(
//                       value: '2',
//                       groupValue: _selectedGender,
//                       activeColor: const Color.fromARGB(255, 227, 10, 169),
//                       onChanged: isEditable 
//                         ? (value) {
//                             setState(() {
//                               _selectedGender = value as String;
//                               _saveData(); // Save data when gender changes
//                             });
//                           } 
//                         : null,
//                     ),
//                     const Text('Female'),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 width: ResponsiveUtils.isMobile(context) ? null : 120,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Radio(
//                       value: '3',
//                       groupValue: _selectedGender,
//                       activeColor: const Color.fromARGB(255, 227, 10, 169),
//                       onChanged: isEditable 
//                         ? (value) {
//                             setState(() {
//                               _selectedGender = value as String;
//                               _saveData(); // Save data when gender changes
//                             });
//                           } 
//                         : null,
//                     ),
//                     const Text('Other'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildImagePicker({required String fieldName}) {
//     // Check editability based on field name
//     final bool isEditable = isFieldEditable(fieldName);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               'Profile Image',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (!isEditable)
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Icon(
//                   Icons.lock_outline,
//                   size: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             if (isEditable)
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.black,
//                   side: BorderSide(color: Colors.grey[300]!),
//                 ),
//                 child: const Text('Choose File'),
//               )
//             else
//               ElevatedButton(
//                 onPressed: null, // Disabled if not editable
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[100],
//                   foregroundColor: Colors.grey[600],
//                   side: BorderSide(color: Colors.grey[300]!),
//                 ),
//                 child: const Text('Choose File'),
//               ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 _profileImagePath != null ? _profileImagePath!.split('/').last : 'No file chosen',
//                 style: GoogleFonts.poppins(color: Colors.grey[600]),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             if (_profileImage != null || _profileImagePath != null)
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: _profileImage != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.file(
//                           _profileImage!,
//                           width: 60,
//                           height: 60,
//                           fit: BoxFit.cover,
//                         ),
//                       )
//                     : ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           _profileImagePath!,
//                           width: 60,
//                           height: 60,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             debugPrint('Error loading profile image: $error');
//                             return Container(
//                               width: 60,
//                               height: 60,
//                               color: Colors.grey[300],
//                               child: const Icon(Icons.error),
//                             );
//                           },
//                         ),
//                       ),
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }


















// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:intl/intl.dart';
// // import 'package:ems/models/edit_user_details.dart';
// // import 'package:ems/utils/responsive_utils.dart';

// // class GeneralInfoSection extends StatefulWidget {
// //   final EditUserDetail edituserDetail;
// //   final Function(
// //     String name,
// //     String gender,
// //     String phone,
// //     String email,
// //     String dob,
// //     String birthCountry,
// //     String birthState,
// //     String homeAddress,
// //     String commencementDate,
// //     String highestEducation,
// //     File? profileImage,
// //   ) onSave;

// //   final Map<String, String> countriesMap;
// //   final Map<String, String> statesMap;
// //   final List<String> educationLevels;

// //   const GeneralInfoSection({
// //     Key? key,
// //     required this.edituserDetail,
// //     required this.onSave,
// //     required this.countriesMap,
// //     required this.statesMap,
// //     required this.educationLevels,
// //   }) : super(key: key);

// //   @override
// //   State<GeneralInfoSection> createState() => _GeneralInfoSectionState();
// // }

// // class _GeneralInfoSectionState extends State<GeneralInfoSection> {
// //   late TextEditingController _nameController;
// //   late TextEditingController _phoneController;
// //   late TextEditingController _emailController;
// //   late TextEditingController _dobController;
// //   late TextEditingController _homeAddressController;
// //   late TextEditingController _commencementDateController;
// //   late String _selectedGender;
// //   late String _selectedBirthCountry;
// //   late String _selectedBirthState;
// //   late String _selectedHighestEducation;
// //   File? _profileImage;
// //   String? _profileImagePath;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initControllers();
// //   }

// //   void _initControllers() {
// //     _nameController = TextEditingController(text: widget.edituserDetail.name);
// //     _phoneController = TextEditingController(text: widget.edituserDetail.mobileNo);
// //     _emailController = TextEditingController(text: widget.edituserDetail.email);
// //     _dobController = TextEditingController(text: widget.edituserDetail.dob);
// //     _homeAddressController = TextEditingController(text: widget.edituserDetail.birthResidentialAddress);
// //     _commencementDateController = TextEditingController(text: widget.edituserDetail.commencementDate);
// //     _selectedGender = widget.edituserDetail.gender;
// //     _selectedBirthCountry = widget.edituserDetail.countryOfBirth;
// //     _selectedBirthState = widget.edituserDetail.birthStateId;
// //     _selectedHighestEducation = widget.edituserDetail.highestEducation;
// //     _profileImagePath = widget.edituserDetail.profileImage.isNotEmpty ? widget.edituserDetail.profileImage : null;
    
// //     // Add listeners to controllers to save data when text changes
// //     _nameController.addListener(_saveData);
// //     _phoneController.addListener(_saveData);
// //     _emailController.addListener(_saveData);
// //     _homeAddressController.addListener(_saveData);
// //   }

// //   Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: controller.text.isNotEmpty 
// //           ? DateFormat('yyyy-MM-dd').parse(controller.text) 
// //           : DateTime.now(),
// //       firstDate: DateTime(1900),
// //       lastDate: DateTime(2100),
// //     );
    
// //     if (picked != null) {
// //       setState(() {
// //         controller.text = DateFormat('yyyy-MM-dd').format(picked);
// //         _saveData(); // Save data after date selection
// //       });
// //     }
// //   }

// //   Future<void> _pickImage() async {
// //     final picker = ImagePicker();
// //     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
// //     if (pickedFile != null) {
// //       setState(() {
// //         _profileImage = File(pickedFile.path);
// //         _profileImagePath = pickedFile.path;
// //         _saveData(); // Save data after image selection
// //       });
// //     }
// //   }

// //   void _saveData() {
// //     widget.onSave(
// //       _nameController.text,
// //       _selectedGender,
// //       _phoneController.text,
// //       _emailController.text,
// //       _dobController.text,
// //       _selectedBirthCountry,
// //       _selectedBirthState,
// //       _homeAddressController.text,
// //       _commencementDateController.text,
// //       _selectedHighestEducation,
// //       _profileImage,
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     // Remove listeners before disposing controllers
// //     _nameController.removeListener(_saveData);
// //     _phoneController.removeListener(_saveData);
// //     _emailController.removeListener(_saveData);
// //     _homeAddressController.removeListener(_saveData);
    
// //     _nameController.dispose();
// //     _phoneController.dispose();
// //     _emailController.dispose();
// //     _dobController.dispose();
// //     _homeAddressController.dispose();
// //     _commencementDateController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDesktop = ResponsiveUtils.isDesktop(context);
// //     final isTablet = ResponsiveUtils.isTablet(context);

// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             _buildSectionHeader('General Settings', widget.edituserDetail.commencementDate),
// //             _buildSectionSubtitle('Student personal information'),
// //             const SizedBox(height: 16),
            
// //             // For desktop, show two columns
// //             if (isDesktop || isTablet)
// //               Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Left column
// //                   Expanded(
// //                     child: Column(
// //                       children: [
// //                         _buildTextField(
// //                           label: 'Name',
// //                           controller: _nameController, 
// //                           validator: (value) => value!.isEmpty ? 'Name is required' : null,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildGenderSelection(),
// //                         const SizedBox(height: 16),
// //                         _buildTextField(
// //                           label: 'Phone',
// //                           controller: _phoneController, 
// //                           keyboardType: TextInputType.phone,
// //                           validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildTextField(
// //                           label: 'Email',
// //                           controller: _emailController, 
// //                           keyboardType: TextInputType.emailAddress,
// //                           validator: (value) {
// //                             if (value!.isEmpty) return 'Email is required';
// //                             final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
// //                             return !emailRegExp.hasMatch(value) ? 'Enter a valid email' : null;
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(width: 16),
// //                   // Right column
// //                   Expanded(
// //                     child: Column(
// //                       children: [
// //                         _buildDatePicker(
// //                           label: 'Date of Birth',
// //                           controller: _dobController,
// //                           validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildDropdown(
// //                           label: 'Birth Country',
// //                           items: widget.countriesMap,
// //                           selectedValue: _selectedBirthCountry,
// //                           onChanged: (value) {
// //                             if (value != null) {
// //                               setState(() {
// //                                 _selectedBirthCountry = value;
// //                                 _saveData(); // Save data when dropdown value changes
// //                               });
// //                             }
// //                           },
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildDropdown(
// //                           label: 'State',
// //                           items: widget.statesMap,
// //                           selectedValue: _selectedBirthState,
// //                           onChanged: (value) {
// //                             if (value != null) {
// //                               setState(() {
// //                                 _selectedBirthState = value;
// //                                 _saveData(); // Save data when dropdown value changes
// //                               });
// //                             }
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               )
// //             else
// //               // For mobile, show single column
// //               Column(
// //                 children: [
// //                   _buildTextField(
// //                     label: 'Name',
// //                     controller: _nameController, 
// //                     validator: (value) => value!.isEmpty ? 'Name is required' : null,
// //                   ),
// //                   const SizedBox(height: 16),
// //                   _buildGenderSelection(),
// //                   const SizedBox(height: 16),
// //                   _buildTextField(
// //                     label: 'Phone',
// //                     controller: _phoneController, 
// //                     keyboardType: TextInputType.phone,
// //                     validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
// //                   ),
// //                   const SizedBox(height: 16),
// //                   _buildTextField(
// //                     label: 'Email',
// //                     controller: _emailController, 
// //                     keyboardType: TextInputType.emailAddress,
// //                     validator: (value) {
// //                       if (value!.isEmpty) return 'Email is required';
// //                       final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
// //                       return !emailRegExp.hasMatch(value) ? 'Enter a valid email' : null;
// //                     },
// //                   ),
// //                   const SizedBox(height: 16),
// //                   _buildDatePicker(
// //                     label: 'Date of Birth',
// //                     controller: _dobController,
// //                     validator: (value) => value!.isEmpty ? 'Date of birth is required' : null,
// //                   ),
// //                   const SizedBox(height: 16),
// //                   _buildDropdown(
// //                     label: 'Birth Country',
// //                     items: widget.countriesMap,
// //                     selectedValue: _selectedBirthCountry,
// //                     onChanged: (value) {
// //                       if (value != null) {
// //                         setState(() {
// //                           _selectedBirthCountry = value;
// //                           _saveData(); // Save data when dropdown value changes
// //                         });
// //                       }
// //                     },
// //                   ),
// //                   const SizedBox(height: 16),
// //                   _buildDropdown(
// //                     label: 'State',
// //                     items: widget.statesMap,
// //                     selectedValue: _selectedBirthState,
// //                     onChanged: (value) {
// //                       if (value != null) {
// //                         setState(() {
// //                           _selectedBirthState = value;
// //                           _saveData(); // Save data when dropdown value changes
// //                         });
// //                       }
// //                     },
// //                   ),
// //                 ],
// //               ),
            
// //             const SizedBox(height: 16),
// //             _buildTextField(
// //               label: 'Home Country Address',
// //               controller: _homeAddressController,
// //             ),
            
// //             const SizedBox(height: 16),
// //             _buildDatePicker(
// //               label: 'Commencement Date',
// //               controller: _commencementDateController,
// //               validator: (value) => value!.isEmpty ? 'Commencement date is required' : null,
// //             ),
            
// //             const SizedBox(height: 16),
// //             _buildDropdown(
// //               label: 'Highest Education',
// //               items: {for (var e in widget.educationLevels) e: e},
// //               selectedValue: _selectedHighestEducation,
// //               onChanged: (value) {
// //                 if (value != null) {
// //                   setState(() {
// //                     _selectedHighestEducation = value;
// //                     _saveData(); // Save data when dropdown value changes
// //                   });
// //                 }
// //               },
// //             ),
            
// //             const SizedBox(height: 16),
// //             _buildImagePicker(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSectionHeader(String title, String date) {
// //     return ResponsiveUtils.isDesktop(context) 
// //       ? Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Text(
// //               title,
// //               style: GoogleFonts.poppins(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.end,
// //               children: [
// //                 Text(
// //                   'Start | Added On',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 14,
// //                     color: Colors.grey[700],
// //                   ),
// //                 ),
// //                 Text(
// //                   date,
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 14,
// //                     color: const Color.fromARGB(255, 227, 10, 169),
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         )
// //       : Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               title,
// //               style: GoogleFonts.poppins(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             Text(
// //               'Start | Added On: $date',
// //               style: GoogleFonts.poppins(
// //                 fontSize: 14,
// //                 color: const Color.fromARGB(255, 227, 10, 169),
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ],
// //         );
// //   }

// //   Widget _buildSectionSubtitle(String subtitle) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.symmetric(vertical: 8),
// //       child: Text(
// //         subtitle,
// //         style: GoogleFonts.poppins(
// //           fontSize: 16,
// //           color: const Color.fromARGB(255, 227, 10, 169),
// //           fontWeight: FontWeight.w500,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTextField({
// //     required String label, 
// //     required TextEditingController controller,
// //     TextInputType keyboardType = TextInputType.text,
// //     String? Function(String?)? validator,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: GoogleFonts.poppins(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         TextFormField(
// //           controller: controller,
// //           keyboardType: keyboardType,
// //           // No need to add onChanged here since we're using controller listeners
// //           decoration: InputDecoration(
// //             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: BorderSide(color: Colors.grey[300]!),
// //             ),
// //             enabledBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: BorderSide(color: Colors.grey[300]!),
// //             ),
// //             focusedBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
// //             ),
// //             errorBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: const BorderSide(color: Colors.red),
// //             ),
// //             filled: true,
// //             fillColor: Colors.white,
// //           ),
// //           validator: validator,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDatePicker({
// //     required String label,
// //     required TextEditingController controller,
// //     String? Function(String?)? validator,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: GoogleFonts.poppins(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         TextFormField(
// //           controller: controller,
// //           readOnly: true,
// //           onTap: () => _selectDate(context, controller),
// //           decoration: InputDecoration(
// //             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: BorderSide(color: Colors.grey[300]!),
// //             ),
// //             enabledBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: BorderSide(color: Colors.grey[300]!),
// //             ),
// //             focusedBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
// //             ),
// //             errorBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: const BorderSide(color: Colors.red),
// //             ),
// //             filled: true,
// //             fillColor: Colors.white,
// //             suffixIcon: const Icon(Icons.calendar_today_outlined),
// //           ),
// //           validator: validator,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDropdown({
// //     required String label,
// //     required Map<String, String> items,
// //     required String selectedValue,
// //     required void Function(String?) onChanged,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: GoogleFonts.poppins(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         DecoratedBox(
// //           decoration: BoxDecoration(
// //             border: Border.all(color: Colors.grey[300]!),
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 12),
// //             child: DropdownButtonHideUnderline(
// //               child: DropdownButton<String>(
// //                 value: items.containsKey(selectedValue) ? selectedValue : items.keys.first,
// //                 isExpanded: true,
// //                 hint: Text(
// //                   'Select ${label}',
// //                   style: GoogleFonts.poppins(color: Colors.grey[600]),
// //                 ),
// //                 items: items.entries
// //                     .map((entry) => DropdownMenuItem<String>(
// //                           value: entry.key,
// //                           child: Text(entry.value),
// //                         ))
// //                     .toList(),
// //                 onChanged: onChanged,
// //                 icon: const Icon(Icons.keyboard_arrow_down),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildGenderSelection() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Gender',
// //           style: GoogleFonts.poppins(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         Wrap(
// //           spacing: 8,
// //           children: [
// //             SizedBox(
// //               width: ResponsiveUtils.isMobile(context) ? null : 120,
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Radio(
// //                     value: '1',
// //                     groupValue: _selectedGender,
// //                     activeColor: const Color.fromARGB(255, 227, 10, 169),
// //                     onChanged: (value) {
// //                       setState(() {
// //                         _selectedGender = value as String;
// //                         _saveData(); // Save data when gender changes
// //                       });
// //                     },
// //                   ),
// //                   const Text('Male'),
// //                 ],
// //               ),
// //             ),
// //             SizedBox(
// //               width: ResponsiveUtils.isMobile(context) ? null : 120,
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Radio(
// //                     value: '2',
// //                     groupValue: _selectedGender,
// //                     activeColor: const Color.fromARGB(255, 227, 10, 169),
// //                     onChanged: (value) {
// //                       setState(() {
// //                         _selectedGender = value as String;
// //                         _saveData(); // Save data when gender changes
// //                       });
// //                     },
// //                   ),
// //                   const Text('Female'),
// //                 ],
// //               ),
// //             ),
// //             SizedBox(
// //               width: ResponsiveUtils.isMobile(context) ? null : 120,
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Radio(
// //                     value: '3',
// //                     groupValue: _selectedGender,
// //                     activeColor: const Color.fromARGB(255, 227, 10, 169),
// //                     onChanged: (value) {
// //                       setState(() {
// //                         _selectedGender = value as String;
// //                         _saveData(); // Save data when gender changes
// //                       });
// //                     },
// //                   ),
// //                   const Text('Other'),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildImagePicker() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'Profile Image',
// //           style: GoogleFonts.poppins(
// //             fontSize: 16,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         Row(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             ElevatedButton(
// //               onPressed: _pickImage,
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.white,
// //                 foregroundColor: Colors.black,
// //                 side: BorderSide(color: Colors.grey[300]!),
// //               ),
// //               child: const Text('Choose File'),
// //             ),
// //             const SizedBox(width: 16),
// //             Expanded(
// //               child: Text(
// //                 _profileImagePath != null ? _profileImagePath!.split('/').last : 'No file chosen',
// //                 style: GoogleFonts.poppins(color: Colors.grey[600]),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //             if (_profileImage != null || _profileImagePath != null)
// //               Padding(
// //                 padding: const EdgeInsets.only(left: 8.0),
// //                 child: _profileImage != null
// //                     ? ClipRRect(
// //                         borderRadius: BorderRadius.circular(8),
// //                         child: Image.file(
// //                           _profileImage!,
// //                           width: 60,
// //                           height: 60,
// //                           fit: BoxFit.cover,
// //                         ),
// //                       )
// //                     : ClipRRect(
// //                         borderRadius: BorderRadius.circular(8),
// //                         child: Image.network(
// //                           _profileImagePath!,
// //                           width: 60,
// //                           height: 60,
// //                           fit: BoxFit.cover,
// //                           errorBuilder: (context, error, stackTrace) => Container(
// //                             width: 60,
// //                             height: 60,
// //                             color: Colors.grey[300],
// //                             child: const Icon(Icons.error),
// //                           ),
// //                         ),
// //                       ),
// //               ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// // }