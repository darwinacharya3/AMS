import 'package:flutter/material.dart';
import 'package:ems/widgets/Extratech 0val/membership/personal_info_screen.dart';
import 'package:ems/widgets/Extratech 0val/membership/location_contact_section.dart';
import 'package:ems/widgets/Extratech 0val/membership/membership_details_section.dart';
import 'package:ems/widgets/Extratech 0val/membership/documents_section.dart';
import 'package:ems/widgets/Extratech 0val/membership/remarks_and_captcha_section.dart';


class MembershipFormWidget extends StatefulWidget {
  const MembershipFormWidget({Key? key}) : super(key: key);

  @override
  State<MembershipFormWidget> createState() => _MembershipFormWidgetState();
}

class _MembershipFormWidgetState extends State<MembershipFormWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form data
  final _formData = <String, dynamic>{};
  
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Find the first error and scroll to it
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Call API to submit form data
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membership application submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting form: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Extratech Oval Membership Application',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF205EB5),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              
              // Form Sections - Each is responsive to screen size
              PersonalInfoSection(formData: _formData),
              SizedBox(height: isSmallScreen ? 16 : 24),
              
              LocationContactSection(formData: _formData),
              SizedBox(height: isSmallScreen ? 16 : 24),
              
              MembershipDetailsSection(formData: _formData),
              SizedBox(height: isSmallScreen ? 16 : 24),
              
              DocumentsSection(formData: _formData),
              SizedBox(height: isSmallScreen ? 16 : 24),
              
              RemarksCaptchaSection(formData: _formData),
              SizedBox(height: isSmallScreen ? 16 : 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF205EB5),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Submit Application',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
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