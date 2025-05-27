import 'package:flutter/material.dart';

class LocationContactSection extends StatefulWidget {
  final Map<String, dynamic> formData;
  
  const LocationContactSection({
    Key? key,
    required this.formData,
  }) : super(key: key);

  @override
  State<LocationContactSection> createState() => _LocationContactSectionState();
}

class _LocationContactSectionState extends State<LocationContactSection> {
  final List<String> _countries = ['USA', 'UK', 'Canada', 'Australia', 'India', 'Nepal'];
  String? _selectedCountry;
  
  final Map<String, List<String>> _statesByCountry = {
    'USA': ['New York', 'California', 'Texas', 'Florida'],
    'UK': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
    'Canada': ['Ontario', 'Quebec', 'British Columbia', 'Alberta'],
    'Australia': ['New South Wales', 'Victoria', 'Queensland', 'Western Australia'],
    'India': ['Maharashtra', 'Delhi', 'Tamil Nadu', 'Karnataka'],
    'Nepal': ['Bagmati', 'Gandaki', 'Koshi', 'Lumbini'],
  };
  
  String? _selectedState;
  
  @override
  void initState() {
    super.initState();
    if (widget.formData.containsKey('country')) {
      _selectedCountry = widget.formData['country'];
      if (widget.formData.containsKey('state')) {
        _selectedState = widget.formData['state'];
      }
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
          'Location & Contact Details',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF205EB5),
          ),
        ),
        const SizedBox(height: 12),
        
        // Country and State - Responsive
        if (isSmallScreen)
          Column(
            children: [
              _buildDropdown(
                label: 'Select Country',
                prefixIcon: Icons.flag,
                value: _selectedCountry,
                items: _countries.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountry = newValue;
                    _selectedState = null; // Reset state when country changes
                    widget.formData['country'] = newValue;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Select State',
                prefixIcon: Icons.location_city,
                value: _selectedState,
                items: (_selectedCountry != null && _statesByCountry.containsKey(_selectedCountry))
                    ? _statesByCountry[_selectedCountry]!.map((String state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Text(state),
                        );
                      }).toList()
                    : [],
                onChanged: _selectedCountry == null
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedState = newValue;
                          widget.formData['state'] = newValue;
                        });
                      },
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Select Country',
                  prefixIcon: Icons.flag,
                  value: _selectedCountry,
                  items: _countries.map((String country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCountry = newValue;
                      _selectedState = null; // Reset state when country changes
                      widget.formData['country'] = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Select State',
                  prefixIcon: Icons.location_city,
                  value: _selectedState,
                  items: (_selectedCountry != null && _statesByCountry.containsKey(_selectedCountry))
                      ? _statesByCountry[_selectedCountry]!.map((String state) {
                          return DropdownMenuItem<String>(
                            value: state,
                            child: Text(state),
                          );
                        }).toList()
                      : [],
                  onChanged: _selectedCountry == null
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedState = newValue;
                            widget.formData['state'] = newValue;
                          });
                        },
                ),
              ),
            ],
          ),
          
        const SizedBox(height: 12),
        
        // Address
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Address',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          onSaved: (value) => widget.formData['address'] = value,
        ),
        const SizedBox(height: 12),
        
        // Email and Mobile - Responsive
        if (isSmallScreen)
          Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null;
                },
                onSaved: (value) => widget.formData['email'] = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mobile No.',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                keyboardType: TextInputType.phone,
                onSaved: (value) => widget.formData['mobile'] = value,
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) => widget.formData['email'] = value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mobile No.',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => widget.formData['mobile'] = value,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData prefixIcon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      isEmpty: value == null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          hint: Text(label),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}