import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ems/services/membership_card_services.dart';

class MembershipForm extends StatefulWidget {
  final Function onSubmit;

  const MembershipForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<MembershipForm> createState() => _MembershipFormState();
}

class _MembershipFormState extends State<MembershipForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMembershipType;
  final TextEditingController _paidAmountController = TextEditingController();
  File? _paymentSlip;
  bool _isLoading = false;
  List<Map<String, dynamic>> _membershipTypes = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchMembershipTypes();
  }

  Future<void> _fetchMembershipTypes() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // print("Fetching membership types..."); // Debug print
      
      // Fetch from API
      final types = await MembershipCardService.getMembershipTypes();
      
      // print("Received types: ${types.length}"); // Debug print
      
      // Debug print membership types
      // for (var type in types) {
        // print("Type: ${type['type']} - Amount: ${type['amount']} - Currency: ${type['currency']}");
      // }
      
      setState(() {
        _membershipTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      // print("Error in _fetchMembershipTypes: $e"); // Debug print
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading membership types: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple[100],
                  child: Icon(Icons.camera_alt, color: Colors.deepPurple[800]),
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
                  backgroundColor: Colors.deepPurple[100],
                  child: Icon(Icons.photo_library, color: Colors.deepPurple[800]),
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

  void _updatePaidAmount(String type) {
    // Changed from 'name' to 'type' to match the API response
    final selectedType = _membershipTypes.firstWhere(
      (element) => element['type'] == type,
      orElse: () => {'amount': 0},
    );
    
    _paidAmountController.text = selectedType['amount'].toString();
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
        // Prepare form data
        Map<String, dynamic> formData = {
          'membershipType': _selectedMembershipType,
          'paidAmount': _paidAmountController.text,
          'paymentSlip': _paymentSlip,
        };
        
        // Submit to parent handler
        widget.onSubmit(formData);
      } catch (e) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // Membership Type
              Text(
                'Membership Type',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.deepPurple[800],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
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
                      color: Colors.grey[600],
                    ),
                  ),
                  value: _selectedMembershipType,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a membership type';
                    }
                    return null;
                  },
                  // Changed 'name' to 'type' to match the API response structure
                  items: _membershipTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['type'],
                      child: Text(
                        '${type['type']} - ${type['currency']} ${type['amount']}',
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMembershipType = value;
                      _updatePaidAmount(value!);
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.deepPurple[800],
                  ),
                  dropdownColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Paid Amount
              Text(
                'Paid Amount (AUD/NPR)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.deepPurple[800],
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
                    borderSide: BorderSide(color: Colors.deepPurple.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.deepPurple.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.deepPurple.shade400),
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
              const SizedBox(height: 24),
              
              // Payment Slip
              Text(
                'Payment Slip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.deepPurple[800],
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
                            border: Border.all(color: Colors.deepPurple.shade200),
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
                          border: Border.all(color: Colors.deepPurple.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 48,
                              color: Colors.deepPurple[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Upload Payment Slip',
                              style: GoogleFonts.poppins(
                                color: Colors.deepPurple[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Take a photo or choose from gallery',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
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
                    backgroundColor: Colors.deepPurple[600],
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

// class MembershipForm extends StatefulWidget {
//   final Function onSubmit;

//   const MembershipForm({Key? key, required this.onSubmit}) : super(key: key);

//   @override
//   State<MembershipForm> createState() => _MembershipFormState();
// }

// class _MembershipFormState extends State<MembershipForm> {
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedMembershipType;
//   final TextEditingController _paidAmountController = TextEditingController();
//   File? _paymentSlip;
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _membershipTypes = [];
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _fetchMembershipTypes();
//   }

//   Future<void> _fetchMembershipTypes() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       // Fetch from API
//       final types = await MembershipCardService.getMembershipTypes();
      
//       setState(() {
//         _membershipTypes = types;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading membership types: $e')),
//       );
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

//   void _updatePaidAmount(String type) {
//     final selectedType = _membershipTypes.firstWhere(
//       (element) => element['name'] == type,
//       orElse: () => {'amount': 0},
//     );
    
//     _paidAmountController.text = selectedType['amount'].toString();
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
//         // Prepare form data
//         Map<String, dynamic> formData = {
//           'membershipType': _selectedMembershipType,
//           'paidAmount': _paidAmountController.text,
//           'paymentSlip': _paymentSlip,
//         };
        
//         // Submit to parent handler
//         widget.onSubmit(formData);
//       } catch (e) {
//         // Show error
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e')),
//         );
        
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
//                 child: DropdownButtonFormField<String>(
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
//                   value: _selectedMembershipType,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select a membership type';
//                     }
//                     return null;
//                   },
//                   items: _membershipTypes.map((type) {
//                     return DropdownMenuItem<String>(
//                       value: type['name'],
//                       child: Text(
//                         '${type['name']} - Rs. ${type['amount']}',
//                         style: GoogleFonts.poppins(),
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedMembershipType = value;
//                       _updatePaidAmount(value!);
//                     });
//                   },
//                   icon: Icon(
//                     Icons.arrow_drop_down,
//                     color: Colors.deepPurple[800],
//                   ),
//                   dropdownColor: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 24),
              
//               // Paid Amount
//               Text(
//                 'Paid Amount (Rs.)',
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







// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// // import 'package:image_picker/image_picker.dart';

// class MembershipForm extends StatefulWidget {
//   final Function onSubmit;

//   const MembershipForm({Key? key, required this.onSubmit}) : super(key: key);

//   @override
//   State<MembershipForm> createState() => _MembershipFormState();
// }

// class _MembershipFormState extends State<MembershipForm> {
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedMembershipType;
//   final TextEditingController _paidAmountController = TextEditingController();
//   File? _paymentSlip;
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _membershipTypes = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchMembershipTypes();
//   }

//   Future<void> _fetchMembershipTypes() async {
//     // In a real implementation, you'd fetch from the API:
//     // https://extratech.extratechweb.com/api/student/membership-types
//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate API call for now
//     await Future.delayed(const Duration(seconds: 1));
    
//     // Sample data (replace with actual API call)
//     setState(() {
//       _membershipTypes = [
//         {"id": 1, "name": "Standard", "amount": 1000},
//         {"id": 2, "name": "Premium", "amount": 2000},
//         {"id": 3, "name": "VIP", "amount": 5000},
//       ];
//       _isLoading = false;
//     });
//   }

//   Future<void> _pickPaymentSlip() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.image,
//         allowCompression: true,
//       );

//       if (result != null) {
//         setState(() {
//           _paymentSlip = File(result.files.single.path!);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking file: $e')),
//       );
//     }
//   }

//   void _updatePaidAmount(String type) {
//     final selectedType = _membershipTypes.firstWhere(
//       (element) => element['name'] == type,
//       orElse: () => {'amount': 0},
//     );
    
//     _paidAmountController.text = selectedType['amount'].toString();
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
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Apply for Membership Card',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
              
//               // Membership Type
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Membership Type',
//                   border: OutlineInputBorder(),
//                 ),
//                 value: _selectedMembershipType,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select a membership type';
//                   }
//                   return null;
//                 },
//                 items: _membershipTypes.map((type) {
//                   return DropdownMenuItem<String>(
//                     value: type['name'],
//                     child: Text('${type['name']} - Rs. ${type['amount']}'),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedMembershipType = value;
//                     _updatePaidAmount(value!);
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
              
//               // Paid Amount
//               TextFormField(
//                 controller: _paidAmountController,
//                 decoration: const InputDecoration(
//                   labelText: 'Paid Amount (Rs.)',
//                   border: OutlineInputBorder(),
//                 ),
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
//               const SizedBox(height: 16),
              
//               // Payment Slip
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Payment Slip',
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _paymentSlip != null
//                       ? Stack(
//                           alignment: Alignment.topRight,
//                           children: [
//                             Container(
//                               height: 200,
//                               width: double.infinity,
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Image.file(
//                                 _paymentSlip!,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {
//                                 setState(() {
//                                   _paymentSlip = null;
//                                 });
//                               },
//                             ),
//                           ],
//                         )
//                       : InkWell(
//                           onTap: _pickPaymentSlip,
//                           child: Container(
//                             height: 100,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(Icons.cloud_upload, size: 40),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Upload Payment Slip',
//                                   style: GoogleFonts.poppins(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//               const SizedBox(height: 24),
              
//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       if (_paymentSlip == null) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Please upload payment slip'),
//                           ),
//                         );
//                         return;
//                       }
                      
//                       widget.onSubmit({
//                         'membershipType': _selectedMembershipType,
//                         'paidAmount': _paidAmountController.text,
//                         'paymentSlip': _paymentSlip,
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Theme.of(context).primaryColor,
//                   ),
//                   child: Text(
//                     'Submit Application',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }