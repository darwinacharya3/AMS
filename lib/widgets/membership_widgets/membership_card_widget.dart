import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';

class MembershipCardDisplay extends StatelessWidget {
  final Map<String, dynamic> cardData;

  const MembershipCardDisplay({Key? key, required this.cardData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile image
                  cardData['photo_url'] != null
                      ? CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(cardData['photo_url']),
                        )
                      : CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                  const SizedBox(width: 16),
                  // User details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardData['name'] ?? 'User Name',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                cardData['email'] ?? 'email@example.com',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[700],
                                  fontSize: 12,
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
                              Icons.business,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                cardData['address'] ?? 'Institution',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cardData['status'] == 1 ? 'Active' : 'Inactive',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              
              // Card details section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column - Info fields
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildInfoRow('ID:', cardData['qr_code_no']?.toString() ?? '10000002'),
                          const SizedBox(height: 12),
                          _buildInfoRow('D.O.B:', _formatDate(cardData['dob']) ?? '01 Jan. 1970'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Nationality:', _getCountryName(cardData['country_id']) ?? 'Nepal'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Start Date:', _formatDate(cardData['start_date']) ?? '01 Jan. 2025'),
                          const SizedBox(height: 12),
                          _buildInfoRow('Expiry Date:', _formatDate(cardData['expiry_date']) ?? '01 Jan. 2030'),
                        ],
                      ),
                    ),
                    
                    // Right column - QR code
                    Expanded(
                      flex: 4,
                      child: cardData['qr_code'] != null
                          ? Image.memory(
                              base64DecodeImage(cardData['qr_code']),
                              height: 130,
                              width: 130,
                            )
                          : QrImageView(
                              data: 'Membership ID: ${cardData['qr_code_no'] ?? '10000002'}',
                              version: QrVersions.auto,
                              size: 130.0,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  // Helper function to format date from API
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
  
//   // Helper function to get country name from country_id
//   String? _getCountryName(int? countryId) {
//     // This is a simplified approach - ideally you would have a map of country IDs to names
//     // For now, just hardcoding Nepal for ID 157 as seen in your API response
//     if (countryId == 157) {
//       return 'Nepal';
//     }
//     return 'Nepal'; // Default to Nepal as shown in screenshots
//   }
// }

// Helper function to get country name from country_id
String? _getCountryName(int? countryId) {
  // Debug: Print the entire cardData to see what's available
  print('Card Data: $cardData');
  
  // Check if there's a country object or name in the response
  if (cardData.containsKey('country') && cardData['country'] != null) {
    return cardData['country']['name'] ?? 'Unknown';
  } else if (cardData.containsKey('country_name')) {
    return cardData['country_name'];
  }
  
  // Fallback: Return the country ID as a string
  return 'Country ID: ${countryId ?? 'Unknown'}';
}
}

// Improved base64 decode function for handling different types of base64 data
Uint8List base64DecodeImage(String source) {
  try {
    if (source.contains('base64,')) {
      // Handle data URI format (data:image/svg+xml;base64,...)
      return base64Decode(source.split('base64,')[1].trim().replaceAll('\n', ''));
    }
    return base64Decode(source.trim().replaceAll('\n', ''));
  } catch (e) {
    print('Error decoding base64 image: $e');
    // Return a minimal 1x1 transparent image as fallback
    return base64Decode('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7');
  }
}















// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// // import 'package:intl/intl.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class MembershipCardDisplay extends StatelessWidget {
//   final Map<String, dynamic> cardData;

//   const MembershipCardDisplay({Key? key, required this.cardData}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16.0),
//       child: Card(
//         elevation: 8.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(24.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16.0),
//             color: Colors.white,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Profile image placeholder
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.grey[200],
//                     child: Icon(
//                       Icons.person,
//                       size: 40,
//                       color: Colors.grey[400],
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   // User details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           cardData['student_name'] ?? 'User Name',
//                           style: GoogleFonts.poppins(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.email,
//                               size: 16,
//                               color: Colors.grey[700],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               cardData['email'] ?? 'email@example.com',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.business,
//                               size: 16,
//                               color: Colors.grey[700],
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               cardData['institution'] ?? 'Institution',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.green,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 cardData['status'] == 1 ? 'Active' : 'Inactive',
//                                 style: GoogleFonts.poppins(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 20),
//               const Divider(),
              
//               // ID, DOB, Nationality info
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: 6,
//                       child: Column(
//                         children: [
//                           _buildInfoRow('ID:', cardData['card_id'] ?? '10000002'),
//                           const SizedBox(height: 16),
//                           _buildInfoRow('D.O.B:', cardData['dob'] ?? '01 Jan. 1970'),
//                           const SizedBox(height: 16),
//                           _buildInfoRow('Nationality:', cardData['country'] ?? 'Nepal'),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       flex: 4,
//                       child: cardData['qr_code'] != null
//                           ? Image.memory(
//                               base64Decode(cardData['qr_code']),
//                               height: 120,
//                               width: 120,
//                             )
//                           : QrImageView(
//                               data: 'Membership ID: ${cardData['card_id'] ?? '10000002'}',
//                               version: QrVersions.auto,
//                               size: 120.0,
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: 120,
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Helper function to decode base64 image
// base64Decode(String source) {
//   return const Base64Decoder().convert(source.replaceAll('\n', ''));
// }


















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// class MembershipCardDisplay extends StatelessWidget {
//   final Map<String, dynamic> cardData;

//   const MembershipCardDisplay({Key? key, required this.cardData}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Calculate expiry date (assuming 1 year validity)
//     DateTime issueDate = DateTime.parse(cardData['issueDate']);
//     DateTime expiryDate = DateTime(issueDate.year + 1, issueDate.month, issueDate.day);
    
//     return Container(
//       margin: const EdgeInsets.all(16.0),
//       child: Card(
//         elevation: 8.0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(24.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16.0),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.deepPurple[700]!,
//                 Colors.deepPurple[500]!,
//               ],
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'MEMBERSHIP CARD',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Icon(
//                     Icons.card_membership,
//                     color: Colors.white,
//                     size: 36,
//                   ),
//                 ],
//               ),
//               const Divider(color: Colors.white54),
//               const SizedBox(height: 8),
//               Text(
//                 cardData['studentName'],
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Card ID: ${cardData['cardId']}',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white70,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   _buildInfoItem('Type', cardData['membershipType']),
//                   const SizedBox(width: 24),
//                   _buildInfoItem('Status', cardData['status']),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   _buildInfoItem(
//                     'Issue Date',
//                     DateFormat('dd MMM yyyy').format(issueDate),
//                   ),
//                   const SizedBox(width: 24),
//                   _buildInfoItem(
//                     'Expiry Date',
//                     DateFormat('dd MMM yyyy').format(expiryDate),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 8.0,
//                   horizontal: 16.0,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20.0),
//                 ),
//                 child: Text(
//                   'Valid Member',
//                   style: GoogleFonts.poppins(
//                     color: Colors.deepPurple[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoItem(String label, String value) {
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               color: Colors.white70,
//               fontSize: 12,
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }













// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:intl/intl.dart';

// // class MembershipCardDisplay extends StatelessWidget {
// //   final Map<String, dynamic> cardData;

// //   const MembershipCardDisplay({Key? key, required this.cardData}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     // Calculate expiry date (assuming 1 year validity)
// //     DateTime issueDate = DateTime.parse(cardData['issueDate']);
// //     DateTime expiryDate = DateTime(issueDate.year + 1, issueDate.month, issueDate.day);
    
// //     return Container(
// //       margin: const EdgeInsets.all(16.0),
// //       child: Card(
// //         elevation: 8.0,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16.0),
// //         ),
// //         child: Container(
// //           padding: const EdgeInsets.all(24.0),
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(16.0),
// //             gradient: LinearGradient(
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //               colors: [
// //                 Theme.of(context).primaryColor,
// //                 Theme.of(context).primaryColor.withOpacity(0.7),
// //               ],
// //             ),
// //           ),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'MEMBERSHIP CARD',
// //                     style: GoogleFonts.poppins(
// //                       color: Colors.white,
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const Icon(
// //                     Icons.card_membership,
// //                     color: Colors.white,
// //                     size: 36,
// //                   ),
// //                 ],
// //               ),
// //               const Divider(color: Colors.white54),
// //               const SizedBox(height: 8),
// //               Text(
// //                 cardData['studentName'],
// //                 style: GoogleFonts.poppins(
// //                   color: Colors.white,
// //                   fontSize: 22,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(height: 4),
// //               Text(
// //                 'Card ID: ${cardData['cardId']}',
// //                 style: GoogleFonts.poppins(
// //                   color: Colors.white70,
// //                   fontSize: 14,
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //               Row(
// //                 children: [
// //                   _buildInfoItem('Type', cardData['membershipType']),
// //                   const SizedBox(width: 24),
// //                   _buildInfoItem('Status', cardData['status']),
// //                 ],
// //               ),
// //               const SizedBox(height: 16),
// //               Row(
// //                 children: [
// //                   _buildInfoItem(
// //                     'Issue Date',
// //                     DateFormat('dd MMM yyyy').format(issueDate),
// //                   ),
// //                   const SizedBox(width: 24),
// //                   _buildInfoItem(
// //                     'Expiry Date',
// //                     DateFormat('dd MMM yyyy').format(expiryDate),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 24),
// //               Container(
// //                 padding: const EdgeInsets.symmetric(
// //                   vertical: 8.0,
// //                   horizontal: 16.0,
// //                 ),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(8.0),
// //                 ),
// //                 child: Text(
// //                   'Valid Member',
// //                   style: GoogleFonts.poppins(
// //                     color: Theme.of(context).primaryColor,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildInfoItem(String label, String value) {
// //     return Expanded(
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             label,
// //             style: GoogleFonts.poppins(
// //               color: Colors.white70,
// //               fontSize: 12,
// //             ),
// //           ),
// //           Text(
// //             value,
// //             style: GoogleFonts.poppins(
// //               color: Colors.white,
// //               fontSize: 16,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }