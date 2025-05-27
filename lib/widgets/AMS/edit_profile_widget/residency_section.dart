import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ems/models/edit_user_details.dart';
import 'package:ems/utils/responsive_utils.dart';

class ResidencySection extends StatefulWidget {
  final EditUserDetail edituserDetail;
  final Function(
    String isAusPermanentResident,
    String countryOfLiving,
    String currentStateId,
    String residentialAddress,
    String postCode,
    String visaType,
    String passportNumber,
    String passportExpiryDate,
  ) onSave;

  final Map<String, String> countriesMap;
  final Map<String, String> statesMap;
  final List<String> visaTypes;

  const ResidencySection({
    Key? key,
    required this.edituserDetail,
    required this.onSave,
    required this.countriesMap,
    required this.statesMap,
    required this.visaTypes,
  }) : super(key: key);

  @override
  State<ResidencySection> createState() => _ResidencySectionState();
}

class _ResidencySectionState extends State<ResidencySection> {
  late bool _isAustralianResident;
  late String _selectedCurrentCountry;
  late String _selectedCurrentState;
  late String _selectedVisaType;
  late TextEditingController _residentialAddressController;
  late TextEditingController _postalCodeController;
  late TextEditingController _passportNumberController;
  late TextEditingController _passportExpiryController;

  @override
  void initState() {
    super.initState();
    _isAustralianResident = widget.edituserDetail.isAusPermanentResident == '1';
    _selectedCurrentCountry = widget.edituserDetail.countryOfLiving;
    _selectedCurrentState = widget.edituserDetail.currentStateId;
    _selectedVisaType = widget.edituserDetail.visaType;
    _residentialAddressController = TextEditingController(text: widget.edituserDetail.residentialAddress);
    _postalCodeController = TextEditingController(text: widget.edituserDetail.postCode);
    _passportNumberController = TextEditingController(text: widget.edituserDetail.passportNumber);
    _passportExpiryController = TextEditingController(text: widget.edituserDetail.passportExpiryDate);
    
    // Add listeners to controllers to save data when text changes
    _residentialAddressController.addListener(_saveData);
    _postalCodeController.addListener(_saveData);
    _passportNumberController.addListener(_saveData);
    _passportExpiryController.addListener(_saveData);
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final isEditable = widget.edituserDetail.editableFields['passportExpiryDate'] ?? true;
    if (!isEditable) return; // Don't show date picker if not editable
    
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

  void _saveData() {
    widget.onSave(
      _isAustralianResident ? '1' : '0',
      _selectedCurrentCountry,
      _selectedCurrentState,
      _residentialAddressController.text,
      _postalCodeController.text,
      _selectedVisaType,
      _passportNumberController.text,
      _passportExpiryController.text,
    );
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _residentialAddressController.removeListener(_saveData);
    _postalCodeController.removeListener(_saveData);
    _passportNumberController.removeListener(_saveData);
    _passportExpiryController.removeListener(_saveData);
    
    _residentialAddressController.dispose();
    _postalCodeController.dispose();
    _passportNumberController.dispose();
    _passportExpiryController.dispose();
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
            _buildSectionHeader('Residency Information', widget.edituserDetail.commencementDate),
            _buildSectionSubtitle('Residential information'),
            const SizedBox(height: 16),
            
            _buildAustralianResidenceSelection(),
            
            const SizedBox(height: 16),
            
            // For desktop and tablet, show two columns
            if (isDesktop || isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: Column(
                      children: [
                        _buildDropdown(
                          label: 'Currently Living Country',
                          items: widget.countriesMap,
                          selectedValue: _selectedCurrentCountry,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCurrentCountry = value;
                                _saveData();
                              });
                            }
                          },
                          isEditable: widget.edituserDetail.editableFields['countryOfLiving'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Residential Address',
                          controller: _residentialAddressController,
                          isEditable: widget.edituserDetail.editableFields['residentialAddress'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Passport Number',
                          controller: _passportNumberController,
                          isEditable: widget.edituserDetail.editableFields['passportNumber'] ?? false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right column
                  Expanded(
                    child: Column(
                      children: [
                        _buildDropdown(
                          label: 'State',
                          items: widget.statesMap,
                          selectedValue: _selectedCurrentState,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCurrentState = value;
                                _saveData();
                              });
                            }
                          },
                          isEditable: widget.edituserDetail.editableFields['currentStateId'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Postal Code',
                          controller: _postalCodeController,
                          keyboardType: TextInputType.number,
                          isEditable: widget.edituserDetail.editableFields['postCode'] ?? true,
                        ),
                        const SizedBox(height: 16),
                        _buildDatePicker(
                          label: 'Passport Expiry Date',
                          controller: _passportExpiryController,
                          isEditable: widget.edituserDetail.editableFields['passportExpiryDate'] ?? true,
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
                  _buildDropdown(
                    label: 'Currently Living Country',
                    items: widget.countriesMap,
                    selectedValue: _selectedCurrentCountry,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCurrentCountry = value;
                          _saveData();
                        });
                      }
                    },
                    isEditable: widget.edituserDetail.editableFields['countryOfLiving'] ?? true,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'State',
                    items: widget.statesMap,
                    selectedValue: _selectedCurrentState,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCurrentState = value;
                          _saveData();
                        });
                      }
                    },
                    isEditable: widget.edituserDetail.editableFields['currentStateId'] ?? true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Residential Address',
                    controller: _residentialAddressController,
                    isEditable: widget.edituserDetail.editableFields['residentialAddress'] ?? true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Postal Code',
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                    isEditable: widget.edituserDetail.editableFields['postCode'] ?? true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Passport Number',
                    controller: _passportNumberController,
                    isEditable: widget.edituserDetail.editableFields['passportNumber'] ?? false,
                  ),
                  const SizedBox(height: 16),
                  _buildDatePicker(
                    label: 'Passport Expiry Date',
                    controller: _passportExpiryController,
                    isEditable: widget.edituserDetail.editableFields['passportExpiryDate'] ?? true,
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Visa Type',
              items: {for (var e in widget.visaTypes) e: e},
              selectedValue: _selectedVisaType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedVisaType = value;
                    _saveData();
                  });
                }
              },
              isEditable: widget.edituserDetail.editableFields['visaType'] ?? false,
            ),
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
            fillColor: isEditable ? Colors.white : Colors.grey[100], // Grey background for non-editable fields
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
          readOnly: true, // Always read-only as it's a date picker
          onTap: isEditable ? () => _selectDate(context, controller) : null, // Only show date picker if editable
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
            fillColor: isEditable ? Colors.white : Colors.grey[100], // Grey background for non-editable fields
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
            color: isEditable ? Colors.white : Colors.grey[100], // Grey background for non-editable fields
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
                onChanged: isEditable ? onChanged : null, // Disable dropdown if not editable
                icon: isEditable ? const Icon(Icons.keyboard_arrow_down) : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAustralianResidenceSelection() {
    final bool isEditable = widget.edituserDetail.editableFields['isAusPermanentResident'] ?? true;
    
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
                      value: true,
                      groupValue: _isAustralianResident,
                      activeColor: const Color.fromARGB(255, 227, 10, 169),
                      onChanged: isEditable ? (value) {
                        setState(() {
                          _isAustralianResident = value as bool;
                          _saveData();
                        });
                      } : null,
                    ),
                    const Text('Yes'),
                  ],
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.isMobile(context) ? null : 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(
                      value: false,
                      groupValue: _isAustralianResident,
                      activeColor: const Color.fromARGB(255, 227, 10, 169),
                      onChanged: isEditable ? (value) {
                        setState(() {
                          _isAustralianResident = value as bool;
                          _saveData();
                        });
                      } : null,
                    ),
                    const Text('No'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}














// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:ems/models/edit_user_details.dart';
// import 'package:ems/utils/responsive_utils.dart';

// class ResidencySection extends StatefulWidget {
//   final EditUserDetail edituserDetail;
//   final Function(
//     String isAusPermanentResident,
//     String countryOfLiving,
//     String currentStateId,
//     String residentialAddress,
//     String postCode,
//     String visaType,
//     String passportNumber,
//     String passportExpiryDate,
//   ) onSave;

//   final Map<String, String> countriesMap;
//   final Map<String, String> statesMap;
//   final List<String> visaTypes;

//   const ResidencySection({
//     Key? key,
//     required this.edituserDetail,
//     required this.onSave,
//     required this.countriesMap,
//     required this.statesMap,
//     required this.visaTypes,
//   }) : super(key: key);

//   @override
//   State<ResidencySection> createState() => _ResidencySectionState();
// }

// class _ResidencySectionState extends State<ResidencySection> {
//   late bool _isAustralianResident;
//   late String _selectedCurrentCountry;
//   late String _selectedCurrentState;
//   late String _selectedVisaType;
//   late TextEditingController _residentialAddressController;
//   late TextEditingController _postalCodeController;
//   late TextEditingController _passportNumberController;
//   late TextEditingController _passportExpiryController;

//   @override
//   void initState() {
//     super.initState();
//     _isAustralianResident = widget.edituserDetail.isAusPermanentResident == '1';
//     _selectedCurrentCountry = widget.edituserDetail.countryOfLiving;
//     _selectedCurrentState = widget.edituserDetail.currentStateId;
//     _selectedVisaType = widget.edituserDetail.visaType;
//     _residentialAddressController = TextEditingController(text: widget.edituserDetail.residentialAddress);
//     _postalCodeController = TextEditingController(text: widget.edituserDetail.postCode);
//     _passportNumberController = TextEditingController(text: widget.edituserDetail.passportNumber);
//     _passportExpiryController = TextEditingController(text: widget.edituserDetail.passportExpiryDate);
//   }

//   Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
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
//       });
//     }
//   }

