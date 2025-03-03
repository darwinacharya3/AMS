import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/widgets/custom_back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData icon;
  final bool showBackButton;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.icon = Icons.person,
    this.showBackButton = true,  // Default to true, can be disabled when needed
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton ? const CustomBackButton() : null,
      title: Row(
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 227, 10, 169),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 227, 10, 169),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  size: 32,
                  color: Colors.black,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}









// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final IconData icon;
  
//   const CustomAppBar({
//     Key? key,
//     required this.title,
//     this.icon = Icons.person,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Row(
//         children: [
//           Icon(
//             icon,
//             color: const Color.fromARGB(255, 227, 10, 169),
//             size: 24,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               color: const Color.fromARGB(255, 227, 10, 169),
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       actions: [
//         Builder(
//           builder: (context) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.menu,
//                   size: 32,
//                   color: Colors.black,
//                 ),
//                 onPressed: () {
//                   Scaffold.of(context).openEndDrawer();
//                 },
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

