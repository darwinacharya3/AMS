import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems/Providers/Extratech_oval/membership_oval_providers.dart';
import 'package:intl/intl.dart';

class MembershipPersonalDetails extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> membershipTypes;
  final GlobalKey<FormState> formKey;
  final VoidCallback onNext;

  const MembershipPersonalDetails({
    Key? key,
    required this.membershipTypes,
    required this.formKey,
    required this.onNext,
  }) : super(key: key);

  @override
  ConsumerState<MembershipPersonalDetails> createState() => _MembershipPersonalDetailsState();
}

class _MembershipPersonalDetailsState extends ConsumerState<MembershipPersonalDetails> {
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  
  // For dropdown search
  final TextEditingController _countrySearchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCountries = [];
  bool _isSearchingCountry = false;
  
  @override
  void initState() {
    super.initState();
    
    // Set initial values for controllers from providers
    _dobController.text = ref.read(dobProvider);
    _paidAmountController.text = ref.read(generalPaidAmountProvider);
    
    // If there's only one membership type, select it automatically
    if (widget.membershipTypes.length == 1) {
      final type = widget.membershipTypes.first;
      final id = type['id'] as int? ?? 0;
      
      // Only set if not already set
      if (ref.read(selectedGeneralMembershipTypeProvider) == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(selectedGeneralMembershipTypeProvider.notifier).state = id;
          
          // Also set the amount
          if (type.containsKey('amount')) {
            final amount = type['amount'].toString();
            ref.read(generalPaidAmountProvider.notifier).state = amount;
            _paidAmountController.text = amount;
          }
        });
      }
    }
  }
  
  @override
  void dispose() {
    _dobController.dispose();
    _paidAmountController.dispose();
    _countrySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    
    // Ref providers
    final selectedMembershipType = ref.watch(selectedGeneralMembershipTypeProvider);
    final firstName = ref.watch(firstNameProvider);
    final middleName = ref.watch(middleNameProvider);
    final lastName = ref.watch(lastNameProvider);
    final dob = ref.watch(dobProvider);
    final selectedCountryId = ref.watch(selectedCountryIdProvider);
    final selectedStateId = ref.watch(selectedStateIdProvider);
    final address = ref.watch(addressProvider);
    final email = ref.watch(emailProvider);
    final phone = ref.watch(phoneProvider);
    final paidAmount = ref.watch(generalPaidAmountProvider);
    
    // Update controller if provider value changes
    if (_paidAmountController.text != paidAmount) {
      _paidAmountController.text = paidAmount;
    }
    
    // Fetch countries
    final countriesAsync = ref.watch(countryListProvider);
    
    // Fetch states if country is selected
    final statesAsync = selectedCountryId != null 
        ? ref.watch(stateListProvider(selectedCountryId))
        : const AsyncValue.data([]);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Membership Type Dropdown
          _buildSectionTitle('Membership Type'),
          _buildMembershipDropdown(selectedMembershipType),
          const SizedBox(height: 16),

          // Personal Details
          _buildSectionTitle('Personal Details'),
          
          // First Name
          _buildTextFormField(
            labelText: 'First Name',
            value: firstName,
            onChanged: (value) => ref.read(firstNameProvider.notifier).state = value,
            validator: (value) => value.isEmpty ? 'Please enter first name' : null,
          ),
          const SizedBox(height: 12),
          
          // Middle Name
          _buildTextFormField(
            labelText: 'Middle Name (Optional)',
            value: middleName,
            onChanged: (value) => ref.read(middleNameProvider.notifier).state = value,
            validator: null, // Optional field
          ),
          const SizedBox(height: 12),
          
          // Last Name
          _buildTextFormField(
            labelText: 'Last Name',
            value: lastName,
            onChanged: (value) => ref.read(lastNameProvider.notifier).state = value,
            validator: (value) => value.isEmpty ? 'Please enter last name' : null,
          ),
          const SizedBox(height: 12),
          
          // Date of Birth
          _buildDateField(
            labelText: 'Date of Birth',
            controller: _dobController,
            onTap: () => _selectDate(context),
            value: dob,
            onChanged: (value) => ref.read(dobProvider.notifier).state = value,
            validator: (value) => value.isEmpty ? 'Please select date of birth' : null,
          ),
          const SizedBox(height: 12),
          
          // Email
          _buildTextFormField(
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
            value: email,
            onChanged: (value) => ref.read(emailProvider.notifier).state = value,
            validator: (value) => _validateEmail(value),
          ),
          const SizedBox(height: 12),
          
          // Phone
          _buildTextFormField(
            labelText: 'Phone',
            keyboardType: TextInputType.phone,
            value: phone,
            onChanged: (value) => ref.read(phoneProvider.notifier).state = value,
            validator: (value) => value.isEmpty ? 'Please enter phone number' : null,
          ),
          const SizedBox(height: 16),

          // Address Information
          _buildSectionTitle('Address Information'),
          
          // Country
          countriesAsync.when(
            data: (countries) {
              // Initialize filtered countries if needed
              if (_filteredCountries.isEmpty && !_isSearchingCountry) {
                _filteredCountries = List.from(countries);
              }
              return _buildImprovedCountryDropdown(countries, selectedCountryId);
            },
            loading: () => const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Text(
              'Failed to load countries',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
          const SizedBox(height: 12),
          
          // State (if country selected)
          if (selectedCountryId != null)
            statesAsync.when(
              data: (states) => _buildStateDropdown(states, selectedStateId),
              loading: () => const SizedBox(
                height: 60, 
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) {
                debugPrint('Error loading states: $error');
                debugPrint('Stack: $stack');
                return Text(
                  'Failed to load states: ${error.toString().substring(0, Math.min(error.toString().length, 100))}...',
                  style: GoogleFonts.poppins(color: Colors.red),
                );
              },
            ),
          if (selectedCountryId != null) const SizedBox(height: 12),
          
          // Address
          _buildTextFormField(
            labelText: 'Address',
            maxLines: 2,
            value: address,
            onChanged: (value) => ref.read(addressProvider.notifier).state = value,
            validator: (value) => value.isEmpty ? 'Please enter address' : null,
          ),
          const SizedBox(height: 16),

          // Payment Information
          _buildSectionTitle('Payment Information'),
          
          // Paid Amount - Using controller instead of value
          TextFormField(
            controller: _paidAmountController, 
            keyboardType: TextInputType.number,
            enabled: false, // Amount is set based on membership type
            decoration: InputDecoration(
              labelText: 'Paid Amount',
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14),
            validator: (value) => (value?.isEmpty ?? true) ? 'Please enter paid amount' : null,
          ),
          const SizedBox(height: 24),

          // Next Button
          Center(
            child: SizedBox(
              width: screenWidth * 0.8,
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF205EB5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Membership Type Dropdown with fixed amount setting
  Widget _buildMembershipDropdown(int? selectedMembershipType) {
    try {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<int>(
            value: selectedMembershipType,
            onChanged: (value) {
              // Update selected membership type
              ref.read(selectedGeneralMembershipTypeProvider.notifier).state = value;
              
              // Find the selected membership type and update amount
              if (value != null) {
                // Find the type in the list
                for (var type in widget.membershipTypes) {
                  if (type['id'] == value) {
                    // Get amount regardless of type (int, double, String)
                    final amount = type['amount'];
                    if (amount != null) {
                      final amountString = amount.toString();
                      debugPrint('Setting amount from membership type: $amountString (type: ${amount.runtimeType})');
                      
                      // Update both the provider and the controller immediately
                      ref.read(generalPaidAmountProvider.notifier).state = amountString;
                      
                      // Ensure UI updates by explicitly setting controller text
                      setState(() {
                        _paidAmountController.text = amountString;
                      });
                    }
                    break;
                  }
                }
              }
            },
            items: widget.membershipTypes.map<DropdownMenuItem<int>>((Map<String, dynamic> type) {
              // Get currency and amount values safely
              final currency = type['currency'] ?? 'USD';
              final amount = type['amount']?.toString() ?? '0';
              final typeStr = type['type'] ?? 'Unknown';
              
              return DropdownMenuItem<int>(
                value: type['id'] as int? ?? 0,
                child: Text(
                  '$typeStr - $currency $amount',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Select Membership Type',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            validator: (value) => value == null ? 'Please select a membership type' : null,
            menuMaxHeight: 300,
            isExpanded: true,
            dropdownColor: Colors.white,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error building membership dropdown: $e');
      return Text('Error: Unable to load membership types', 
        style: GoogleFonts.poppins(color: Colors.red));
    }
  }

  // Improved Country Dropdown with Search
  Widget _buildImprovedCountryDropdown(List<Map<String, dynamic>> countries, int? selectedCountryId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Currently selected country display
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearchingCountry = true;
              _filteredCountries = List.from(countries);
            });
            // Give focus to the search field after showing it
            Future.delayed(const Duration(milliseconds: 100), () {
              FocusScope.of(context).requestFocus();
            });
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCountryId != null
                      ? countries.firstWhere(
                          (country) => country['id'] == selectedCountryId,
                          orElse: () => {'name': 'Select Country'},
                        )['name'] ?? 'Select Country'
                      : 'Select Country',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: selectedCountryId != null ? Colors.black : Colors.grey,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        
        // Search and dropdown (shown conditionally)
        if (_isSearchingCountry)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _countrySearchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      hintText: 'Search country',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _isSearchingCountry = false;
                            _countrySearchController.clear();
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          _filteredCountries = List.from(countries);
                        } else {
                          _filteredCountries = countries
                              .where((country) => country['name'].toString().toLowerCase().contains(value.toLowerCase()))
                              .toList();
                        }
                      });
                    },
                  ),
                ),
                
                // Dropdown list
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    minWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final id = country['id'] is int 
                          ? country['id'] as int 
                          : int.tryParse(country['id'].toString()) ?? 0;
                      final name = country['name'] != null 
                          ? country['name'].toString() 
                          : 'Unknown';
                          
                      return InkWell(
                        onTap: () {
                          setState(() {
                            ref.read(selectedCountryIdProvider.notifier).state = id;
                            ref.read(selectedStateIdProvider.notifier).state = null;
                            _isSearchingCountry = false;
                            _countrySearchController.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
                            name,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Fixed state dropdown
  Widget _buildStateDropdown(List<dynamic> states, int? selectedStateId) {
    debugPrint('Building state dropdown with ${states.length} states');
    
    // Log the structure of the first state for debugging
    if (states.isNotEmpty) {
      debugPrint('Sample state structure: ${states.first}');
    }
    
    // Check if states list is empty
    if (states.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No states available for selected country',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      );
    }
    
    try {
      // Create the list of items manually with complete null safety
      List<DropdownMenuItem<int>> stateItems = [];
      
      for (var state in states) {
        // Skip any state entries with null data
        if (state == null) continue;
        
        // Extract id with null checks - Fix for API structure
        var id = state['id'];
        
        // Extract name with null checks - IMPORTANT FIX: API returns state_name not name
        var name = state['state_name'];  
        
        if (id == null || name == null) {
          debugPrint('Skipping state with null id or name: $state');
          continue;
        }
        
        // Convert id to int safely
        int stateId;
        try {
          stateId = id is int ? id : int.parse(id.toString());
        } catch (e) {
          debugPrint('Failed to parse state ID: $id - Error: $e');
          continue;
        }
        
        // Convert name to string safely
        String stateName = name.toString();
        
        // Create dropdown item
        stateItems.add(DropdownMenuItem<int>(
          value: stateId,
          child: Text(
            stateName,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ));
      }
      
      if (stateItems.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'State data format is invalid',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
        );
      }
      
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<int>(
            value: selectedStateId,
            onChanged: (value) {
              debugPrint('State selected: $value');
              ref.read(selectedStateIdProvider.notifier).state = value;
            },
            items: stateItems,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Select State',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            menuMaxHeight: 300,
            isExpanded: true,
            dropdownColor: Colors.white,
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('Error building states dropdown: $e');
      debugPrint('Stack trace: $stack');
      return Text(
        'Error building state dropdown: ${e.toString().substring(0, Math.min(e.toString().length, 100))}...',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.red,
        ),
      );
    }
  }
  
  // Build section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF205EB5),
        ),
      ),
    );
  }

  // Build text form field
  Widget _buildTextFormField({
    required String labelText,
    required String value,
    required Function(String) onChanged,
    required String? Function(String)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[700],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 14),
      validator: (value) => validator?.call(value ?? ''),
    );
  }

  // Build date field
  Widget _buildDateField({
    required String labelText,
    required TextEditingController controller,
    required VoidCallback onTap,
    required String value,
    required Function(String) onChanged,
    required String? Function(String)? validator,
  }) {
    controller.text = value;
    
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[700],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      style: GoogleFonts.poppins(fontSize: 14),
      validator: (value) => validator?.call(value ?? ''),
    );
  }

  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _dobController.text = formattedDate;
      });
      ref.read(dobProvider.notifier).state = formattedDate;
    }
  }

  // Email validation
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter an email address';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
}

// Helper for math operations (avoiding import)
class Math {
  static int min(int a, int b) => a < b ? a : b;
}











