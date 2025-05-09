import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ems/services/membership_card_services.dart';

class MembershipForm extends StatefulWidget {
  final Function onSubmit;
  final List<Map<String, dynamic>>? membershipTypes;

  const MembershipForm({super.key, required this.onSubmit, this.membershipTypes});
  @override
  State<MembershipForm> createState() => _MembershipFormState();
}

class _MembershipFormState extends State<MembershipForm> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedMembershipTypeId;
  final TextEditingController _paidAmountController = TextEditingController();
  File? _paymentSlip;
  bool _isLoading = false;
  List<Map<String, dynamic>> _membershipTypes = [];
  final ImagePicker _picker = ImagePicker();
  // String? _selectedTypeName;

  @override
  void initState() {
    super.initState();
    if (widget.membershipTypes != null && widget.membershipTypes!.isNotEmpty) {
      setState(() {
        _membershipTypes = widget.membershipTypes!;
      });
    } else {
      _fetchMembershipTypes();
    }
  }

  Future<void> _fetchMembershipTypes() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Fetch from API
      final types = await MembershipCardService.getMembershipTypes();
      
      setState(() {
        _membershipTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading membership types: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _getPaymentSlip(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _paymentSlip = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Payment Slip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF205EB5),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt, color: Color(0xFF205EB5)),
                ),
                title: Text('Take Photo', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _getPaymentSlip(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.photo_library, color: Color(0xFF205EB5)),
                ),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _getPaymentSlip(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePaidAmount(int typeId) {
    // Find the type by ID
    final selectedType = _membershipTypes.firstWhere(
      (element) => element['id'] == typeId,
      orElse: () => {'amount': 0, 'type': 'Unknown'},
    );
    
    // Update paid amount and selected type name
    setState(() {
      _paidAmountController.text = selectedType['amount'].toString();
      // _selectedTypeName = selectedType['type'];
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_paymentSlip == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload payment slip'),
          ),
        );
        return;
      }
      
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Prepare form data matching the API expectations
        Map<String, dynamic> formData = {
          'card_type_id': _selectedMembershipTypeId.toString(),
          'amount': _paidAmountController.text,
          'payment_slip': _paymentSlip,
        };
        
        // Submit to parent handler
        widget.onSubmit(formData);
      } catch (e) {
        // Show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apply for Membership Card',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111213),
                ),
              ),
              const SizedBox(height: 16),
              
              // Membership Type
              Text(
                'Membership Type',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Color(0xFF205EB5),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF205EB5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    hintText: 'Select membership type',
                    hintStyle: GoogleFonts.poppins(
                      color: Color(0xFFA1A1A1),
                    ),
                  ),
                  value: _selectedMembershipTypeId,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a membership type';
                    }
                    return null;
                  },
                  items: _membershipTypes.map((type) {
                    return DropdownMenuItem<int>(
                      value: type['id'],
                      child: Text(
                        '${type['type']} - ${type['currency']} ${type['amount']}',
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMembershipTypeId = value;
                      if (value != null) {
                        _updatePaidAmount(value);
                      }
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF205EB5),
                  ),
                  dropdownColor: Colors.white,
                  isExpanded: true,
                ),
              ),
              const SizedBox(height: 24),
              
              // Paid Amount
              Text(
                'Paid Amount (AUD/NPR)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Color(0xFF205EB5),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _paidAmountController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF205EB5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF205EB5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF205EB5)),
                  ),
                  hintStyle: GoogleFonts.poppins(),
                ),
                style: GoogleFonts.poppins(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter paid amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 26),
              
              // Payment Slip
              Text(
                'Payment Slip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Color(0xFF205EB5),
                ),
              ),
              const SizedBox(height: 8),
              _paymentSlip != null
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF205EB5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _paymentSlip!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: IconButton(
                              icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  _paymentSlip = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: _showImageSourceOptions,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF205EB5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 48,
                              color: Color(0xFF205EB5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Upload Payment Slip',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF205EB5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Take a photo or choose from gallery',
                              style: GoogleFonts.poppins(
                                color: Color(0xFFA1A1A1),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF205EB5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Submit Application',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:ems/services/membership_card_services.dart';
// import 'dart:developer' as developer;

// class MembershipForm extends StatefulWidget {
//   final Function onSubmit;
//   final List<Map<String, dynamic>>? membershipTypes; // Accept types from parent

//   const MembershipForm({
//     Key? key,
//     required this.onSubmit,
//     this.membershipTypes, // Make it optional for backward compatibility
//   }) : super(key: key);

//   @override
//   State<MembershipForm> createState() => _MembershipFormState();
// }

// class _MembershipFormState extends State<MembershipForm> {
//   final _formKey = GlobalKey<FormState>();
//   int? _selectedMembershipTypeId;
//   final TextEditingController _paidAmountController = TextEditingController();
//   File? _paymentSlip;
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _membershipTypes = [];
//   final ImagePicker _picker = ImagePicker();
//   // String? _selectedTypeName;

//   @override
//   void initState() {
//     super.initState();
//     // Use provided types or fetch them
//     if (widget.membershipTypes != null && widget.membershipTypes!.isNotEmpty) {
//       setState(() {
//         _membershipTypes = widget.membershipTypes!;
//       });
//       developer.log('Using provided membership types: ${_membershipTypes.length}');
//     } else {
//       _fetchMembershipTypes();
//     }
//   }

//   Future<void> _fetchMembershipTypes() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       developer.log("Fetching membership types...");
      
//       // Fetch from API
//       final types = await MembershipCardService.getMembershipTypes();
      
//       developer.log("Received types: ${types.length}");
      
//       // Debug print membership types
//       for (var type in types) {
//         developer.log("Type: ${type['type']} - ID: ${type['id']} - Amount: ${type['amount']} - Currency: ${type['currency']}");
//       }
      
//       setState(() {
//         _membershipTypes = types;
//         _isLoading = false;
//       });
//     } catch (e) {
//       developer.log("Error in _fetchMembershipTypes: $e");
      
//       setState(() {
//         _isLoading = false;
//       });
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error loading membership types: $e'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 5),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _getPaymentSlip(ImageSource source) async {
//     try {
//       final XFile? photo = await _picker.pickImage(
//         source: source,
//         imageQuality: 80,
//       );

//       if (photo != null) {
//         setState(() {
//           _paymentSlip = File(photo.path);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error selecting image: $e')),
//       );
//     }
//   }

//   void _showImageSourceOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Select Payment Slip',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.deepPurple[800],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.deepPurple[100],
//                   child: Icon(Icons.camera_alt, color: Colors.deepPurple[800]),
//                 ),
//                 title: Text('Take Photo', style: GoogleFonts.poppins()),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _getPaymentSlip(ImageSource.camera);
//                 },
//               ),
//               const SizedBox(height: 8),
//               ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.deepPurple[100],
//                   child: Icon(Icons.photo_library, color: Colors.deepPurple[800]),
//                 ),
//                 title: Text('Choose from Gallery', style: GoogleFonts.poppins()),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _getPaymentSlip(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _updatePaidAmount(int typeId) {
//     // Find the type by ID
//     final selectedType = _membershipTypes.firstWhere(
//       (element) => element['id'] == typeId,
//       orElse: () => {'amount': 0, 'type': 'Unknown'},
//     );
    
//     // Update paid amount and selected type name
//     setState(() {
//       _paidAmountController.text = selectedType['amount'].toString();
//       // _selectedTypeName = selectedType['type'];
//     });
    
//     developer.log('Selected type: ${selectedType['type']}, Amount: ${selectedType['amount']}');
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       if (_paymentSlip == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please upload payment slip'),
//           ),
//         );
//         return;
//       }
      
//       // Show loading indicator
//       setState(() {
//         _isLoading = true;
//       });
      
//       try {
//         // Prepare form data matching the API expectations
//         Map<String, dynamic> formData = {
//           'card_type_id': _selectedMembershipTypeId.toString(), // API expects card_type_id
//           'amount': _paidAmountController.text, // API expects amount
//           'payment_slip': _paymentSlip, // API expects payment_slip
//         };
        
//         developer.log('Submitting form data: $formData');
        
//         // Submit to parent handler
//         widget.onSubmit(formData);
//       } catch (e) {
//         // Show error
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: $e')),
//           );
//         }
        
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     return Card(
//       elevation: 4.0,
//       margin: const EdgeInsets.all(8.0),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Apply for Membership Card',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Debug info for troubleshooting
//               if (_membershipTypes.isEmpty)
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.yellow[100],
//                     borderRadius: BorderRadius.circular(4),
//                     border: Border.all(color: Colors.orange),
//                   ),
//                   child: Text(
//                     'No membership types available. Please refresh or contact support.',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.orange[800],
//                     ),
//                   ),
//                 ),
              
//               // Membership Type
//               Text(
//                 'Membership Type',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.deepPurple[800],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.deepPurple.shade200),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: DropdownButtonFormField<int>(
//                   decoration: InputDecoration(
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     border: InputBorder.none,
//                     focusedBorder: InputBorder.none,
//                     enabledBorder: InputBorder.none,
//                     errorBorder: InputBorder.none,
//                     disabledBorder: InputBorder.none,
//                     fillColor: Colors.transparent,
//                     hintText: 'Select membership type',
//                     hintStyle: GoogleFonts.poppins(
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   value: _selectedMembershipTypeId,
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select a membership type';
//                     }
//                     return null;
//                   },
//                   // Use ID as value instead of type name
//                   items: _membershipTypes.map((type) {
//                     return DropdownMenuItem<int>(
//                       value: type['id'],
//                       child: Text(
//                         '${type['type']} - ${type['currency']} ${type['amount']}',
//                         style: GoogleFonts.poppins(),
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedMembershipTypeId = value;
//                       if (value != null) {
//                         _updatePaidAmount(value);
//                       }
//                     });
//                   },
//                   icon: Icon(
//                     Icons.arrow_drop_down,
//                     color: Colors.deepPurple[800],
//                   ),
//                   dropdownColor: Colors.white,
//                   isExpanded: true,
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Paid Amount
//               Text(
//                 'Paid Amount (AUD/NPR)',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.deepPurple[800],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _paidAmountController,
//                 decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: Colors.deepPurple.shade200),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: Colors.deepPurple.shade200),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: BorderSide(color: Colors.deepPurple.shade400),
//                   ),
//                   hintStyle: GoogleFonts.poppins(),
//                 ),
//                 style: GoogleFonts.poppins(),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter paid amount';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter a valid amount';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
              
//               // Payment Slip
//               Text(
//                 'Payment Slip',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.deepPurple[800],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               _paymentSlip != null
//                   ? Stack(
//                       alignment: Alignment.topRight,
//                       children: [
//                         Container(
//                           height: 200,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.deepPurple.shade200),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.file(
//                               _paymentSlip!,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: CircleAvatar(
//                             backgroundColor: Colors.white,
//                             radius: 16,
//                             child: IconButton(
//                               icon: Icon(Icons.close, size: 16, color: Colors.red[700]),
//                               padding: EdgeInsets.zero,
//                               onPressed: () {
//                                 setState(() {
//                                   _paymentSlip = null;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   : InkWell(
//                       onTap: _showImageSourceOptions,
//                       child: Container(
//                         height: 150,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.deepPurple.shade200),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.photo_library,
//                               size: 48,
//                               color: Colors.deepPurple[400],
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               'Upload Payment Slip',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.deepPurple[800],
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Take a photo or choose from gallery',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//               const SizedBox(height: 32),
              
//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _submitForm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple[600],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   ),
//                   child: _isLoading 
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           'Submit Application',
//                           style: GoogleFonts.poppins(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 16,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


