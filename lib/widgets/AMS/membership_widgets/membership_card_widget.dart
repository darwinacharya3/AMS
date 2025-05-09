import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ems/services/country_service.dart';

class MembershipCardDisplay extends StatefulWidget {
  final Map<String, dynamic> cardData;
  final List<Map<String, dynamic>>? membershipTypes;

  const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
  @override
  State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
}

class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
  String _countryName = 'Loading...';
  bool _isLoadingCountry = true;
  bool _hasQrCode = false;
  String? _svgContent;
  String _errorMessage = '';
  String? _membershipTypeName;
  
  @override
  void initState() {
    super.initState();
    _loadCountryName();
    _processQrCode();
    _getMembershipTypeName();
  }
  
  void _getMembershipTypeName() {
    // Get card type id from card data
    final cardTypeId = widget.cardData['card_type_id'];
    
    if (cardTypeId != null && widget.membershipTypes != null) {
      for (final type in widget.membershipTypes!) {
        if (type['id'] == cardTypeId) {
          setState(() {
            _membershipTypeName = type['type'];
          });
          return;
        }
      }
    }
    
    // If we can't find the type or there are no types, use a default value
    setState(() {
      _membershipTypeName = widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : 'Regular';
    });
  }
  
  void _processQrCode() {
    if (widget.cardData.containsKey('qr_code')) {
      try {
        final qrCodeData = widget.cardData['qr_code'].toString();
        
        if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
          // Extract base64 part
          final base64String = qrCodeData.split('base64,')[1];
          
          // Decode base64 to bytes
          final bytes = base64Decode(base64String);
          
          // Convert bytes to SVG string
          final svgString = utf8.decode(bytes);
          
          setState(() {
            _svgContent = svgString;
            _hasQrCode = true;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid QR format';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error processing QR';
        });
      }
    }
  }

  Future<void> _loadCountryName() async {
    if (widget.cardData['country_id'] != null) {
      try {
        final countryName = await CountryService.getCountryName(widget.cardData['country_id']);
        if (mounted) {
          setState(() {
            _countryName = countryName;
            _isLoadingCountry = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _countryName = 'Unknown';
            _isLoadingCountry = false;
          });
        }
      }
    } else {
      setState(() {
        _countryName = 'Not specified';
        _isLoadingCountry = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if application is still pending (status != 1)
    final bool isPending = widget.cardData['status'] != 1;
    
    if (isPending) {
      return _buildPendingApplicationView();
    }
    
    // If status is 1 (approved), show the actual card
    return _buildApprovedCardView();
  }

  Widget _buildPendingApplicationView() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(24.0),
                child: Icon(
                  Icons.check_circle_outline,
                  color: const Color(0xFF205EB5),
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Application Submitted',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111213),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your membership card application has been submitted successfully and is awaiting approval.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.access_time,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Status',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Under Review',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'You will be notified when your application is approved. Your membership card will be available here after approval.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Application reference number if available
              if (widget.cardData['qr_code_no'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reference: ${widget.cardData['qr_code_no']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovedCardView() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = screenWidth - 32;
        
        return Container(
          width: cardWidth,
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(cardWidth),
                  
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  _buildDetailsSection(cardWidth),
                  
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  _buildValiditySection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(double availableWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.cardData['photo_url'] != null
            ? CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(widget.cardData['photo_url']),
              )
            : CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                child: Icon(
                  Icons.person,
                  size: 35,
                  color: Color(0xFF205EB5),
                ),
              ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cardData['name'] ?? 'User Name',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF205EB5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 14,
                    color: Color(0xFF205EB5),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.cardData['email'] ?? 'email@example.com',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.card_membership,
                    size: 14,
                    color: Color(0xFF205EB5),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _membershipTypeName ?? 'Membership Type',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Active',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Color(0xFF205EB5),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.cardData['address'] ?? 'No address',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(double availableWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('ID:', widget.cardData['qr_code_no'].toString()),  
              const SizedBox(height: 12),
              _buildInfoRow('D.O.B:', _formatDate(widget.cardData['dob']).toString()),
              const SizedBox(height: 12),
              _buildNationalityRow(
                _isLoadingCountry ? 'Loading...' : _countryName
              ),
            ],
          ),
        ),
        
        Expanded(
          flex: 35,
          child: _buildQrCode(),
        ),
      ],
    );
  }

  Widget _buildValiditySection() {
    final startDate = _formatDate(widget.cardData['start_date']);
    final expiryDate = _formatDate(widget.cardData['expiry_date']);
    final isLifetime = widget.cardData['is_lifetime'] == 1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Membership Validity:',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF205EB5),
          ),
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Date:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111213),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      startDate ?? 'Not specified',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Color(0xFF111213),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expiry Date:',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111213),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: isLifetime ? Border.all(color: Colors.green, width: 1.5) : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isLifetime ? 'Lifetime' : (expiryDate ?? 'Not specified'),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isLifetime ? Colors.green : Color(0xFF111213),
                              fontWeight: isLifetime ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isLifetime)
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF205EB5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Color(0xFF111213),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildNationalityRow(String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nationality:',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF205EB5),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildQrCode() {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _hasQrCode && _svgContent != null
            ? SvgPicture.string(
                _svgContent!,
                fit: BoxFit.contain,
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Error loading QR',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.red[300],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  String? _formatDate(String? dateString) {
    if (dateString == null) return null;
    try {
      final date = DateTime.parse(dateString);
      final day = date.day.toString().padLeft(2, '0');
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final month = months[date.month - 1];
      final year = date.year.toString();
      return '$day $month. $year';
    } catch (e) {
      return dateString;
    }
  }
}


















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:ems/services/country_service.dart';

