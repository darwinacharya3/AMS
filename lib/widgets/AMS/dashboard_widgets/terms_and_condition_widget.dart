import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/user_detail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:ems/services/secure_storage_service.dart';

class TermsAndConditionWidget extends StatefulWidget {
  final UserDetail? userDetail;
  
  const TermsAndConditionWidget({
    super.key,
    required this.userDetail,
  });

  @override
  State<TermsAndConditionWidget> createState() => _TermsAndConditionWidgetState();
}

class _TermsAndConditionWidgetState extends State<TermsAndConditionWidget> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _sections = [];
  
  // Track expanded state for each section separately
  Map<int, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _fetchTermsAndCondition();
  }

  Future<void> _fetchTermsAndCondition() async {
    if (widget.userDetail == null) {
      debugPrint('TermsWidget: userDetail is null');
      setState(() {
        _isLoading = false;
        _error = 'No user information available';
      });
      return;
    }

    debugPrint('TermsWidget: term_and_condition value: ${widget.userDetail!.termAndCondition}');
    
    if (widget.userDetail!.termAndCondition.isEmpty) {
      debugPrint('TermsWidget: term_and_condition is empty');
      setState(() {
        _isLoading = false;
        _error = 'No terms and condition information available';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get credentials from secure storage
      final email = await SecureStorageService.getUserEmail();
      final password = await SecureStorageService.getUserPassword();
      
      debugPrint('TermsWidget: Retrieved credentials - Email: $email');
      
      if (email == null || password == null) {
        throw Exception('Stored credentials not found');
      }
      
      // Use the same login endpoint to get terms and conditions
      final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';
      debugPrint('TermsWidget: Making API request to: $loginUrl');

      final requestBody = {
        'email': email,
        'password': password,
        'get_terms': widget.userDetail!.termAndCondition
      };
      
      final loginResponse = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      debugPrint('TermsWidget: API Response Status Code: ${loginResponse.statusCode}');
      
      if (loginResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(loginResponse.body);
        debugPrint('TermsWidget: Response keys: ${data.keys.toList()}');
        
        // Reset sections
        _sections = [];
        
        // Section 1: Terms & Conditions
        if (data.containsKey('termsAndConditionFirstPage')) {
          _sections.add({
            'title': 'Terms & Condition',
            'content': _processContent(data['termsAndConditionFirstPage'])
          });
          _expandedSections[0] = false; // Initialize to collapsed
        }
        
        // Section 2: Privacy Statement and Declaration (combined)
        String privacyContent = '';
        
        // Combine second and third page content
        if (data.containsKey('termsAndConditionSecondPage')) {
          privacyContent += data['termsAndConditionSecondPage'];
        }
        
        if (data.containsKey('termsAndConditionThirdPage')) {
          if (privacyContent.isNotEmpty) {
            privacyContent += '<br><br>';
          }
          privacyContent += data['termsAndConditionThirdPage'];
        }
        
        if (privacyContent.isNotEmpty) {
          _sections.add({
            'title': 'Privacy Statement and Declaration',
            'content': _processContent(privacyContent)
          });
          _expandedSections[1] = false; // Initialize to collapsed
        }
        
        if (_sections.isNotEmpty) {
          debugPrint('TermsWidget: Created ${_sections.length} sections');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          debugPrint('TermsWidget: No terms content found in response');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = 'Terms and conditions not found in response';
            });
          }
        }
      } else {
        throw Exception('Failed to load terms and conditions: ${loginResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('TermsWidget: Error fetching terms: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading terms: $e';
        });
      }
    }
  }

  String _processContent(String htmlContent) {
    // Remove the existing <li> tags and create a custom formatted list
    String plainContent = htmlContent.replaceAll('<li>', '').replaceAll('</li>', '<br>');
    
    // Split the content by <br> tags to get individual items
    List<String> items = plainContent.split('<br>');
    
    // Rebuild the HTML with proper formatting
    StringBuffer processedContent = StringBuffer();
    
    // Add a wrapper div with justified alignment
    processedContent.write('<div style="text-align: justify;">');
    
    int listItemCount = 0;
    
    for (int i = 0; i < items.length; i++) {
      String item = items[i].trim();
      if (item.isEmpty) continue;
      
      // Check if this is a declaration paragraph starting with a number (like "5. I declare...")
      if (RegExp(r'^\s*\d+\.\s+I\s+declare').hasMatch(item)) {
        // This is a declaration paragraph, not a numbered list item
        processedContent.write(
          '<p style="margin-bottom: 12px; text-align: justify;">${item}</p>'
        );
      } 
      // Check if it's any other paragraph starting with a number pattern
      else if (RegExp(r'^\s*\d+\.\s+').hasMatch(item)) {
        // This might be a declaration paragraph that doesn't start with "I declare"
        // Just preserve it as is without adding to the numbering
        processedContent.write(
          '<p style="margin-bottom: 12px; text-align: justify;">${item}</p>'
        );
      } 
      else {
        // Regular list item - apply auto-numbering
        listItemCount++;
        // Clean any existing numbering patterns
        String cleanItem = item.replaceAll(RegExp(r'^\s*0\.\s*\d+\.\s*'), '');
        
        // Create a paragraph with proper indentation and margin for better readability
        processedContent.write(
          '<p style="margin-bottom: 12px; text-indent: 0; padding-left: 20px; position: relative;">'
          '<span style="position: absolute; left: 0;">$listItemCount.</span> $cleanItem'
          '</p>'
        );
      }
    }
    
    processedContent.write('</div>');
    
    return processedContent.toString();
  }

  void _toggleSectionExpanded(int sectionIndex) {
    setState(() {
      _expandedSections[sectionIndex] = !(_expandedSections[sectionIndex] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA1A1A1).withOpacity(0.25),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSignatureSection(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF205EB5),
                ),
              ),
            )
          else if (_error != null)
            _buildErrorMessage()
          else
            ..._sections.asMap().entries.map((entry) => 
              _buildTermsSection(entry.key, entry.value['title'], entry.value['content'])
            ).toList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Signature and Acceptance',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF111213)
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Student\'s full name as a signature',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF205EB5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildInfoRow(
          Icons.edit_outlined,
          'Signature',
          widget.userDetail?.signature ?? 'Not provided',
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _error!,
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _fetchTermsAndCondition();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF205EB5),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(int index, String title, String content) {
    bool isExpanded = _expandedSections[index] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 150,
            constraints: isExpanded ? null : const BoxConstraints(maxHeight: 150),
            child: ClipRect(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Html(
                  data: content,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      fontFamily: 'Poppins',
                      color: const Color(0xFFA1A1A1),
                      textAlign: TextAlign.justify,
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 12),
                      textAlign: TextAlign.justify,
                    ),
                    "div": Style(
                      textAlign: TextAlign.justify,
                    ),
                    "span": Style(
                      fontWeight: FontWeight.w500,
                    ),
                    "a": Style(
                      color: const Color(0xFF205EB5),
                      textDecoration: TextDecoration.none,
                    ),
                  },
                  // Corrected: Using "onAnchorTap" instead of "onLinkTap"
                  onAnchorTap: (url, _, __) {
                    if (url != null) {
                      // Handle link tapping if needed
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: ElevatedButton(
                onPressed: () => _toggleSectionExpanded(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF205EB5),
                  foregroundColor: const Color(0XFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isExpanded ? 'Show Less' : 'Show More',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (index < _sections.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: Colors.grey[300],
                thickness: 1.0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF205EB5),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFFA1A1A1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:ems/services/secure_storage_service.dart';

// class TermsAndConditionWidget extends StatefulWidget {
//   final UserDetail? userDetail;
  
//   const TermsAndConditionWidget({
//     super.key,
//     required this.userDetail,
//   });

//   @override
//   State<TermsAndConditionWidget> createState() => _TermsAndConditionWidgetState();
// }

// class _TermsAndConditionWidgetState extends State<TermsAndConditionWidget> {
//   bool _isLoading = true;
//   String? _error;
//   List<Map<String, dynamic>> _sections = [];
  
//   // Track expanded state for each section separately
//   Map<int, bool> _expandedSections = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchTermsAndCondition();
//   }

//   Future<void> _fetchTermsAndCondition() async {
//     if (widget.userDetail == null) {
//       debugPrint('TermsWidget: userDetail is null');
//       setState(() {
//         _isLoading = false;
//         _error = 'No user information available';
//       });
//       return;
//     }

//     debugPrint('TermsWidget: term_and_condition value: ${widget.userDetail!.termAndCondition}');
    
//     if (widget.userDetail!.termAndCondition.isEmpty) {
//       debugPrint('TermsWidget: term_and_condition is empty');
//       setState(() {
//         _isLoading = false;
//         _error = 'No terms and condition information available';
//       });
//       return;
//     }

//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       // Get credentials from secure storage
//       final email = await SecureStorageService.getUserEmail();
//       final password = await SecureStorageService.getUserPassword();
      
//       debugPrint('TermsWidget: Retrieved credentials - Email: $email');
      
//       if (email == null || password == null) {
//         throw Exception('Stored credentials not found');
//       }
      
//       // Use the same login endpoint to get terms and conditions
//       final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';
//       debugPrint('TermsWidget: Making API request to: $loginUrl');

//       final requestBody = {
//         'email': email,
//         'password': password,
//         'get_terms': widget.userDetail!.termAndCondition
//       };
      
//       final loginResponse = await http.post(
//         Uri.parse(loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(requestBody),
//       );

//       debugPrint('TermsWidget: API Response Status Code: ${loginResponse.statusCode}');
      
//       if (loginResponse.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(loginResponse.body);
//         debugPrint('TermsWidget: Response keys: ${data.keys.toList()}');
        
//         // Reset sections
//         _sections = [];
        
//         // Section 1: Terms & Conditions
//         if (data.containsKey('termsAndConditionFirstPage')) {
//           _sections.add({
//             'title': 'Terms & Condition',
//             'content': _fixNumbering(data['termsAndConditionFirstPage'])
//           });
//           _expandedSections[0] = false; // Initialize to collapsed
//         }
        
//         // Section 2: Privacy Statement and Declaration (combined)
//         String privacyContent = '';
        
//         // Combine second and third page content
//         if (data.containsKey('termsAndConditionSecondPage')) {
//           privacyContent += data['termsAndConditionSecondPage'];
//         }
        
//         if (data.containsKey('termsAndConditionThirdPage')) {
//           if (privacyContent.isNotEmpty) {
//             privacyContent += '<br><br>';
//           }
//           privacyContent += data['termsAndConditionThirdPage'];
//         }
        
//         if (privacyContent.isNotEmpty) {
//           _sections.add({
//             'title': 'Privacy Statement and Declaration',
//             'content': _fixNumbering(privacyContent)
//           });
//           _expandedSections[1] = false; // Initialize to collapsed
//         }
        
//         if (_sections.isNotEmpty) {
//           debugPrint('TermsWidget: Created ${_sections.length} sections');
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//             });
//           }
//         } else {
//           debugPrint('TermsWidget: No terms content found in response');
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//               _error = 'Terms and conditions not found in response';
//             });
//           }
//         }
//       } else {
//         throw Exception('Failed to load terms and conditions: ${loginResponse.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('TermsWidget: Error fetching terms: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _error = 'Error loading terms: $e';
//         });
//       }
//     }
//   }

//   String _fixNumbering(String htmlContent) {
//     // Remove the existing <li> tags and create a custom formatted list
//     String plainContent = htmlContent.replaceAll('<li>', '').replaceAll('</li>', '<br>');
    
//     // Split the content by <br> tags to get individual list items
//     List<String> items = plainContent.split('<br>');
    
//     // Rebuild the HTML with manual numbering and text-align: justify
//     StringBuffer fixedContent = StringBuffer();
    
//     // Add a wrapper div with justified alignment
//     fixedContent.write('<div style="text-align: justify;">');
    
//     for (int i = 0; i < items.length; i++) {
//       if (items[i].trim().isNotEmpty) {
//         // Clean any existing numbering patterns
//         String cleanItem = items[i].replaceAll(RegExp(r'^\s*0\.\s*\d+\.\s*'), '');
//         // Create a paragraph with proper indentation and margin for better readability
//         fixedContent.write(
//           '<p style="margin-bottom: 12px; text-indent: 0; padding-left: 20px; position: relative;">'
//           '<span style="position: absolute; left: 0;">${i+1}.</span> $cleanItem'
//           '</p>'
//         );
//       }
//     }
    
//     fixedContent.write('</div>');
    
//     return fixedContent.toString();
//   }

//   void _toggleSectionExpanded(int sectionIndex) {
//     setState(() {
//       _expandedSections[sectionIndex] = !(_expandedSections[sectionIndex] ?? false);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFFA1A1A1).withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           _buildSignatureSection(),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Center(
//                 child: CircularProgressIndicator(
//                   color: Color(0xFF205EB5),
//                 ),
//               ),
//             )
//           else if (_error != null)
//             _buildErrorMessage()
//           else
//             ..._sections.asMap().entries.map((entry) => 
//               _buildTermsSection(entry.key, entry.value['title'], entry.value['content'])
//             ).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         'Signature and Acceptance',
//         style: GoogleFonts.poppins(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: const Color(0xFF111213)
//         ),
//       ),
//     );
//   }

//   Widget _buildSignatureSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Text(
//             'Student\'s full name as a signature',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: const Color(0xFF205EB5),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         _buildInfoRow(
//           Icons.edit_outlined,
//           'Signature',
//           widget.userDetail?.signature ?? 'Not provided',
//         ),
//       ],
//     );
//   }

//   Widget _buildErrorMessage() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             _error!,
//             style: GoogleFonts.poppins(
//               color: Colors.red,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ElevatedButton(
//             onPressed: () {
//               _fetchTermsAndCondition();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF205EB5),
//               foregroundColor: Colors.white,
//             ),
//             child: Text(
//               'Retry',
//               style: GoogleFonts.poppins(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTermsSection(int index, String title, String content) {
//     bool isExpanded = _expandedSections[index] ?? false;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
//             child: Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             height: isExpanded ? null : 150,
//             constraints: isExpanded ? null : const BoxConstraints(maxHeight: 150),
//             child: ClipRect(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Html(
//                   data: content,
//                   style: {
//                     "body": Style(
//                       fontSize: FontSize(16),
//                       fontFamily: 'Poppins',
//                       color: const Color(0xFFA1A1A1),
//                       textAlign: TextAlign.justify,
//                     ),
//                     "p": Style(
//                       margin: Margins.only(bottom: 12),
//                       textAlign: TextAlign.justify,
//                     ),
//                     "div": Style(
//                       textAlign: TextAlign.justify,
//                     ),
//                     "span": Style(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   },
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Center(
//               child: ElevatedButton(
//                 onPressed: () => _toggleSectionExpanded(index),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFA1A1A1),
//                   foregroundColor: const Color(0xFF111213),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   isExpanded ? 'Show Less' : 'Show More',
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           if (index < _sections.length - 1)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Divider(
//                 color: Colors.grey[300],
//                 thickness: 1.0,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: const Color(0xFF205EB5),
//             size: 24,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: const Color(0xFFA1A1A1),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:ems/services/secure_storage_service.dart';

// class TermsAndConditionWidget extends StatefulWidget {
//   final UserDetail? userDetail;
  
//   const TermsAndConditionWidget({
//     super.key,
//     required this.userDetail,
//   });

//   @override
//   State<TermsAndConditionWidget> createState() => _TermsAndConditionWidgetState();
// }

// class _TermsAndConditionWidgetState extends State<TermsAndConditionWidget> {
//   String? _termsHtmlContent;
//   bool _isLoading = true;
//   bool _isExpanded = false;
//   String? _error;
//   List<Map<String, dynamic>> _termsPages = [];
//   int _currentPage = 0;

//   // List of page titles based on page index
//   final List<String> _pageTitles = [
//     'Terms & Condition',
//     'Privacy Statement and Declaration',
//     'Privacy Statement and Declaration'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchTermsAndCondition();
//   }


//   Future<void> _fetchTermsAndCondition() async {
//     if (widget.userDetail == null) {
//       debugPrint('TermsWidget: userDetail is null');
//       setState(() {
//         _isLoading = false;
//         _error = 'No user information available';
//       });
//       return;
//     }

//     debugPrint('TermsWidget: term_and_condition value: ${widget.userDetail!.termAndCondition}');

    
//     if (widget.userDetail!.termAndCondition.isEmpty) {
//       debugPrint('TermsWidget: term_and_condition is empty');
//       setState(() {
//         _isLoading = false;
//         _error = 'No terms and condition information available';
//       });
//       return;
//     }

//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       // Get credentials from secure storage
//       final email = await SecureStorageService.getUserEmail();
//       final password = await SecureStorageService.getUserPassword();
      
//       debugPrint('TermsWidget: Retrieved credentials - Email: $email');
      
//       if (email == null || password == null) {
//         throw Exception('Stored credentials not found');
//       }
      
//       // Use the same login endpoint to get terms and conditions
//       final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';
//       debugPrint('TermsWidget: Making API request to: $loginUrl');

//       final requestBody = {
//         'email': email,
//         'password': password,
//         'get_terms': widget.userDetail!.termAndCondition
//       };
      
//       final loginResponse = await http.post(
//         Uri.parse(loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(requestBody),
//       );

//       debugPrint('TermsWidget: API Response Status Code: ${loginResponse.statusCode}');
      
//       if (loginResponse.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(loginResponse.body);
//         debugPrint('TermsWidget: Response keys: ${data.keys.toList()}');
        
//         // Check for the three terms pages
//         _termsPages = [];
//         if (data.containsKey('termsAndConditionFirstPage')) {
//           _termsPages.add({
//             'title': _pageTitles[0],
//             'content': _fixNumbering(data['termsAndConditionFirstPage'])
//           });
//         }
        
//         if (data.containsKey('termsAndConditionSecondPage')) {
//           _termsPages.add({
//             'title': _pageTitles[1], 
//             'content': _fixNumbering(data['termsAndConditionSecondPage'])
//           });
//         }
        
//         if (data.containsKey('termsAndConditionThirdPage')) {
//           _termsPages.add({
//             'title': _pageTitles[2],
//             'content': _fixNumbering(data['termsAndConditionThirdPage'])
//           });
//         }
        
//         if (_termsPages.isNotEmpty) {
//           debugPrint('TermsWidget: Found ${_termsPages.length} terms pages');
//           if (mounted) {
//             setState(() {
//               _termsHtmlContent = _termsPages[0]['content'];
//               _isLoading = false;
//             });
//           }
//         } else {
//           debugPrint('TermsWidget: No terms pages found in response');
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//               _error = 'Terms and conditions not found in response';
//             });
//           }
//         }
//       } else {
//         throw Exception('Failed to load terms and conditions: ${loginResponse.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('TermsWidget: Error fetching terms: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _error = 'Error loading terms: $e';
//         });
//       }
//     }
//   }

//   String _fixNumbering(String htmlContent) {
//     // Remove the existing <li> tags and create a custom formatted list
//     String plainContent = htmlContent.replaceAll('<li>', '').replaceAll('</li>', '<br>');
    
//     // Split the content by <br> tags to get individual list items
//     List<String> items = plainContent.split('<br>');
    
//     // Rebuild the HTML with manual numbering and text-align: justify
//     StringBuffer fixedContent = StringBuffer();
    
//     // Add a wrapper div with justified alignment
//     fixedContent.write('<div style="text-align: justify;">');
    
//     for (int i = 0; i < items.length; i++) {
//       if (items[i].trim().isNotEmpty) {
//         // Clean any existing numbering patterns
//         String cleanItem = items[i].replaceAll(RegExp(r'^\s*0\.\s*\d+\.\s*'), '');
//         // Create a paragraph with proper indentation and margin for better readability
//         fixedContent.write(
//           '<p style="margin-bottom: 12px; text-indent: 0; padding-left: 20px; position: relative;">'
//           '<span style="position: absolute; left: 0;">${i+1}.</span> $cleanItem'
//           '</p>'
//         );
//       }
//     }
    
//     fixedContent.write('</div>');
    
//     return fixedContent.toString();
//   }

//   void _nextPage() {
//     if (_currentPage < _termsPages.length - 1) {
//       setState(() {
//         _currentPage++;
//         _termsHtmlContent = _termsPages[_currentPage]['content'];
//       });
//     }
//   }

//   void _previousPage() {
//     if (_currentPage > 0) {
//       setState(() {
//         _currentPage--;
//         _termsHtmlContent = _termsPages[_currentPage]['content'];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xFFA1A1A1).withValues(),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           _buildSignatureSection(),
//           _buildTermsAndConditionSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         'Signature and Acceptance',
//         style: GoogleFonts.poppins(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color : const Color(0xFF111213)
//         ),
//       ),
//     );
//   }

//   Widget _buildSignatureSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal:8,),
//           child: Text(
//             'Student\'s full name as a signature',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: const Color(0xFF205EB5),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         _buildInfoRow(
//           Icons.edit_outlined,
//           'Signature',
//           widget.userDetail?.signature ?? 'Not provided',
//         ),
//       ],
//     );
//   }

//   Widget _buildTermsAndConditionSection() {
//     // Get the current page title
//     String currentPageTitle = _termsPages.isNotEmpty && _currentPage < _termsPages.length 
//         ? _termsPages[_currentPage]['title'] 
//         : 'Terms & Condition';

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   currentPageTitle,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               if (_termsPages.isNotEmpty)
//                 Text(
//                   'Page ${_currentPage + 1} of ${_termsPages.length}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         if (_isLoading)
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF205EB5),
//               ),
//             ),
//           )
//         else if (_error != null)
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _error!,
//                   style: GoogleFonts.poppins(
//                     color: Colors.red,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () {
//                     _fetchTermsAndCondition();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF205EB5),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text(
//                     'Retry',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else if (_termsHtmlContent != null)
//           Column(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 height: _isExpanded ? null : 150,
//                 constraints: _isExpanded ? null : const BoxConstraints(maxHeight: 150),
//                 child: ClipRect(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Html(
//                       data: _termsHtmlContent!,
//                       style: {
//                         "body": Style(
//                           fontSize: FontSize(16),
//                           fontFamily: 'Poppins',
//                           color: Color(0xFFA1A1A1),
//                           textAlign: TextAlign.justify,
//                         ),
//                         "p": Style(
//                           margin: Margins.only(bottom: 12),
//                           textAlign: TextAlign.justify,
//                         ),
//                         "div": Style(
//                           textAlign: TextAlign.justify,
//                         ),
//                         "span": Style(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     if (_termsPages.length > 1)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: _currentPage > 0 ? _previousPage : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF205EB5),
//                               foregroundColor: Colors.white,
//                               disabledBackgroundColor: Color(0xFFA1A1A1),
//                             ),
//                             child: Text(
//                               'Previous',
//                               style: GoogleFonts.poppins(),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           ElevatedButton(
//                             onPressed: _currentPage < _termsPages.length - 1 ? _nextPage : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF205EB5),
//                               foregroundColor: Colors.white,
//                               disabledBackgroundColor: Color(0xFFA1A1A1),
//                             ),
//                             child: Text(
//                               'Next',
//                               style: GoogleFonts.poppins(),
//                             ),
//                           ),
//                         ],
//                       ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _isExpanded = !_isExpanded;
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFFA1A1A1),
//                         foregroundColor: Color(0xFF111213),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Text(
//                         _isExpanded ? 'Show Less' : 'Show More',
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           )
//         else
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Text('No terms and conditions found.'),
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: const Color(0xFF205EB5),
//             size: 24,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Color(0xFFA1A1A1),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:ems/services/secure_storage_service.dart';

// class TermsAndConditionWidget extends StatefulWidget {
//   final UserDetail? userDetail;
  
//   const TermsAndConditionWidget({
//     super.key,
//     required this.userDetail,
//   });

//   @override
//   State<TermsAndConditionWidget> createState() => _TermsAndConditionWidgetState();
// }

// class _TermsAndConditionWidgetState extends State<TermsAndConditionWidget> {
//   String? _termsHtmlContent;
//   bool _isLoading = true;
//   bool _isExpanded = false;
//   String? _error;
//   List<Map<String, dynamic>> _termsPages = [];
//   int _currentPage = 0;

//   // List of page titles based on page index
//   final List<String> _pageTitles = [
//     'Terms & Condition',
//     'Privacy Statement and Declaration',
//     'Privacy Statement and Declaration'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchTermsAndCondition();
//   }


//   Future<void> _fetchTermsAndCondition() async {
//     if (widget.userDetail == null) {
//       debugPrint('TermsWidget: userDetail is null');
//       setState(() {
//         _isLoading = false;
//         _error = 'No user information available';
//       });
//       return;
//     }

//     debugPrint('TermsWidget: term_and_condition value: ${widget.userDetail!.termAndCondition}');

    
//     if (widget.userDetail!.termAndCondition.isEmpty) {
//       debugPrint('TermsWidget: term_and_condition is empty');
//       setState(() {
//         _isLoading = false;
//         _error = 'No terms and condition information available';
//       });
//       return;
//     }

//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       // Get credentials from secure storage
//       final email = await SecureStorageService.getUserEmail();
//       final password = await SecureStorageService.getUserPassword();
      
//       debugPrint('TermsWidget: Retrieved credentials - Email: $email');
      
//       if (email == null || password == null) {
//         throw Exception('Stored credentials not found');
//       }
      
//       // Use the same login endpoint to get terms and conditions
//       final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';
//       debugPrint('TermsWidget: Making API request to: $loginUrl');

//       final requestBody = {
//         'email': email,
//         'password': password,
//         'get_terms': widget.userDetail!.termAndCondition
//       };
      
//       final loginResponse = await http.post(
//         Uri.parse(loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(requestBody),
//       );

//       debugPrint('TermsWidget: API Response Status Code: ${loginResponse.statusCode}');
      
//       if (loginResponse.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(loginResponse.body);
//         debugPrint('TermsWidget: Response keys: ${data.keys.toList()}');
        
//         // Check for the three terms pages
//         _termsPages = [];
//         if (data.containsKey('termsAndConditionFirstPage')) {
//           _termsPages.add({
//             'title': _pageTitles[0],
//             'content': _fixNumbering(data['termsAndConditionFirstPage'])
//           });
//         }
        
//         if (data.containsKey('termsAndConditionSecondPage')) {
//           _termsPages.add({
//             'title': _pageTitles[1], 
//             'content': _fixNumbering(data['termsAndConditionSecondPage'])
//           });
//         }
        
//         if (data.containsKey('termsAndConditionThirdPage')) {
//           _termsPages.add({
//             'title': _pageTitles[2],
//             'content': _fixNumbering(data['termsAndConditionThirdPage'])
//           });
//         }
        
//         if (_termsPages.isNotEmpty) {
//           debugPrint('TermsWidget: Found ${_termsPages.length} terms pages');
//           if (mounted) {
//             setState(() {
//               _termsHtmlContent = _termsPages[0]['content'];
//               _isLoading = false;
//             });
//           }
//         } else {
//           debugPrint('TermsWidget: No terms pages found in response');
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//               _error = 'Terms and conditions not found in response';
//             });
//           }
//         }
//       } else {
//         throw Exception('Failed to load terms and conditions: ${loginResponse.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('TermsWidget: Error fetching terms: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _error = 'Error loading terms: $e';
//         });
//       }
//     }
//   }

// String _fixNumbering(String htmlContent) {
//   // Remove the existing <li> tags and create a custom formatted list
//   String plainContent = htmlContent.replaceAll('<li>', '').replaceAll('</li>', '<br>');
  
//   // Split the content by <br> tags to get individual list items
//   List<String> items = plainContent.split('<br>');
  
//   // Rebuild the HTML with manual numbering
//   StringBuffer fixedContent = StringBuffer();
//   for (int i = 0; i < items.length; i++) {
//     if (items[i].trim().isNotEmpty) {
//       // Clean any existing numbering patterns
//       String cleanItem = items[i].replaceAll(RegExp(r'^\s*0\.\s*\d+\.\s*'), '');
//       // fixedContent.write('<div>${i+1}. $cleanItem</div>');
//        fixedContent.write('<div style="margin-left: 5px; margin-bottom: 10px; text-indent: -15px; padding-left: 5px;">${i+1}. $cleanItem</div>');
//     }
//   }
  
//   return fixedContent.toString();
// }

//   void _nextPage() {
//     if (_currentPage < _termsPages.length - 1) {
//       setState(() {
//         _currentPage++;
//         _termsHtmlContent = _termsPages[_currentPage]['content'];
//       });
//     }
//   }

//   void _previousPage() {
//     if (_currentPage > 0) {
//       setState(() {
//         _currentPage--;
//         _termsHtmlContent = _termsPages[_currentPage]['content'];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xFFA1A1A1).withValues(),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           _buildSignatureSection(),
//           _buildTermsAndConditionSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         'Signature and Acceptance',
//         style: GoogleFonts.poppins(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color : const Color(0xFF111213)
//         ),
//       ),
//     );
//   }

//   Widget _buildSignatureSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal:8,),
//           child: Text(
//             'Student\'s full name as a signature',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: const Color(0xFF205EB5),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         _buildInfoRow(
//           Icons.edit_outlined,
//           'Signature',
//           widget.userDetail?.signature ?? 'Not provided',
//         ),
//       ],
//     );
//   }

//   Widget _buildTermsAndConditionSection() {
//     // Get the current page title
//     String currentPageTitle = _termsPages.isNotEmpty && _currentPage < _termsPages.length 
//         ? _termsPages[_currentPage]['title'] 
//         : 'Terms & Condition';

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   currentPageTitle,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               if (_termsPages.isNotEmpty)
//                 Text(
//                   'Page ${_currentPage + 1} of ${_termsPages.length}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         if (_isLoading)
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: const Color(0xFF205EB5),
//               ),
//             ),
//           )
//         else if (_error != null)
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _error!,
//                   style: GoogleFonts.poppins(
//                     color: Colors.red,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () {
//                     _fetchTermsAndCondition();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF205EB5),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text(
//                     'Retry',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else if (_termsHtmlContent != null)
//           Column(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 height: _isExpanded ? null : 150,
//                 constraints: _isExpanded ? null : const BoxConstraints(maxHeight: 150),
//                 child: ClipRect(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Html(
//                       data: _termsHtmlContent!,
//                       style: {
//                         "body": Style(
//                           fontSize: FontSize(16), // Increased font size to 16
//                           fontFamily: 'Poppins',
//                           color: Color(0xFFA1A1A1),
//                         ),
//                         "li": Style(
//                            margin: Margins.only(bottom: 8),
//                         ),
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     if (_termsPages.length > 1)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: _currentPage > 0 ? _previousPage : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF205EB5),
//                               foregroundColor: Colors.white,
//                               disabledBackgroundColor: Color(0xFFA1A1A1),
//                             ),
//                             child: Text(
//                               'Previous',
//                               style: GoogleFonts.poppins(),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           ElevatedButton(
//                             onPressed: _currentPage < _termsPages.length - 1 ? _nextPage : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF205EB5),
//                               foregroundColor: Colors.white,
//                               disabledBackgroundColor: Color(0xFFA1A1A1),
//                             ),
//                             child: Text(
//                               'Next',
//                               style: GoogleFonts.poppins(),
//                             ),
//                           ),
//                         ],
//                       ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _isExpanded = !_isExpanded;
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFFA1A1A1),
//                         foregroundColor: Color(0xFF111213),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Text(
//                         _isExpanded ? 'Show Less' : 'Show More',
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           )
//         else
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Text('No terms and conditions found.'),
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: const Color(0xFF205EB5),
//             size: 24,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Color(0xFFA1A1A1),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }























// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:ems/services/secure_storage_service.dart';

// class TermsAndConditionWidget extends StatefulWidget {
//   final UserDetail? userDetail;
  
//   const TermsAndConditionWidget({
//     Key? key,
//     required this.userDetail,
//   }) : super(key: key);

//   @override
//   State<TermsAndConditionWidget> createState() => _TermsAndConditionWidgetState();
// }

// class _TermsAndConditionWidgetState extends State<TermsAndConditionWidget> {
//   String? _termsHtmlContent;
//   bool _isLoading = true;
//   bool _isExpanded = false;
//   String? _error;
//   List<Map<String, dynamic>> _termsPages = [];
//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTermsAndCondition();
//   }

//   Future<void> _fetchTermsAndCondition() async {
//     if (widget.userDetail == null) {
//       debugPrint('TermsWidget: userDetail is null');
//       setState(() {
//         _isLoading = false;
//         _error = 'No user information available';
//       });
//       return;
//     }

//     debugPrint('TermsWidget: term_and_condition value: ${widget.userDetail!.termAndCondition}');
    
//     if (widget.userDetail!.termAndCondition.isEmpty) {
//       debugPrint('TermsWidget: term_and_condition is empty');
//       setState(() {
//         _isLoading = false;
//         _error = 'No terms and condition information available';
//       });
//       return;
//     }

//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       // Get credentials from secure storage
//       final email = await SecureStorageService.getUserEmail();
//       final password = await SecureStorageService.getUserPassword();
      
//       debugPrint('TermsWidget: Retrieved credentials - Email: $email');
      
//       if (email == null || password == null) {
//         throw Exception('Stored credentials not found');
//       }
      
//       // Use the same login endpoint to get terms and conditions
//       final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';
//       debugPrint('TermsWidget: Making API request to: $loginUrl');

//       final requestBody = {
//         'email': email,
//         'password': password,
//         'get_terms': widget.userDetail!.termAndCondition
//       };
      
//       final loginResponse = await http.post(
//         Uri.parse(loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(requestBody),
//       );

//       debugPrint('TermsWidget: API Response Status Code: ${loginResponse.statusCode}');
      
//       if (loginResponse.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(loginResponse.body);
//         debugPrint('TermsWidget: Response keys: ${data.keys.toList()}');
        
//         // Check for the three terms pages
//         _termsPages = [];
        
//         if (data.containsKey('termsAndConditionFirstPage')) {
//           _termsPages.add({
//             'title': 'Page 1',
//             'content': data['termsAndConditionFirstPage']
//           });
//         }
        
//         if (data.containsKey('termsAndConditionSecondPage')) {
//           _termsPages.add({
//             'title': 'Page 2',
//             'content': data['termsAndConditionSecondPage']
//           });
//         }
        
//         if (data.containsKey('termsAndConditionThirdPage')) {
//           _termsPages.add({
//             'title': 'Page 3',
//             'content': data['termsAndConditionThirdPage']
//           });
//         }
        
//         if (_termsPages.isNotEmpty) {
//           debugPrint('TermsWidget: Found ${_termsPages.length} terms pages');
//           if (mounted) {
//             setState(() {
//               _termsHtmlContent = _termsPages[0]['content'];
//               _isLoading = false;
//             });
//           }
//         } else {
//           debugPrint('TermsWidget: No terms pages found in response');
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//               _error = 'Terms and conditions not found in response';
//             });
//           }
//         }
//       } else {
//         throw Exception('Failed to load terms and conditions: ${loginResponse.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('TermsWidget: Error fetching terms: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _error = 'Error loading terms: $e';
//         });
//       }
//     }
//   }

//   void _nextPage() {
//     if (_currentPage < _termsPages.length - 1) {
//       setState(() {
//         _currentPage++;
//         _termsHtmlContent = _termsPages[_currentPage]['content'];
//       });
//     }
//   }

//   void _previousPage() {
//     if (_currentPage > 0) {
//       setState(() {
//         _currentPage--;
//         _termsHtmlContent = _termsPages[_currentPage]['content'];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           _buildSignatureSection(),
//           _buildTermsAndConditionSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         'Signature and Acceptance',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildSignatureSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Text(
//             'Student\'s full name as a signature',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: const Color.fromARGB(255, 227, 10, 169),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         _buildInfoRow(
//           Icons.edit_outlined,
//           'Signature',
//           widget.userDetail?.signature ?? 'Not provided',
//         ),
//       ],
//     );
//   }

