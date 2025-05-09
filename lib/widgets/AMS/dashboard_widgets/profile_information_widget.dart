import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/user_detail.dart';
import 'package:ems/screens/AMS/home/edit_profile_information.dart'; // Add this import

class ProfileInformationWidget extends StatelessWidget {
  final UserDetail userDetail;
  final Function? onRefresh;
  static const String baseImageUrl = 'https://extratech.extratechweb.com';
  
  const ProfileInformationWidget({
    super.key,
    required this.userDetail,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(),
          _buildTimeSlotInfo(),
          _buildActionButtons(context), // Pass context here
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
          // const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userDetail.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111213),
                  ),
                ),
                Text(
                  userDetail.etId,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFFA1A1A1),
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
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - batch information
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '[${userDetail.batchOtherName}]',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111213),
                ),
                softWrap: true, // Allow text to wrap to next line
              ),
            ],
          ),
        ),
        
        // Right side - date information
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.topRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Start | Added On',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111213),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userDetail.commencementDate,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFA1A1A1),
                  ),
                  softWrap: true, // Allow text to wrap to next line
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  // Updated to accept BuildContext parameter
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Download Profile functionality to be implemented
              },
              icon: const Icon(Icons.download, color: Color(0xFF205EB5),),
              label: Text(
                'Download Profile',
                style: GoogleFonts.poppins(color: const Color(0xFF205EB5),),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF205EB5),),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Added Edit button with navigation to EditProfileScreen
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to the EditProfileScreen
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userDetail: userDetail),
                  ),
                ).then((result) {
                  // Refresh the profile if changes were made
                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully')),
                    );
                    
                    // Call the refresh callback if provided
                    if (onRefresh != null) {
                      onRefresh!();
                    }
                  }
                });
              },
              icon: const Icon(Icons.edit, color: Color(0xFF205EB5),),
              label: Text(
                'Edit',
                style: GoogleFonts.poppins(color: Color(0xFF205EB5),),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF205EB5),),
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
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA1A1A1).withOpacity(0.25),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('General Information'),
          _buildSubHeader('Personal Details'),
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
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF111213)
        ),
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      // color: Colors.blue[50],
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Color(0xFF205EB5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF205EB5),
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Color(0xFFA1A1A1),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color : const Color(0xFF111213)
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
// // import 'package:ems/screens/AMS/home/edit_profile_information.dart';

// class ProfileInformationWidget extends StatelessWidget {
//   final UserDetail userDetail;
//   static const String baseImageUrl = 'https://extratech.extratechweb.com';
  
//   const ProfileInformationWidget({
//     super.key,
//     required this.userDetail,
//   });

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

//   Widget _buildProfileHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundImage: NetworkImage(
//               // Fix image URL construction
//               userDetail.image.startsWith('http') 
//                   ? userDetail.image
//                   : '$baseImageUrl/${userDetail.image.replaceAll(RegExp('^/'), '')}',
//             ),
//             // Add error handling for image loading
//             onBackgroundImageError: (exception, stackTrace) {
//               debugPrint('Error loading profile image: $exception');
//             },
//             child: userDetail.image.isEmpty
//                 ? const Icon(Icons.person, size: 30, color: Colors.white)
//                 : null,
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
//                   style: GoogleFonts.poppins(
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

//   Widget _buildTimeSlotInfo() {
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
//               icon: const Icon(Icons.download, color: Color.fromARGB(255, 227, 10, 169)),
//               label: Text(
//                 'Download Profile',
//                 style: GoogleFonts.poppins(color: const Color.fromARGB(255, 227, 10, 169)),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 side: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           // Inside the _buildActionButtons() method, update the Edit button:


//           // Expanded(
//           //   child: ElevatedButton.icon(
//           //     onPressed: () {
//           //       // Edit functionality to be implemented
                
//           //     },
//           //     icon: const Icon(Icons.edit, color: Color.fromARGB(255, 227, 10, 169)),
//           //     label: Text(
//           //       'Edit',
//           //       style: GoogleFonts.poppins(color: const Color.fromARGB(255, 227, 10, 169)),
//           //     ),
//           //     style: ElevatedButton.styleFrom(
//           //       backgroundColor: Colors.white,
//           //       side: const BorderSide(color: Color.fromARGB(255, 227, 10, 169)),
//           //       padding: const EdgeInsets.symmetric(vertical: 12),
//           //     ),
//           //   ),
//           // ),
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