//   void _saveData() {
//     widget.onSave(
//       _isAustralianResident ? '1' : '0',
//       _selectedCurrentCountry,
//       _selectedCurrentState,
//       _residentialAddressController.text,
//       _postalCodeController.text,
//       _selectedVisaType,
//       _passportNumberController.text,
//       _passportExpiryController.text,
//     );
//   }

//   @override
//   void dispose() {
//     _residentialAddressController.dispose();
//     _postalCodeController.dispose();
//     _passportNumberController.dispose();
//     _passportExpiryController.dispose();
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
//             _buildSectionHeader('Residency Information', widget.edituserDetail.commencementDate),
//             _buildSectionSubtitle('Residential information'),
//             const SizedBox(height: 16),
            
//             _buildAustralianResidenceSelection(),
            
//             const SizedBox(height: 16),
            
//             // For desktop and tablet, show two columns
//             if (isDesktop || isTablet)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Left column
//                   Expanded(
//                     child: Column(
//                       children: [
//                         _buildDropdown(
//                           label: 'Currently Living Country',
//                           items: widget.countriesMap,
//                           selectedValue: _selectedCurrentCountry,
//                           onChanged: (value) {
//                             if (value != null) {
//                               setState(() {
//                                 _selectedCurrentCountry = value;
//                               });
//                             }
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           label: 'Residential Address',
//                           controller: _residentialAddressController,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           label: 'Passport Number',
//                           controller: _passportNumberController,
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   // Right column
//                   Expanded(
//                     child: Column(
//                       children: [
//                         _buildDropdown(
//                           label: 'State',
//                           items: widget.statesMap,
//                           selectedValue: _selectedCurrentState,
//                           onChanged: (value) {
//                             if (value != null) {
//                               setState(() {
//                                 _selectedCurrentState = value;
//                               });
//                             }
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         _buildTextField(
//                           label: 'Postal Code',
//                           controller: _postalCodeController,
//                           keyboardType: TextInputType.number,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildDatePicker(
//                           label: 'Passport Expiry Date',
//                           controller: _passportExpiryController,
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
//                   _buildDropdown(
//                     label: 'Currently Living Country',
//                     items: widget.countriesMap,
//                     selectedValue: _selectedCurrentCountry,
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           _selectedCurrentCountry = value;
//                         });
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDropdown(
//                     label: 'State',
//                     items: widget.statesMap,
//                     selectedValue: _selectedCurrentState,
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           _selectedCurrentState = value;
//                         });
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     label: 'Residential Address',
//                     controller: _residentialAddressController,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     label: 'Postal Code',
//                     controller: _postalCodeController,
//                     keyboardType: TextInputType.number,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     label: 'Passport Number',
//                     controller: _passportNumberController,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDatePicker(
//                     label: 'Passport Expiry Date',
//                     controller: _passportExpiryController,
//                   ),
//                 ],
//               ),
            
//             const SizedBox(height: 16),
//             _buildDropdown(
//               label: 'Visa Type',
//               items: {for (var e in widget.visaTypes) e: e},
//               selectedValue: _selectedVisaType,
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     _selectedVisaType = value;
//                   });
//                 }
//               },
//             ),
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
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           onChanged: (_) => _saveData(),
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
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.red),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//           validator: validator,
//         ),
//       ],
//     );
//   }

//   Widget _buildDatePicker({
//     required String label,
//     required TextEditingController controller,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           readOnly: true,
//           onTap: () => _selectDate(context, controller),
//           onChanged: (_) => _saveData(),
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
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Colors.red),
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             suffixIcon: const Icon(Icons.calendar_today_outlined),
//           ),
//           validator: validator,
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required Map<String, String> items,
//     required String selectedValue,
//     required void Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         DecoratedBox(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: items.containsKey(selectedValue) ? selectedValue : items.keys.first,
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
//                 onChanged: (value) {
//                   onChanged(value);
//                   _saveData();
//                 },
//                 icon: const Icon(Icons.keyboard_arrow_down),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAustralianResidenceSelection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Are you an Australian permanent residence?',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           children: [
//             SizedBox(
//               width: ResponsiveUtils.isMobile(context) ? null : 120,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Radio(
//                     value: true,
//                     groupValue: _isAustralianResident,
//                     activeColor: const Color.fromARGB(255, 227, 10, 169),
//                     onChanged: (value) {
//                       setState(() {
//                         _isAustralianResident = value as bool;
//                         _saveData();
//                       });
//                     },
//                   ),
//                   const Text('Yes'),
//                 ],
//               ),
//             ),
//             SizedBox(
//               width: ResponsiveUtils.isMobile(context) ? null : 120,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Radio(
//                     value: false,
//                     groupValue: _isAustralianResident,
//                     activeColor: const Color.fromARGB(255, 227, 10, 169),
//                     onChanged: (value) {
//                       setState(() {
//                         _isAustralianResident = value as bool;
//                         _saveData();
//                       });
//                     },
//                   ),
//                   const Text('No'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }