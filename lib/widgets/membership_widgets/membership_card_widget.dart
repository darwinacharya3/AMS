import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MembershipCardDisplay extends StatelessWidget {
  final Map<String, dynamic> cardData;

  const MembershipCardDisplay({Key? key, required this.cardData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate expiry date (assuming 1 year validity)
    DateTime issueDate = DateTime.parse(cardData['issueDate']);
    DateTime expiryDate = DateTime(issueDate.year + 1, issueDate.month, issueDate.day);
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple[700]!,
                Colors.deepPurple[500]!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MEMBERSHIP CARD',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.card_membership,
                    color: Colors.white,
                    size: 36,
                  ),
                ],
              ),
              const Divider(color: Colors.white54),
              const SizedBox(height: 8),
              Text(
                cardData['studentName'],
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Card ID: ${cardData['cardId']}',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildInfoItem('Type', cardData['membershipType']),
                  const SizedBox(width: 24),
                  _buildInfoItem('Status', cardData['status']),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoItem(
                    'Issue Date',
                    DateFormat('dd MMM yyyy').format(issueDate),
                  ),
                  const SizedBox(width: 24),
                  _buildInfoItem(
                    'Expiry Date',
                    DateFormat('dd MMM yyyy').format(expiryDate),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'Valid Member',
                  style: GoogleFonts.poppins(
                    color: Colors.deepPurple[700],
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

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}













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
//                 Theme.of(context).primaryColor,
//                 Theme.of(context).primaryColor.withOpacity(0.7),
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
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: Text(
//                   'Valid Member',
//                   style: GoogleFonts.poppins(
//                     color: Theme.of(context).primaryColor,
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