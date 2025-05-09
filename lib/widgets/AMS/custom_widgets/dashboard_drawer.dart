import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardDrawer extends StatelessWidget {
  final String selectedItem;
  final Function(String) onItemSelected;

  const DashboardDrawer({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  // Helper method to check if any subsection is selected
  bool _isAnySubsectionSelected(List<String> subsections) {
    return subsections.contains(selectedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF205EB5),
      child: Column(
        children: [
          const SizedBox(height: 80),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildExpansionTile(
                  context,
                  'Dashboard',
                  Icons.dashboard,
                  [
                    _buildSubListTile(context, 'General', Icons.person),
                    _buildSubListTile(context, 'Attendance', Icons.calendar_today),
                    _buildSubListTile(context, 'Quiz', Icons.quiz),
                    _buildSubListTile(context, 'Career', Icons.work),
                  ],
                  ['General', 'Attendance', 'Quiz', 'Career'],
                ),
                 _buildListTile(context, 'Membership Card', Icons.card_membership_outlined),
                _buildListTile(context, 'Materials', Icons.library_books),
                _buildListTile(context, 'Zoom Links', Icons.videocam),
                _buildExpansionTile(
                  context,
                  'Tickets',
                  Icons.confirmation_number,
                  [
                    _buildSubListTile(context, 'Create Ticket', Icons.add_circle_outline),
                    _buildSubListTile(context, 'All Tickets', Icons.list_alt),
                    _buildSubListTile(context, 'Completed Tickets', Icons.check_circle_outline),
                  ],
                  ['Create Ticket', 'All Tickets', 'Completed Tickets'],
                ),
                _buildListTile(context, 'Logout', Icons.logout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, 
    String title, 
    IconData icon, 
    List<Widget> children,
    List<String> subsections,
  ) {
    bool isExpanded = _isAnySubsectionSelected(subsections);
    
    return ExpansionTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Color(0xFF205EB5),
      collapsedIconColor: Colors.white,
      iconColor: Colors.white,
      initiallyExpanded: isExpanded,
      children: children,
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon) {
    bool isSelected = selectedItem == title;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isSelected ? Colors.white : Color(0xFF205EB5),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Color(0xFF205EB5) : Colors.white,
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? Color(0xFF205EB5) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          onItemSelected(title);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildSubListTile(BuildContext context, String title, IconData icon) {
    bool isSelected = selectedItem == title;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isSelected ? Colors.blue[50] : Color(0xFF205EB5),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Color(0xFF205EB5) : Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? Color(0xFF205EB5) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: () {
          onItemSelected(title);
          Navigator.pop(context);
        },
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DashboardDrawer extends StatelessWidget {
//   final String selectedItem;
//   final Function(String) onItemSelected;

//   const DashboardDrawer({
//     super.key,
//     required this.selectedItem,
//     required this.onItemSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: Colors.blue,
//       child: Column(
//         children: [
//           const SizedBox(height: 80),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 _buildExpansionTile(
//                   context,
//                   'Dashboard',
//                   Icons.dashboard,
//                   [
//                     _buildSubListTile(context, 'General', Icons.person),
//                     _buildSubListTile(context, 'Attendance', Icons.calendar_today),
//                     _buildSubListTile(context, 'Quiz', Icons.quiz),
//                     _buildSubListTile(context, 'Career', Icons.work),
//                   ],
//                 ),
//                 _buildListTile(context, 'Materials', Icons.library_books),
//                 _buildListTile(context, 'Zoom Links', Icons.videocam),
//                 _buildExpansionTile(
//                   context,
//                   'Tickets',
//                   Icons.confirmation_number,
//                   [
//                     _buildSubListTile(context, 'Create Ticket', Icons.add_circle_outline),
//                     _buildSubListTile(context, 'All Tickets', Icons.list_alt),
//                     _buildSubListTile(context, 'Completed Tickets', Icons.check_circle_outline),
//                   ],
//                 ),
//                 _buildListTile(context, 'Logout', Icons.logout),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExpansionTile(BuildContext context, String title, IconData icon, List<Widget> children) {
//     return ExpansionTile(
//       leading: Icon(icon, color: Colors.white),
//       title: Text(
//         title,
//         style: GoogleFonts.inter(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       backgroundColor: selectedItem == title ? Colors.white : Colors.blue,
//       collapsedIconColor: Colors.white,
//       iconColor: selectedItem == title ? Colors.blue : Colors.white,
//       children: children,
//     );
//   }

//   Widget _buildListTile(BuildContext context, String title, IconData icon) {
//     bool isSelected = selectedItem == title;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       color: isSelected ? Colors.white : Colors.blue,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//         ),
//         title: Text(
//           title,
//           style: GoogleFonts.inter(
//             color: isSelected ? Colors.blue : Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         onTap: () {
//           onItemSelected(title);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }

//   Widget _buildSubListTile(BuildContext context, String title, IconData icon) {
//     bool isSelected = selectedItem == title;
    
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       color: isSelected ? Colors.blue[50] : Colors.blue,
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.white,
//           size: 24,
//         ),
//         title: Text(
//           title,
//           style: GoogleFonts.inter(
//             color: isSelected ? Colors.blue : Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         onTap: () {
//           onItemSelected(title);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
// }