// class MembershipCardDisplay extends StatefulWidget {
//   final Map<String, dynamic> cardData;
//   final List<Map<String, dynamic>>? membershipTypes;

//   const MembershipCardDisplay({super.key, required this.cardData, this.membershipTypes});
//   @override
//   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// }

// class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
//   String _countryName = 'Loading...';
//   bool _isLoadingCountry = true;
//   bool _hasQrCode = false;
//   String? _svgContent;
//   String _errorMessage = '';
//   String? _membershipTypeName;
  
//   @override
//   void initState() {
//     super.initState();
//     _loadCountryName();
//     _processQrCode();
//     _getMembershipTypeName();
//   }
  
//   void _getMembershipTypeName() {
//     // Get card type id from card data
//     final cardTypeId = widget.cardData['card_type_id'];
    
//     if (cardTypeId != null && widget.membershipTypes != null) {
//       for (final type in widget.membershipTypes!) {
//         if (type['id'] == cardTypeId) {
//           setState(() {
//             _membershipTypeName = type['type'];
//           });
//           return;
//         }
//       }
//     }
    
//     // If we can't find the type or there are no types, use a default value
//     setState(() {
//       _membershipTypeName = widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : 'Regular';
//     });
//   }
  
//   void _processQrCode() {
//     if (widget.cardData.containsKey('qr_code')) {
//       try {
//         final qrCodeData = widget.cardData['qr_code'].toString();
        
//         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
//           // Extract base64 part
//           final base64String = qrCodeData.split('base64,')[1];
          
//           // Decode base64 to bytes
//           final bytes = base64Decode(base64String);
          
//           // Convert bytes to SVG string
//           final svgString = utf8.decode(bytes);
          
//           setState(() {
//             _svgContent = svgString;
//             _hasQrCode = true;
//           });
//         } else {
//           setState(() {
//             _errorMessage = 'Invalid QR format';
//           });
//         }
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'Error processing QR';
//         });
//       }
//     }
//   }

//   Future<void> _loadCountryName() async {
//     if (widget.cardData['country_id'] != null) {
//       try {
//         final countryName = await CountryService.getCountryName(widget.cardData['country_id']);
//         if (mounted) {
//           setState(() {
//             _countryName = countryName;
//             _isLoadingCountry = false;
//           });
//         }
//       } catch (e) {
//         if (mounted) {
//           setState(() {
//             _countryName = 'Unknown';
//             _isLoadingCountry = false;
//           });
//         }
//       }
//     } else {
//       setState(() {
//         _countryName = 'Not specified';
//         _isLoadingCountry = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final cardWidth = screenWidth - 32;
        
