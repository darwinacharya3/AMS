import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/edit_user_details.dart';
import 'package:ems/utils/responsive_utils.dart';

class SignatureSection extends StatefulWidget {
  final EditUserDetail edituserDetail;
  final Function(String signature) onSave;

  const SignatureSection({
    Key? key,
    required this.edituserDetail,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SignatureSection> createState() => _SignatureSectionState();
}

class _SignatureSectionState extends State<SignatureSection> {
  late TextEditingController _signatureController;
  late bool _isSignatureEditable;

  @override
  void initState() {
    super.initState();
    _signatureController = TextEditingController(text: widget.edituserDetail.signature);
    _isSignatureEditable = widget.edituserDetail.editableFields['signature'] ?? false;
    
    // Add listener to save data when signature changes
    if (_isSignatureEditable) {
      _signatureController.addListener(_saveData);
    }
  }
  
  void _saveData() {
    widget.onSave(_signatureController.text);
  }

  @override
  void dispose() {
    if (_isSignatureEditable) {
      _signatureController.removeListener(_saveData);
    }
    _signatureController.dispose();
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
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildSectionSubtitle("Student's full name as a signature"),
            SizedBox(height: isDesktop ? 24 : 16),
            
            // For desktop/tablet, we can add some additional padding or max width constraints
            if (isDesktop || isTablet)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 32),
                child: _buildTextField(
                  label: 'Signature',
                  controller: _signatureController,
                  validator: (value) => value!.isEmpty ? 'Signature is required' : null,
                ),
              )
            else
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

  Widget _buildHeader() {
    return ResponsiveUtils.isDesktop(context)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Signature and Acceptance',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // For desktop, we can add a date or additional information
              Text(
                'Date: ${widget.edituserDetail.commencementDate}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          )
        : Text(
            'Signature and Acceptance',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.isDesktop(context) ? 12 : 8,
      ),
      child: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: ResponsiveUtils.isDesktop(context) ? 16 : 14,
          color: const Color.fromARGB(255, 227, 10, 169),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        TextFormField(
          controller: controller,
          readOnly: !_isSignatureEditable,
          enabled: _isSignatureEditable,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12, 
              vertical: isMobile ? 16 : 20,
            ),
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
            fillColor: _isSignatureEditable ? Colors.white : Colors.grey[100], // Grey background for non-editable fields
          ),
          validator: validator,
        ),
      ],
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/edit_user_details.dart';
// import 'package:ems/utils/responsive_utils.dart';

// class SignatureSection extends StatefulWidget {
//   final EditUserDetail edituserDetail;
//   final Function(String signature) onSave;

//   const SignatureSection({
//     Key? key,
//     required this.edituserDetail,
//     required this.onSave,
//   }) : super(key: key);

//   @override
//   State<SignatureSection> createState() => _SignatureSectionState();
// }

// class _SignatureSectionState extends State<SignatureSection> {
//   late TextEditingController _signatureController;

//   @override
//   void initState() {
//     super.initState();
//     _signatureController = TextEditingController(text: widget.edituserDetail.signature);
//   }

//   @override
//   void dispose() {
//     _signatureController.dispose();
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
//         padding: EdgeInsets.all(isDesktop ? 24 : 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildHeader(),
//             _buildSectionSubtitle("Student's full name as a signature"),
//             SizedBox(height: isDesktop ? 24 : 16),
            
//             // For desktop/tablet, we can add some additional padding or max width constraints
//             if (isDesktop || isTablet)
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 32),
//                 child: _buildTextField(
//                   label: 'Signature',
//                   controller: _signatureController,
//                   validator: (value) => value!.isEmpty ? 'Signature is required' : null,
//                 ),
//               )
//             else
//               _buildTextField(
//                 label: 'Signature',
//                 controller: _signatureController,
//                 validator: (value) => value!.isEmpty ? 'Signature is required' : null,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return ResponsiveUtils.isDesktop(context)
//         ? Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Signature and Acceptance',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               // For desktop, we can add a date or additional information
//               Text(
//                 'Date: ${widget.edituserDetail.commencementDate}',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ],
//           )
//         : Text(
//             'Signature and Acceptance',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           );
//   }

//   Widget _buildSectionSubtitle(String subtitle) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         vertical: ResponsiveUtils.isDesktop(context) ? 12 : 8,
//       ),
//       child: Text(
//         subtitle,
//         style: GoogleFonts.poppins(
//           fontSize: ResponsiveUtils.isDesktop(context) ? 16 : 14,
//           color: const Color.fromARGB(255, 227, 10, 169),
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label, 
//     required TextEditingController controller,
//     String? Function(String?)? validator,
//   }) {
//     final isMobile = ResponsiveUtils.isMobile(context);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: isMobile ? 16 : 18,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         SizedBox(height: isMobile ? 8 : 12),
//         TextFormField(
//           controller: controller,
//           onChanged: (value) {
//             widget.onSave(value);
//           },
//           style: TextStyle(
//             fontSize: isMobile ? 16 : 18,
//           ),
//           decoration: InputDecoration(
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 12, 
//               vertical: isMobile ? 16 : 20,
//             ),
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
// }