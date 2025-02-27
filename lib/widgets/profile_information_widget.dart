import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/user_detail.dart';

class ProfileInformationWidget extends StatelessWidget {
  final UserDetail userDetail;
  static const String baseImageUrl = 'https://extratech.extratechweb.com';
  
  const ProfileInformationWidget({
    Key? key,
    required this.userDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(),
          _buildTimeSlotInfo(),
          _buildActionButtons(),
          _buildPersonalInformation(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              // Fix image URL construction
              userDetail.image.startsWith('http') 
                  ? userDetail.image
                  : '$baseImageUrl/${userDetail.image.replaceAll(RegExp('^/'), '')}',
            ),
            // Add error handling for image loading
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Error loading profile image: $exception');
            },
            child: userDetail.image.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userDetail.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  userDetail.etId,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${userDetail.batchOtherName}]',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // Text(
                //   'Tue-Wed 18:00:00 21:00:00',  // From time_slot_id mapping
                //   style: GoogleFonts.poppins(
                //     fontSize: 14,
                //     color: Colors.grey[600],
                //   ),
                // ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Start | Added On',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 227, 10, 169),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userDetail.commencementDate,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Download Profile functionality to be implemented
              },
              icon: const Icon(Icons.download, color: Color.fromARGB(255, 227, 10, 169)),
              label: Text(
                'Download Profile',
                style: GoogleFonts.poppins(color: const Color.fromARGB(255, 227, 10, 169)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Edit functionality to be implemented
              },
              icon: const Icon(Icons.edit, color: Color.fromARGB(255, 227, 10, 169)),
              label: Text(
                'Edit',
                style: GoogleFonts.poppins(color: const Color.fromARGB(255, 227, 10, 169)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('General Settings'),
          _buildSubHeader('Student personal information'),
          _buildInfoRow(Icons.person, 'Name', userDetail.name),
          _buildInfoRow(Icons.person_outline, 'Gender', userDetail.gender == '1' ? 'Male' : 'Female'),
          _buildInfoRow(Icons.phone, 'Phone', userDetail.mobileNo),
          _buildInfoRow(Icons.email, 'Email', userDetail.email),
          _buildInfoRow(Icons.calendar_today, 'Date of Birth', userDetail.dob),
          _buildInfoRow(Icons.flag, 'Birth Country', 'Nepal'), // This should be mapped from country ID
          _buildInfoRow(Icons.location_city, 'State', 'Gandaki'), // This should be mapped from state ID
          _buildInfoRow(Icons.home, 'Home Country Address', userDetail.birthResidentialAddress),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color.fromARGB(255, 227, 10, 169),
          fontWeight: FontWeight.w500,
        ),
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
            color: const Color.fromARGB(255, 227, 10, 169),
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
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

// class ProfileInformationWidget extends StatelessWidget {
//   final UserDetail userDetail;
//   static const String baseImageUrl = 'https://extratech.extratechweb.com/';
  
//   const ProfileInformationWidget({
//     Key? key,
//     required this.userDetail,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildProfileHeader(),
//           _buildTimeSlotInfo(),
//           _buildActionButtons(),
//           _buildPersonalInformation(),
          
//         ],
//       ),
//     );
//   }

//    Widget _buildProfileHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundImage: NetworkImage(
//               '$baseImageUrl${userDetail.image}',
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   userDetail.name,
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),

//                 Text(
//                   userDetail.etId,
//                    style: GoogleFonts.poppins(
//                     fontSize: 14,
                    
//                   ),
//                 ),
                
//               ],
              
//             ),
//           ),
//         ],
//       ),
//     );
//   }




//     Widget _buildTimeSlotInfo() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '[${userDetail.batchOtherName}]',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 // Text(
//                 //   'Tue-Wed 18:00:00 21:00:00',  // From time_slot_id mapping
//                 //   style: GoogleFonts.poppins(
//                 //     fontSize: 14,
//                 //     color: Colors.grey[600],
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 'Start | Added On',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: const Color.fromARGB(255, 227, 10, 169),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 userDetail.commencementDate,
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Expanded(
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 // Download Profile functionality to be implemented
//               },
//               icon: const Icon(Icons.download, color:  Color.fromARGB(255, 227, 10, 169),),
//               label: Text(
//                 'Download Profile',
//                 style: GoogleFonts.poppins(color: const Color.fromARGB(255, 227, 10, 169),),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 side: const BorderSide(color:  Color.fromARGB(255, 227, 10, 169),),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 // Edit functionality to be implemented
//               },
//               icon: const Icon(Icons.edit,color:  Color.fromARGB(255, 227, 10, 169),),
//               label: Text(
//                 'Edit',
//                 style: GoogleFonts.poppins(color: const Color.fromARGB(255, 227, 10, 169),),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 side: const BorderSide(color:  Color.fromARGB(255, 227, 10, 169),),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPersonalInformation() {
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
//           _buildSectionHeader('General Settings'),
//           _buildSubHeader('Student personal information'),
//           _buildInfoRow(Icons.person, 'Name', userDetail.name),
//           _buildInfoRow(Icons.person_outline, 'Gender', userDetail.gender == '1' ? 'Male' : 'Female'),
//           _buildInfoRow(Icons.phone, 'Phone', userDetail.mobileNo),
//           _buildInfoRow(Icons.email, 'Email', userDetail.email),
//           _buildInfoRow(Icons.calendar_today, 'Date of Birth', userDetail.dob),
//           _buildInfoRow(Icons.flag, 'Birth Country', 'Nepal'), // This should be mapped from country ID
//           _buildInfoRow(Icons.location_city, 'State', 'Gandaki'), // This should be mapped from state ID
//           _buildInfoRow(Icons.home, 'Home Country Address', userDetail.birthResidentialAddress),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildSubHeader(String title) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       color: Colors.blue[50],
//       child: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           color: const Color.fromARGB(255, 227, 10, 169),
//           fontWeight: FontWeight.w500,
//         ),
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
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
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