//         return Container(
//           width: cardWidth,
//           margin: const EdgeInsets.symmetric(vertical: 16.0),
//           child: Card(
//             elevation: 8.0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16.0),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(20.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16.0),
//                 color: Colors.white,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildProfileSection(cardWidth),
                  
//                   const SizedBox(height: 16),
//                   const Divider(height: 1),
//                   const SizedBox(height: 16),
                  
//                   _buildDetailsSection(cardWidth),
                  
//                   const SizedBox(height: 16),
//                   const Divider(height: 1),
//                   const SizedBox(height: 16),
                  
//                   _buildValiditySection(),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfileSection(double availableWidth) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         widget.cardData['photo_url'] != null
//             ? CircleAvatar(
//                 radius: 35,
//                 backgroundImage: NetworkImage(widget.cardData['photo_url']),
//               )
//             : CircleAvatar(
//                 radius: 35,
//                 backgroundColor: Colors.grey[200],
//                 child: Icon(
//                   Icons.person,
//                   size: 35,
//                   color: Colors.grey[400],
//                 ),
//               ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.cardData['name'] ?? 'User Name',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF111213),
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.email,
//                     size: 14,
//                     color: Colors.grey[700],
//                   ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       widget.cardData['email'] ?? 'email@example.com',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.grey[700],
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.card_membership,
//                     size: 14,
//                     color: Colors.grey[700],
//                   ),
//                   const SizedBox(width: 4),
//                   Flexible(
//                     child: Text(
//                       _membershipTypeName ?? 'Membership Type',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.grey[700],
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 6,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: widget.cardData['status'] == 1 ? Colors.green : Colors.orange,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       widget.cardData['status'] == 1 ? 'Active' : 'Inactive',
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.location_on,
//                     size: 14,
//                     color: Colors.grey[700],
//                   ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       widget.cardData['address'] ?? 'No address',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.grey[700],
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailsSection(double availableWidth) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 65,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildInfoRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '10000002'),
//               const SizedBox(height: 12),
//               _buildInfoRow('D.O.B:', _formatDate(widget.cardData['dob']) ?? '01 Jan. 1970'),
//               const SizedBox(height: 12),
//               _buildNationalityRow(
//                 _isLoadingCountry ? 'Loading...' : _countryName
//               ),
//             ],
//           ),
//         ),
        
//         Expanded(
//           flex: 35,
//           child: _buildQrCode(),
//         ),
//       ],
//     );
//   }

