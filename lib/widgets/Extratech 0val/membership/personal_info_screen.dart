import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonalInfoSection extends StatefulWidget {
  final Map<String, dynamic> formData;
  
  const PersonalInfoSection({
    Key? key,
    required this.formData,
  }) : super(key: key);

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    if (widget.formData.containsKey('dob') && widget.formData['dob'] != null) {
      _selectedDate = widget.formData['dob'];
      _dobController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
  }
  
  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        widget.formData['dob'] = picked;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF205EB5),
          ),
        ),
        const SizedBox(height: 12),
        
        // Name fields - Responsive layout
        if (isSmallScreen) 
          // Stack vertically on small screens
          Column(
            children: [
              _buildTextField(
                label: 'First Name *',
                prefixIcon: Icons.person,
                onSaved: (value) => widget.formData['firstName'] = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Middle Name',
                prefixIcon: Icons.person,
                onSaved: (value) => widget.formData['middleName'] = value,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Last Name',
                prefixIcon: Icons.person,
                onSaved: (value) => widget.formData['lastName'] = value,
              ),
            ],
          )
        else 
          // Side by side on larger screens
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'First Name *',
                  prefixIcon: Icons.person,
                  onSaved: (value) => widget.formData['firstName'] = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Middle Name',
                  prefixIcon: Icons.person,
                  onSaved: (value) => widget.formData['middleName'] = value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Last Name',
                  prefixIcon: Icons.person,
                  onSaved: (value) => widget.formData['lastName'] = value,
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 12),
        
        // Date of Birth
        TextFormField(
          controller: _dobController,
          decoration: InputDecoration(
            labelText: 'DOB',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () => _selectDate(context),
            ),
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
          onSaved: (value) => widget.formData['dobString'] = value,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData prefixIcon,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}