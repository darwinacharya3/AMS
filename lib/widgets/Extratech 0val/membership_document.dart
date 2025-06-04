import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ems/Providers/Extratech_oval/membership_oval_providers.dart';
import 'package:image_picker/image_picker.dart';

class MembershipDocuments extends ConsumerStatefulWidget {
  final VoidCallback onPrevious;

  const MembershipDocuments({
    Key? key,
    required this.onPrevious,
  }) : super(key: key);

  @override
  ConsumerState<MembershipDocuments> createState() => _MembershipDocumentsState();
}

class _MembershipDocumentsState extends ConsumerState<MembershipDocuments> {
  final ImagePicker _picker = ImagePicker();
  bool isSubmitting = false;
  String errorMessage = '';
  bool showSuccessMessage = false;

  @override
  Widget build(BuildContext context) {
    // File providers
    final photo = ref.watch(photoProvider);
    final paymentSlip = ref.watch(generalPaymentSlipProvider);
    final citizenshipFront = ref.watch(citizenshipFrontProvider);
    final citizenshipBack = ref.watch(citizenshipBackProvider);
    final comments = ref.watch(commentsProvider);
    
    // Loading state
    final isLoading = ref.watch(generalFormSubmissionLoadingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSuccessMessage) _buildSuccessMessage(),
        if (errorMessage.isNotEmpty) _buildErrorMessage(),
        
        // Payment Information
        _buildSectionTitle('Payment Information'),
        
        // Payment Slip Upload
        _buildFileUpload(
          title: 'Payment Slip',
          file: paymentSlip,
          onPickImage: (source) => _pickImage(source, 'payment_slip'),
          onDelete: paymentSlip != null ? () => _deleteFile('payment_slip') : null,
        ),
        const SizedBox(height: 16),

        // Documents
        _buildSectionTitle('Required Documents'),
        
        // Photo Upload
        _buildFileUpload(
          title: 'Your Photo',
          file: photo,
          onPickImage: (source) => _pickImage(source, 'photo'),
          onDelete: photo != null ? () => _deleteFile('photo') : null,
        ),
        const SizedBox(height: 12),
        
        // Citizenship Front Upload
        _buildFileUpload(
          title: 'Citizenship Front',
          file: citizenshipFront,
          onPickImage: (source) => _pickImage(source, 'citizenship_front'),
          onDelete: citizenshipFront != null ? () => _deleteFile('citizenship_front') : null,
        ),
        const SizedBox(height: 12),
        
        // Citizenship Back Upload
        _buildFileUpload(
          title: 'Citizenship Back',
          file: citizenshipBack,
          onPickImage: (source) => _pickImage(source, 'citizenship_back'),
          onDelete: citizenshipBack != null ? () => _deleteFile('citizenship_back') : null,
        ),
        const SizedBox(height: 16),

        // Comments
        _buildSectionTitle('Additional Comments (Optional)'),
        _buildTextFormField(
          labelText: 'Comments',
          maxLines: 3,
          value: comments,
          onChanged: (value) => ref.read(commentsProvider.notifier).state = value,
        ),
        const SizedBox(height: 24),

        // Navigation Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onPrevious,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isSubmitting || isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF205EB5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: const Color(0xFF205EB5).withOpacity(0.5),
                ),
                child: isSubmitting || isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Submit',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle_outline, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Upload image from gallery or camera
  Future<void> _pickImage(ImageSource source, String fileType) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source, 
        imageQuality: 70,
        maxWidth: 800,
      );
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        
        setState(() {
          // Clear any error messages when a new file is selected
          errorMessage = '';
          
          // Update appropriate provider based on file type
          switch (fileType) {
            case 'photo':
              ref.read(photoProvider.notifier).state = file;
              break;
            case 'payment_slip':
              ref.read(generalPaymentSlipProvider.notifier).state = file;
              break;
            case 'citizenship_front':
              ref.read(citizenshipFrontProvider.notifier).state = file;
              break;
            case 'citizenship_back':
              ref.read(citizenshipBackProvider.notifier).state = file;
              break;
          }
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error picking image: ${e.toString()}';
      });
    }
  }

  // Show image source selection modal
  void _showImageSourceOptions(Function(ImageSource) onPickImage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF205EB5),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF205EB5).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF205EB5),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Gallery',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Choose from your photos',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF205EB5).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF205EB5),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Camera',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Take a new photo',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onPickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Delete uploaded file
  void _deleteFile(String fileType) {
    setState(() {
      switch (fileType) {
        case 'photo':
          ref.read(photoProvider.notifier).state = null;
          break;
        case 'payment_slip':
          ref.read(generalPaymentSlipProvider.notifier).state = null;
          break;
        case 'citizenship_front':
          ref.read(citizenshipFrontProvider.notifier).state = null;
          break;
        case 'citizenship_back':
          ref.read(citizenshipBackProvider.notifier).state = null;
          break;
      }
    });
  }

  // Build file upload container with SMALLER UPLOAD BUTTON
  Widget _buildFileUpload({
    required String title,
    required File? file,
    required Function(ImageSource) onPickImage,
    required VoidCallback? onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // File name or "No file selected"
              Expanded(
                child: file == null
                  ? Text(
                      'No file selected',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.path.split('/').last,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (onDelete != null)
                          GestureDetector(
                            onTap: onDelete,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[400],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Remove',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.red[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
              ),
              
              // Smaller Upload Icon Button
              IconButton(
                onPressed: () => _showImageSourceOptions(onPickImage),
                icon: const Icon(
                  Icons.upload_file_rounded,
                  size: 20,
                  color: Color(0xFF205EB5),
                ),
                tooltip: 'Upload file',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                splashRadius: 24,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    const Color(0xFF205EB5).withOpacity(0.1),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Form submission with improved data handling
  Future<void> _submitForm() async {
    // Check required file uploads
    if (ref.read(photoProvider) == null) {
      setState(() {
        errorMessage = 'Please upload your photo';
      });
      return;
    }
    
    if (ref.read(generalPaymentSlipProvider) == null) {
      setState(() {
        errorMessage = 'Please upload payment slip';
      });
      return;
    }
    
    if (ref.read(citizenshipFrontProvider) == null) {
      setState(() {
        errorMessage = 'Please upload citizenship front';
      });
      return;
    }
    
    if (ref.read(citizenshipBackProvider) == null) {
      setState(() {
        errorMessage = 'Please upload citizenship back';
      });
      return;
    }
    
    // Clear any previous error
    setState(() {
      errorMessage = '';
      isSubmitting = true;
    });
    
    // Pre-submission validation to ensure all required fields have values
    final firstName = ref.read(firstNameProvider);
    final email = ref.read(emailProvider);
    final amount = ref.read(generalPaidAmountProvider);
    final dob = ref.read(dobProvider);
    final phone = ref.read(phoneProvider);
    final address = ref.read(addressProvider);
    final countryId = ref.read(selectedCountryIdProvider);
    final cardTypeId = ref.read(selectedGeneralMembershipTypeProvider);
    
    // Check all required fields
    final List<String> missingFields = [];
    
    if (firstName.isEmpty) missingFields.add('First name');
    if (email.isEmpty) missingFields.add('Email');
    if (amount.isEmpty) missingFields.add('Paid amount');
    if (dob.isEmpty) missingFields.add('Date of birth');
    if (phone.isEmpty) missingFields.add('Phone');
    if (address.isEmpty) missingFields.add('Address');
    if (countryId == null) missingFields.add('Country');
    if (cardTypeId == null) missingFields.add('Membership type');
    
    if (missingFields.isNotEmpty) {
      setState(() {
        errorMessage = 'The following fields are required: ${missingFields.join(', ')}. Please go back and complete the form.';
        isSubmitting = false;
      });
      return;
    }
    
    // Create form data
    final formData = {
      'card_type_id': cardTypeId,
      'first_name': firstName,
      'middle_name': ref.read(middleNameProvider),
      'last_name': ref.read(lastNameProvider),
      'dob': dob,
      'email': email,
      'phone': phone,
      'country_id': countryId,
      'state_id': ref.read(selectedStateIdProvider),
      'address': address,
      'amount': amount,
      'comment': ref.read(commentsProvider),
      'photo': ref.read(photoProvider),
      'payment_slip': ref.read(generalPaymentSlipProvider),
      'citizenship_front': ref.read(citizenshipFrontProvider),
      'citizenship_back': ref.read(citizenshipBackProvider),
    };
    
    // Debug log the data being submitted
    debugPrint('Form data being submitted:');
    // formData.forEach((key, value) {
    //   if (value is! File) {
    //     debugPrint('$key: $value');
    //   } else {
    //     debugPrint('$key: ${(value as File).path}');
    //   }
    // });
    
    try {
      final submitForm = ref.read(submitGeneralMembershipFormProvider);
      final result = await submitForm(formData);
      
      if (result) {
        // Reset ALL form data after successful submission
        _resetAllFormData();
        
        setState(() {
          showSuccessMessage = true;
          isSubmitting = false;
        });
        
        // Scroll to the top to show success message
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              alignment: 0.0,
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error submitting application: ${e.toString()}';
        isSubmitting = false;
      });
      
      // Scroll to show error message
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            alignment: 0.0,
          );
        }
      });
    }
  }
  
  // Reset ALL form data completely - both documents and personal details
  void _resetAllFormData() {
    // Reset personal details
    ref.read(firstNameProvider.notifier).state = '';
    ref.read(middleNameProvider.notifier).state = '';
    ref.read(lastNameProvider.notifier).state = '';
    ref.read(dobProvider.notifier).state = '';
    ref.read(emailProvider.notifier).state = '';
    ref.read(phoneProvider.notifier).state = '';
    ref.read(addressProvider.notifier).state = '';
    ref.read(selectedCountryIdProvider.notifier).state = null;
    ref.read(selectedStateIdProvider.notifier).state = null;
    ref.read(selectedGeneralMembershipTypeProvider.notifier).state = null;
    ref.read(generalPaidAmountProvider.notifier).state = '';
    
    // Reset documents and comments
    ref.read(photoProvider.notifier).state = null;
    ref.read(generalPaymentSlipProvider.notifier).state = null;
    ref.read(citizenshipFrontProvider.notifier).state = null;
    ref.read(citizenshipBackProvider.notifier).state = null;
    ref.read(commentsProvider.notifier).state = '';
    
    debugPrint('All form data has been completely reset');
  }

  // Success message
  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Success',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your membership application has been submitted successfully. We will process your application and get back to you shortly.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                showSuccessMessage = false;
              });
              // Use the onPrevious callback to navigate back to the personal details step
              widget.onPrevious();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green[700],
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Submit another application',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Error message
  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
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
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      maxLines: maxLines,
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
    );
  }
}