//   Widget _buildValiditySection() {
//     final startDate = _formatDate(widget.cardData['start_date']);
//     final expiryDate = _formatDate(widget.cardData['expiry_date']);
//     final isLifetime = widget.cardData['is_lifetime'] == 1;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Membership Validity:',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF111213),
//           ),
//         ),
//         const SizedBox(height: 8),
        
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Start Date:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF111213),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       startDate ?? 'Not specified',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Color(0xFF111213),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Expiry Date:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF111213),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8),
//                       border: isLifetime ? Border.all(color: Colors.green, width: 1.5) : null,
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             isLifetime ? 'Lifetime' : (expiryDate ?? 'Not specified'),
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               color: isLifetime ? Colors.green : Color(0xFF111213),
//                               fontWeight: isLifetime ? FontWeight.bold : FontWeight.normal,
//                             ),
//                           ),
//                         ),
//                         if (isLifetime)
//                           Icon(
//                             Icons.check_circle_outline,
//                             color: Colors.green,
//                             size: 16,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 65,
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               color: Color(0xFF111213),
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Color(0xFF111213),
//             ),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNationalityRow(String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Nationality:',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//             color: Color(0xFF111213),
//           ),
//         ),
//         const SizedBox(width: 4),
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQrCode() {
//     return Container(
//       height: 110,
//       width: 110,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: _hasQrCode && _svgContent != null
//             ? SvgPicture.string(
//                 _svgContent!,
//                 fit: BoxFit.contain,
//               )
//             : Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.qr_code_2,
//                       size: 40,
//                       color: Colors.grey[400],
//                     ),
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Text(
//                           'Error loading QR',
//                           style: GoogleFonts.poppins(
//                             fontSize: 9,
//                             color: Colors.red[300],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   String? _formatDate(String? dateString) {
//     if (dateString == null) return null;
//     try {
//       final date = DateTime.parse(dateString);
//       final day = date.day.toString().padLeft(2, '0');
//       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//       final month = months[date.month - 1];
//       final year = date.year.toString();
//       return '$day $month. $year';
//     } catch (e) {
//       return dateString;
//     }
//   }
// }













// import 'dart:convert';
// import 'dart:developer' as developer;
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:ems/services/country_service.dart';

// class MembershipCardDisplay extends StatefulWidget {
//   final Map<String, dynamic> cardData;
//   final List<Map<String, dynamic>>? membershipTypes;

//   const MembershipCardDisplay({
//     Key? key, 
//     required this.cardData,
//     this.membershipTypes,
//   }) : super(key: key);

//   @override
//   State<MembershipCardDisplay> createState() => _MembershipCardDisplayState();
// }

// class _MembershipCardDisplayState extends State<MembershipCardDisplay> {
//   String _countryName = 'Loading...';
//   bool _isLoadingCountry = true;
//   bool _hasQrCode = false;
//   String? _svgContent;
//   String _errorMessage = '';
//   String? _membershipTypeName;
  
//   @override
//   void initState() {
//     super.initState();
//     _loadCountryName();
//     _processQrCode();
//     _getMembershipTypeName();
//   }
  
//   void _getMembershipTypeName() {
//     // Get card type id from card data
//     final cardTypeId = widget.cardData['card_type_id'];
    
//     if (cardTypeId != null && widget.membershipTypes != null) {
//       for (final type in widget.membershipTypes!) {
//         if (type['id'] == cardTypeId) {
//           setState(() {
//             _membershipTypeName = type['type'];
//           });
//           return;
//         }
//       }
//     }
    
//     // If we can't find the type or there are no types, use a default value
//     setState(() {
//       _membershipTypeName = widget.cardData['is_lifetime'] == 1 ? 'Lifetime' : 'Regular';
//     });
//   }
  
//   void _processQrCode() {
//     // Debug what data we have
//     developer.log('Processing card data with keys: ${widget.cardData.keys.join(", ")}');
    
//     if (widget.cardData.containsKey('qr_code')) {
//       try {
//         final qrCodeData = widget.cardData['qr_code'].toString();
//         developer.log('QR code data found: ${qrCodeData.substring(0, 50)}...');
        
//         if (qrCodeData.startsWith('data:image/svg+xml;base64,')) {
//           // Extract base64 part
//           final base64String = qrCodeData.split('base64,')[1];
          
//           // Decode base64 to bytes
//           final bytes = base64Decode(base64String);
          
//           // Convert bytes to SVG string
//           final svgString = utf8.decode(bytes);
          
//           setState(() {
//             _svgContent = svgString;
//             _hasQrCode = true;
//           });
          
//           developer.log('SVG content extracted successfully');
//         } else {
//           setState(() {
//             _errorMessage = 'Invalid QR format';
//           });
//           developer.log('QR code is not in expected SVG format');
//         }
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'Error: ${e.toString()}';
//         });
//         developer.log('Error processing QR code: $e');
//       }
//     } else {
//       developer.log('No qr_code field found in card data');
//     }
//   }

//   Future<void> _loadCountryName() async {
//     if (widget.cardData['country_id'] != null) {
//       try {
//         final countryName = await CountryService.getCountryName(widget.cardData['country_id']);
//         if (mounted) {
//           setState(() {
//             _countryName = countryName;
//             _isLoadingCountry = false;
//           });
//         }
//       } catch (e) {
//         debugPrint('Error loading country name: $e');
//         if (mounted) {
//           setState(() {
//             _countryName = 'Unknown';
//             _isLoadingCountry = false;
//           });
//         }
//       }
//     } else {
//       setState(() {
//         _countryName = 'Not specified';
//         _isLoadingCountry = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final cardWidth = screenWidth - 32;
        
//         return Container(
//           width: cardWidth,
//           margin: const EdgeInsets.symmetric(vertical: 16.0),
//           child: Card(
//             elevation: 8.0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16.0),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(20.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16.0),
//                 color: Colors.white,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Top section with profile and details
//                   _buildProfileSection(cardWidth),
                  
//                   const SizedBox(height: 16),
//                   const Divider(height: 1),
//                   const SizedBox(height: 16),
                  
//                   // Bottom section with details and QR code
//                   _buildDetailsSection(cardWidth),
                  
//                   const SizedBox(height: 16),
//                   const Divider(height: 1),
//                   const SizedBox(height: 16),
                  
//                   // Membership validity section
//                   _buildValiditySection(),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfileSection(double availableWidth) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         widget.cardData['photo_url'] != null
//             ? CircleAvatar(
//                 radius: 35,
//                 backgroundImage: NetworkImage(widget.cardData['photo_url']),
//               )
//             : CircleAvatar(
//                 radius: 35,
//                 backgroundColor: Colors.grey[200],
//                 child: Icon(
//                   Icons.person,
//                   size: 35,
//                   color: Colors.grey[400],
//                 ),
//               ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.cardData['name'] ?? 'User Name',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.email,
//                     size: 14,
//                     color: Colors.grey[700],
//                   ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       widget.cardData['email'] ?? 'email@example.com',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.grey[700],
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.card_membership,  // Changed icon to be appropriate for membership type
//                     size: 14,
//                     color: Colors.grey[700],
//                   ),
//                   const SizedBox(width: 4),
//                   Flexible(
//                     child: Text(
//                       _membershipTypeName ?? 'Membership Type',  // Display membership type instead of address
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.grey[700],
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 6,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: widget.cardData['status'] == 1 ? Colors.green : Colors.orange,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       widget.cardData['status'] == 1 ? 'Active' : 'Inactive',
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               // Show address as well since it's useful information
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.location_on,
//                     size: 14,
//                     color: Colors.grey[700],
//                   ),
//                   const SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       widget.cardData['address'] ?? 'No address',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.grey[700],
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailsSection(double availableWidth) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 65,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildInfoRow('ID:', widget.cardData['qr_code_no']?.toString() ?? '10000002'),
//               const SizedBox(height: 12),
//               _buildInfoRow('D.O.B:', _formatDate(widget.cardData['dob']) ?? '01 Jan. 1970'),
//               const SizedBox(height: 12),
//               _buildNationalityRow(
//                 _isLoadingCountry ? 'Loading...' : _countryName
//               ),
//             ],
//           ),
//         ),
        
//         Expanded(
//           flex: 35,
//           child: _buildQrCode(),
//         ),
//       ],
//     );
//   }

//   Widget _buildValiditySection() {
//     final startDate = _formatDate(widget.cardData['start_date']);
//     final expiryDate = _formatDate(widget.cardData['expiry_date']);
//     final isLifetime = widget.cardData['is_lifetime'] == 1;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Membership Validity:',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
        
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Start Date:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       startDate ?? 'Not specified',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Expiry Date:',
//                     style: GoogleFonts.poppins(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(8),
//                       border: isLifetime ? Border.all(color: Colors.green, width: 1.5) : null,
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             isLifetime ? 'Lifetime' : (expiryDate ?? 'Not specified'),
//                             style: GoogleFonts.poppins(
//                               fontSize: 14,
//                               color: isLifetime ? Colors.green : Colors.black87,
//                               fontWeight: isLifetime ? FontWeight.bold : FontWeight.normal,
//                             ),
//                           ),
//                         ),
//                         if (isLifetime)
//                           Icon(
//                             Icons.check_circle_outline,
//                             color: Colors.green,
//                             size: 16,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 65,
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNationalityRow(String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Nationality:',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(width: 4),
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQrCode() {
//     return Container(
//       height: 110,
//       width: 110,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: _hasQrCode && _svgContent != null
//             ? SvgPicture.string(
//                 _svgContent!,
//                 fit: BoxFit.contain,
//               )
//             : Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.qr_code_2,
//                       size: 40,
//                       color: Colors.grey[400],
//                     ),
//                     if (_errorMessage.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Text(
//                           'Error loading QR',
//                           style: GoogleFonts.poppins(
//                             fontSize: 9,
//                             color: Colors.red[300],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   String? _formatDate(String? dateString) {
//     if (dateString == null) return null;
//     try {
//       final date = DateTime.parse(dateString);
//       final day = date.day.toString().padLeft(2, '0');
//       final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//       final month = months[date.month - 1];
//       final year = date.year.toString();
//       return '$day $month. $year';
//     } catch (e) {
//       return dateString;
//     }
//   }
// }