//   Widget _buildTermsAndConditionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Terms & Condition',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               if (_termsPages.isNotEmpty)
//                 Text(
//                   'Page ${_currentPage + 1} of ${_termsPages.length}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         if (_isLoading)
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: Color.fromARGB(255, 227, 10, 169),
//               ),
//             ),
//           )
//         else if (_error != null)
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _error!,
//                   style: GoogleFonts.poppins(
//                     color: Colors.red,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () {
//                     _fetchTermsAndCondition();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 227, 10, 169),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text(
//                     'Retry',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else if (_termsHtmlContent != null)
//           Column(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 height: _isExpanded ? null : 150,
//                 constraints: _isExpanded ? null : const BoxConstraints(maxHeight: 150),
//                 child: ClipRect(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Html(
//                       data: _termsHtmlContent!,
//                       style: {
//                         "body": Style(
//                           fontSize: FontSize(14),
//                           fontFamily: 'Poppins',
//                           color: Colors.grey[700],
//                         ),
//                         "li": Style(
//                            margin: Margins.only(bottom: 8),
//                         ),
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     if (_termsPages.length > 1)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: _currentPage > 0 ? _previousPage : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color.fromARGB(255, 227, 10, 169),
//                               foregroundColor: Colors.white,
//                               disabledBackgroundColor: Colors.grey[300],
//                             ),
//                             child: Text(
//                               'Previous',
//                               style: GoogleFonts.poppins(),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           ElevatedButton(
//                             onPressed: _currentPage < _termsPages.length - 1 ? _nextPage : null,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color.fromARGB(255, 227, 10, 169),
//                               foregroundColor: Colors.white,
//                               disabledBackgroundColor: Colors.grey[300],
//                             ),
//                             child: Text(
//                               'Next',
//                               style: GoogleFonts.poppins(),
//                             ),
//                           ),
//                         ],
//                       ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _isExpanded = !_isExpanded;
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[200],
//                         foregroundColor: Colors.black87,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Text(
//                         _isExpanded ? 'Show Less' : 'Show More',
//                         style: GoogleFonts.poppins(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           )
//         else
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Text('No terms and conditions found.'),
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: const Color.fromARGB(255, 227, 10, 169),
//             size: 24,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:ems/services/secure_storage_service.dart';

// class TermsAndConditionWidget extends StatefulWidget {
//   final UserDetail? userDetail;
  
//   const TermsAndConditionWidget({
//     Key? key,
//     required this.userDetail,
//   }) : super(key: key);

//   @override
//   State<TermsAndConditionWidget> createState() => _TermsAndConditionWidgetState();
// }

// class _TermsAndConditionWidgetState extends State<TermsAndConditionWidget> {
//   String? _termsHtmlContent;
//   bool _isLoading = true;
//   bool _isExpanded = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTermsAndCondition();
//   }

//   Future<void> _fetchTermsAndCondition() async {
//     if (widget.userDetail == null) {
//       debugPrint('TermsWidget: userDetail is null');
//       setState(() {
//         _isLoading = false;
//         _error = 'No user information available';
//       });
//       return;
//     }

//     debugPrint('TermsWidget: term_and_condition value: ${widget.userDetail!.termAndCondition}');
    
//     if (widget.userDetail!.termAndCondition.isEmpty) {
//       debugPrint('TermsWidget: term_and_condition is empty');
//       setState(() {
//         _isLoading = false;
//         _error = 'No terms and condition information available';
//       });
//       return;
//     }

//     try {
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       // Get credentials from secure storage
//       final email = await SecureStorageService.getUserEmail();
//       final password = await SecureStorageService.getUserPassword();
      
