// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:ems/screens/home/dashboard_screen.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   bool rememberMe = false;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _showAlert = true;
//   bool _isLoading = false;
//   String? _errorMessage;

//   Future<void> _signIn() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse('https://extratech.extratechweb.com/api/auth/login'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'email': _emailController.text.trim(),
//           'password': _passwordController.text,
//         }),
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (response.statusCode == 200) {
//         // Successfully logged in
//         final responseData = json.decode(response.body);
//         print('Login response: $responseData');

       

        
//         // Navigate to dashboard screen
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const DashboardScreen())
//         );
//       } else {
//         // Handle error responses
//         setState(() {
//           _errorMessage = 'Login failed. Please check your credentials.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Network error. Please try again.';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 // Logo section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 20.0),
//                   child: Image.asset(
//                     'assets/logo.png',
//                     height: 60,
//                   ),
//                 ),
                
//                 // Alert message
//                 if (_showAlert)
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 20.0),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFFDCDC),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                       child: Row(
//                         children: [
//                           Container(
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Icon(Icons.warning_outlined, color: Colors.white, size: 16),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Text(
//                               'You must be logged in to access this page.',
//                               style: TextStyle(
//                                 color: Color(0xFFD32F2F),
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _showAlert = false;
//                               });
//                             },
//                             child: const Icon(
//                               Icons.close,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
                
//                 // Display error message if there is one
//                 if (_errorMessage != null)
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 20.0),
//                     padding: const EdgeInsets.all(12.0),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.error_outline, color: Colors.red),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _errorMessage!,
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                
//                 // Sign in card
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Sign In heading
//                         const Center(
//                           child: Text(
//                             'Sign In',
//                             style: TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
                        
//                         // To continue to AMS subheading
//                         const Center(
//                           child: Padding(
//                             padding: EdgeInsets.only(top: 8.0, bottom: 32.0),
//                             child: Text(
//                               'to continue to AMS',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         ),
                        
//                         // Email field
//                         const Text(
//                           'Email',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _emailController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter your email',
//                             filled: true,
//                             fillColor: Colors.grey[100],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                         ),
//                         const SizedBox(height: 20),
                        
//                         // Password field
//                         const Text(
//                           'Password',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         TextField(
//                           controller: _passwordController,
//                           obscureText: true,
//                           decoration: InputDecoration(
//                             hintText: 'Enter your password',
//                             filled: true,
//                             fillColor: Colors.grey[100],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
                        
//                         // Forgot password
//                         GestureDetector(
//                           onTap: () {
//                             // Add forgot password navigation logic here
//                           },
//                           child: const Text(
//                             'Forgot your password?',
//                             style: TextStyle(
//                               color: Colors.blue,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
                        
//                         // Remember me checkbox
//                         Row(
//                           children: [
//                             Checkbox(
//                               value: rememberMe,
//                               onChanged: (value) {
//                                 setState(() {
//                                   rememberMe = value ?? false;
//                                 });
//                               },
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               side: const BorderSide(color: Colors.grey),
//                             ),
//                             const Text(
//                               'Remember me next time',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),
                        
//                         // Sign in button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _signIn,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF3F51B5), // Indigo/blue color from the screenshot
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                             child: _isLoading
//                                 ? const CircularProgressIndicator(color: Colors.white)
//                                 : const Text(
//                                     'Sign in',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }















// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // class SignUpScreen extends StatefulWidget {
// //   const SignUpScreen({super.key});

// //   @override
// //   _SignUpScreenState createState() => _SignUpScreenState();
// // }

// // class _SignUpScreenState extends State<SignUpScreen> {
// //   bool rememberMe = false;
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   bool _showAlert = true;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[200],
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           child: Padding(
// //             padding: const EdgeInsets.all(20.0),
// //             child: Column(
// //               children: [
// //                 // Logo section
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(vertical: 20.0),
// //                   child: Image.asset(
// //                     'assets/logo.png',
// //                     height: 60,
// //                   ),
// //                 ),
                
// //                 // Alert message
// //                 if (_showAlert)
// //                   Container(
// //                     margin: const EdgeInsets.only(bottom: 20.0),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFFFDCDC),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
// //                       child: Row(
// //                         children: [
// //                           Container(
// //                             decoration: const BoxDecoration(
// //                               color: Colors.red,
// //                               shape: BoxShape.circle,
// //                             ),
// //                             child: const Padding(
// //                               padding: EdgeInsets.all(8.0),
// //                               child: Icon(Icons.warning_outlined, color: Colors.white, size: 16),
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: Text(
// //                               'You must be logged in to access this page.',
// //                               style: GoogleFonts.poppins(
// //                                     fontSize: 16,
// //                                     color: Color(0xFFD32F2F),
// //                                   ),
                              
// //                             ),
// //                           ),
// //                           GestureDetector(
// //                             onTap: () {
// //                               setState(() {
// //                                 _showAlert = false;
// //                               });
// //                             },
// //                             child: const Icon(
// //                               Icons.close,
// //                               color: Colors.black54,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
                
// //                 // Sign in card
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(24.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         // Sign In heading
// //                         Center(
// //                           child: Text(
// //                             'Sign In',
                           
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 32,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ),
                        
// //                         // To continue to AMS subheading
// //                         Center(
// //                           child: Padding(
// //                             padding: EdgeInsets.only(top: 8.0, bottom: 32.0),
// //                             child: Text(
// //                               'to continue to AMS',
// //                               // style: TextStyle(
// //                               //   fontSize: 18,
// //                               //   color: Colors.grey,
// //                               // ),
// //                               style: GoogleFonts.poppins(
// //                                 fontSize: 18,
// //                                 color: Colors.grey,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
                        
// //                         // Email field
// //                         Text(
// //                           'Email',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         TextField(
// //                           controller: _emailController,
// //                           decoration: InputDecoration(
// //                             hintText: 'Enter your email',
// //                             filled: true,
// //                             fillColor: Colors.grey[100],
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                               borderSide: BorderSide.none,
// //                             ),
// //                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //                           ),
// //                           keyboardType: TextInputType.emailAddress,
// //                         ),
// //                         const SizedBox(height: 20),
                        
// //                         // Password field
// //                         Text(
// //                           'Password',
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         TextField(
// //                           controller: _passwordController,
// //                           obscureText: true,
// //                           decoration: InputDecoration(
// //                             hintText: 'Enter your password',
// //                             filled: true,
// //                             fillColor: Colors.grey[100],
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                               borderSide: BorderSide.none,
// //                             ),
// //                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 20),
                        
// //                         // Forgot password
// //                         GestureDetector(
// //                           onTap: () {
// //                             // Add forgot password navigation logic here
// //                           },
// //                           child:Text(
// //                             'Forgot your password?',
// //                             style: GoogleFonts.poppins(
// //                               color: Colors.blue,
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 20),
                        
// //                         // Remember me checkbox
// //                         Row(
// //                           children: [
// //                             Checkbox(
// //                               value: rememberMe,
// //                               onChanged: (value) {
// //                                 setState(() {
// //                                   rememberMe = value ?? false;
// //                                 });
// //                               },
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(4),
// //                               ),
// //                               side: const BorderSide(color: Colors.grey),
// //                             ),
// //                             Text(
// //                               'Remember me next time',
// //                               style: GoogleFonts.poppins(
// //                                 fontSize: 16,
// //                                 color: Colors.grey,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 24),
                        
// //                         // Sign in button
// //                         SizedBox(
// //                           width: double.infinity,
// //                           height: 50,
// //                           child: ElevatedButton(
// //                             onPressed: () {
// //                               // Add sign in logic here
// //                             },
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: const Color(0xFF3F51B5), // Indigo/blue color from the screenshot
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(4),
// //                               ),
// //                             ),
// //                             child: Text(
// //                               'Sign in',
// //                               style: GoogleFonts.poppins(
// //                                 fontSize: 18,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }