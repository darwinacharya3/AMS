import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/edit_user_details.dart';
import 'package:ems/utils/responsive_utils.dart';

class EmergencyContactSection extends StatefulWidget {
  final EditUserDetail edituserDetail;
  final Function(
    String eContactName,
    String relation,
    String eContactNo,
  ) onSave;

  const EmergencyContactSection({
    Key? key,
    required this.edituserDetail,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EmergencyContactSection> createState() => _EmergencyContactSectionState();
}

class _EmergencyContactSectionState extends State<EmergencyContactSection> {
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyRelationController;
  late TextEditingController _emergencyContactController;

  @override
  void initState() {
    super.initState();
    _emergencyNameController = TextEditingController(text: widget.edituserDetail.eContactName);
    _emergencyRelationController = TextEditingController(text: widget.edituserDetail.relation);
    _emergencyContactController = TextEditingController(text: widget.edituserDetail.eContactNo);
    
    // Add listeners to save data when text changes
    _emergencyNameController.addListener(_saveData);
    _emergencyRelationController.addListener(_saveData);
    _emergencyContactController.addListener(_saveData);
  }

  void _saveData() {
    widget.onSave(
      _emergencyNameController.text,
      _emergencyRelationController.text,
      _emergencyContactController.text,
    );
  }

  @override
  void dispose() {
    // Remove listeners before disposing controllers
    _emergencyNameController.removeListener(_saveData);
    _emergencyRelationController.removeListener(_saveData);
    _emergencyContactController.removeListener(_saveData);
    
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyContactController.dispose();
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
            Text(
              'Emergency Contact',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildSectionSubtitle('Emergency contact of student'),
            const SizedBox(height: 16),
            
            // For desktop and tablet, show in a row
            if (isDesktop || isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: _buildTextField(
                      label: 'Full Name',
                      controller: _emergencyNameController,
                      validator: (value) => value!.isEmpty ? 'Emergency contact name is required' : null,
                      isEditable: widget.edituserDetail.editableFields['eContactName'] ?? true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Middle column
                  Expanded(
                    child: _buildTextField(
                      label: 'Relation to Student',
                      controller: _emergencyRelationController,
                      validator: (value) => value!.isEmpty ? 'Relation is required' : null,
                      isEditable: widget.edituserDetail.editableFields['relation'] ?? true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right column
                  Expanded(
                    child: _buildTextField(
                      label: 'Contact No',
                      controller: _emergencyContactController,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Emergency contact number is required' : null,
                      isEditable: widget.edituserDetail.editableFields['eContactNo'] ?? true,
                    ),
                  ),
                ],
              )
            else
              // For mobile, show in a column
              Column(
                children: [
                  _buildTextField(
                    label: 'Full Name',
                    controller: _emergencyNameController,
                    validator: (value) => value!.isEmpty ? 'Emergency contact name is required' : null,
                    isEditable: widget.edituserDetail.editableFields['eContactName'] ?? true,
                  ),
                  
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Relation to Student',
                    controller: _emergencyRelationController,
                    validator: (value) => value!.isEmpty ? 'Relation is required' : null,
                    isEditable: widget.edituserDetail.editableFields['relation'] ?? true,
                  ),
                  
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Contact No',
                    controller: _emergencyContactController,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Emergency contact number is required' : null,
                    isEditable: widget.edituserDetail.editableFields['eContactNo'] ?? true,
                  ),
                ],
              ),
          ],
        ),
      ),
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
}
















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/edit_user_details.dart';
// import 'package:ems/utils/responsive_utils.dart';

// class EmergencyContactSection extends StatefulWidget {
//   final EditUserDetail edituserDetail;
//   final Function(
//     String eContactName,
//     String relation,
//     String eContactNo,
//   ) onSave;

//   const EmergencyContactSection({
//     Key? key,
//     required this.edituserDetail,
//     required this.onSave,
//   }) : super(key: key);

//   @override
//   State<EmergencyContactSection> createState() => _EmergencyContactSectionState();
// }

// class _EmergencyContactSectionState extends State<EmergencyContactSection> {
//   late TextEditingController _emergencyNameController;
//   late TextEditingController _emergencyRelationController;
//   late TextEditingController _emergencyContactController;

//   @override
//   void initState() {
//     super.initState();
//     _emergencyNameController = TextEditingController(text: widget.edituserDetail.eContactName);
//     _emergencyRelationController = TextEditingController(text: widget.edituserDetail.relation);
//     _emergencyContactController = TextEditingController(text: widget.edituserDetail.eContactNo);
    
//     // Add listeners to save data when text changes
//     _emergencyNameController.addListener(_saveData);
//     _emergencyRelationController.addListener(_saveData);
//     _emergencyContactController.addListener(_saveData);
//   }

//   void _saveData() {
//     widget.onSave(
//       _emergencyNameController.text,
//       _emergencyRelationController.text,
//       _emergencyContactController.text,
//     );
//   }

//   @override
//   void dispose() {
//     // Remove listeners before disposing controllers
//     _emergencyNameController.removeListener(_saveData);
//     _emergencyRelationController.removeListener(_saveData);
//     _emergencyContactController.removeListener(_saveData);
    
//     _emergencyNameController.dispose();
//     _emergencyRelationController.dispose();
//     _emergencyContactController.dispose();
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
//             Text(
//               'Emergency Contact',
//               style: GoogleFonts.poppins(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             _buildSectionSubtitle('Emergency contact of student'),
//             const SizedBox(height: 16),
            
//             // For desktop and tablet, show in a row
//             if (isDesktop || isTablet)
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Left column
//                   Expanded(
//                     child: _buildTextField(
//                       label: 'Full Name',
//                       controller: _emergencyNameController,
//                       validator: (value) => value!.isEmpty ? 'Emergency contact name is required' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   // Middle column
//                   Expanded(
//                     child: _buildTextField(
//                       label: 'Relation to Student',
//                       controller: _emergencyRelationController,
//                       validator: (value) => value!.isEmpty ? 'Relation is required' : null,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   // Right column
//                   Expanded(
//                     child: _buildTextField(
//                       label: 'Contact No',
//                       controller: _emergencyContactController,
//                       keyboardType: TextInputType.phone,
//                       validator: (value) => value!.isEmpty ? 'Emergency contact number is required' : null,
//                     ),
//                   ),
//                 ],
//               )
//             else
//               // For mobile, show in a column
//               Column(
//                 children: [
//                   _buildTextField(
//                     label: 'Full Name',
//                     controller: _emergencyNameController,
//                     validator: (value) => value!.isEmpty ? 'Emergency contact name is required' : null,
//                   ),
                  
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     label: 'Relation to Student',
//                     controller: _emergencyRelationController,
//                     validator: (value) => value!.isEmpty ? 'Relation is required' : null,
//                   ),
                  
//                   const SizedBox(height: 16),
//                   _buildTextField(
//                     label: 'Contact No',
//                     controller: _emergencyContactController,
//                     keyboardType: TextInputType.phone,
//                     validator: (value) => value!.isEmpty ? 'Emergency contact number is required' : null,
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
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
//           // Using controller listeners instead of onChanged
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
// }