//       debugPrint('TermsWidget: Retrieved credentials - Email: $email');
      
//       if (email == null || password == null) {
//         throw Exception('Stored credentials not found');
//       }
      
//       // Use the same login endpoint to get terms and conditions
//       final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';
//       debugPrint('TermsWidget: Making API request to: $loginUrl');
//       debugPrint('TermsWidget: Requesting terms with ID: ${widget.userDetail!.termAndCondition}');

//       // Try first approach: just sending the term ID
//       final requestBody = {
//         'email': email,
//         'password': password,
//         'get_terms': widget.userDetail!.termAndCondition
//       };
      
//       debugPrint('TermsWidget: Request body: ${json.encode(requestBody)}');

//       final loginResponse = await http.post(
//         Uri.parse(loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(requestBody),
//       );

//       debugPrint('TermsWidget: API Response Status Code: ${loginResponse.statusCode}');
//       debugPrint('TermsWidget: API Response Body: ${loginResponse.body}');

//       if (loginResponse.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(loginResponse.body);
        
//         // Debug output of all keys in the response
//         debugPrint('TermsWidget: Response keys: ${data.keys.toList()}');
        
//         // Check if terms_and_conditions exists in the response
//         if (data.containsKey('terms_and_conditions')) {
//           debugPrint('TermsWidget: Terms found in response');
//           if (mounted) {
//             setState(() {
//               // Assuming the API returns HTML content in terms_and_conditions field
//               _termsHtmlContent = data['terms_and_conditions']['content'] as String?;
//               debugPrint('TermsWidget: Terms content length: ${_termsHtmlContent?.length ?? 0}');
//               _isLoading = false;
//             });
//           }
//         } else {
//           // Check for alternative keys that might contain the terms
//           // Sometimes APIs use different naming conventions
//           final possibleKeys = ['terms_and_condition', 'terms', 'termsAndConditions', 'term'];
//           String? foundContent;
          
//           for (final key in possibleKeys) {
//             if (data.containsKey(key)) {
//               debugPrint('TermsWidget: Found alternative key: $key');
//               if (data[key] is Map && data[key].containsKey('content')) {
//                 foundContent = data[key]['content'] as String?;
//               } else if (data[key] is String) {
//                 foundContent = data[key] as String?;
//               }
//               break;
//             }
//           }
          
//           if (foundContent != null) {
//             if (mounted) {
//               setState(() {
//                 _termsHtmlContent = foundContent;
//                 _isLoading = false;
//               });
//             }
//           } else {
//             debugPrint('TermsWidget: Terms not found in response');
//             if (mounted) {
//               setState(() {
//                 _isLoading = false;
//                 _error = 'Terms and conditions not found in response';
//               });
//             }
//           }
//         }
//       } else {
//         throw Exception('Failed to load terms and conditions: ${loginResponse.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('TermsWidget: Error fetching terms: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _error = 'Error loading terms: $e';
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           _buildSignatureSection(),
//           _buildTermsAndConditionSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         'Signature and Acceptance',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildSignatureSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Text(
//             'Student\'s full name as a signature',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: const Color.fromARGB(255, 227, 10, 169),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         _buildInfoRow(
//           Icons.edit_outlined,
//           'Signature',
//           widget.userDetail?.signature ?? 'Not provided',
//         ),
//       ],
//     );
//   }

//   Widget _buildTermsAndConditionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
//           child: Text(
//             'Terms & Condition',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         if (_isLoading)
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: Color.fromARGB(255, 227, 10, 169),
//               ),
//             ),
//           )
//         else if (_error != null)
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _error!,
//                   style: GoogleFonts.poppins(
//                     color: Colors.red,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () {
//                     _fetchTermsAndCondition();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromARGB(255, 227, 10, 169),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text(
//                     'Retry',
//                     style: GoogleFonts.poppins(),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         else if (_termsHtmlContent != null)
//           Column(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 height: _isExpanded ? null : 150,
//                 constraints: _isExpanded ? null : const BoxConstraints(maxHeight: 150),
//                 child: ClipRect(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Html(
//                       data: _termsHtmlContent!,
//                       style: {
//                         "body": Style(
//                           fontSize: FontSize(14),
//                           fontFamily: 'Poppins',
//                           color: Colors.grey[700],
//                         ),
//                         "li": Style(
//                            margin: Margins.only(bottom: 8),
//                         ),
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _isExpanded = !_isExpanded;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[200],
//                       foregroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       _isExpanded ? 'Show Less' : 'Show More',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           )
//         else
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Text('No terms and conditions found.'),
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: const Color.fromARGB(255, 227, 10, 169),
//             size: 24,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/models/user_detail.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:ems/services/secure_storage_service.dart';

// class TermsAndConditionWidget extends StatefulWidget {
//   final UserDetail? userDetail;
  
//   const TermsAndConditionWidget({
//     Key? key,
//     required this.userDetail,
//   }) : super(key: key);

//   @override
//   State<TermsAndConditionWidget> createState() => _TermsAndConditionWidgetState();
// }

// class _TermsAndConditionWidgetState extends State<TermsAndConditionWidget> {
//   String? _termsHtmlContent;
//   bool _isLoading = true;
//   bool _isExpanded = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTermsAndCondition();
//   }

//   Future<void> _fetchTermsAndCondition() async {
//     if (widget.userDetail == null || widget.userDetail!.termAndCondition.isEmpty) {
//       setState(() {
//         _isLoading = false;
//         _error = 'No terms and condition information available';
//       });
//       return;
//     }

    
//       setState(() {
//         _isLoading = true;
//         _error = null;
//       });

//       // Get credentials from secure storage
//       final email = await SecureStorageService.getUserEmail();
//       final password = await SecureStorageService.getUserPassword();
      
//       if (email == null || password == null) {
//         throw Exception('Stored credentials not found');
//       }
      
//       // Use the same login endpoint to get terms and conditions
//       final loginUrl = 'https://extratech.extratechweb.com/api/auth/login';

//       final loginResponse = await http.post(
//         Uri.parse(loginUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode({
//           'email': email,
//           'password': password,
//           'get_terms': widget.userDetail!.termAndCondition // Request specific terms
//         }),
//       );

//       if (loginResponse.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(loginResponse.body);
        
//         // Check if terms_and_conditions exists in the response
//         if (data.containsKey('terms_and_conditions')) {
//           if (mounted) {
//             setState(() {
//               // Assuming the API returns HTML content in terms_and_conditions field
//               _termsHtmlContent = data['terms_and_conditions']['content'] as String?;
//               _isLoading = false;
//             });
//           }
//         } 
//       } else {
//         throw Exception('Failed to load terms and conditions: ${loginResponse.statusCode}');
//       }
    
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           _buildSignatureSection(),
//           _buildTermsAndConditionSection(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         'Signature and Acceptance',
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildSignatureSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Text(
//             'Student\'s full name as a signature',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: const Color.fromARGB(255, 227, 10, 169),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         _buildInfoRow(
//           Icons.edit_outlined,
//           'Signature',
//           widget.userDetail?.signature ?? 'Not provided',
//         ),
//       ],
//     );
//   }

//   Widget _buildTermsAndConditionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
//           child: Text(
//             'Terms & Condition',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         if (_isLoading)
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: Color.fromARGB(255, 227, 10, 169),
//               ),
//             ),
//           )
//         else if (_error != null)
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               _error!,
//               style: GoogleFonts.poppins(
//                 color: Colors.red,
//                 fontSize: 14,
//               ),
//             ),
//           )
//         else if (_termsHtmlContent != null)
//           Column(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 height: _isExpanded ? null : 150,
//                 constraints: _isExpanded ? null : const BoxConstraints(maxHeight: 150),
//                 child: ClipRect(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Html(
//                       data: _termsHtmlContent!,
//                       style: {
//                         "body": Style(
//                           fontSize: FontSize(14),
//                           fontFamily: 'Poppins',
//                           color: Colors.grey[700],
//                         ),
//                         "li": Style(
//                            margin: Margins.only(bottom: 8),

//                         ),
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _isExpanded = !_isExpanded;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey[200],
//                       foregroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       _isExpanded ? 'Show Less' : 'Show More',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           )
//         else
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Text('No terms and conditions found.'),
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: const Color.fromARGB(255, 227, 10, 169),
//             size: 24,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }