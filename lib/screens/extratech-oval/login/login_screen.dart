import 'package:flutter/material.dart';
import 'package:ems/core/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ExtratechOvalScreen extends StatefulWidget {
  @override
  _ExtratechOvalScreenState createState() => _ExtratechOvalScreenState();
}

class _ExtratechOvalScreenState extends State<ExtratechOvalScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${userCredential.user?.displayName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithEmailPassword() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in successfully')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFA1C7FF), // 0%
              Color(0xFFC4DCFF), // 11%
              Color(0xFFDBE7FE), // 23%
              Color(0xFFFEF9FC), // 41%
              Color(0xFFFFF4FB), // 74%
              Color(0xFFFDE8F5), // 100%
            ],
            stops: [0.0, 0.11, 0.23, 0.41, 0.74, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.02),
                  Image.asset(
                    'assets/Oval Logo.png',
                    width: 266,
                    height: 139,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Please, login to continue.',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  buildTextField('Email or Username', _usernameController),
                  SizedBox(height: 16),
                  buildPasswordField(),
                  SizedBox(height: 16),
                  buildRememberMeAndForgotPassword(),
                  SizedBox(height: 24),
                  buildLoginButton(),
                  SizedBox(height: 24),
                  buildOrLoginWithDivider(),
                  SizedBox(height: 24),
                  buildGoogleLoginButton(),
                  SizedBox(height: 30),
                  buildRegisterNowText(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey.shade400,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Remember me',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Handle forgot password
          },
          child: Text(
            'Forgot password',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithEmailPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF205EB5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          disabledBackgroundColor: Color(0xFF205EB5).withOpacity(0.5),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget buildOrLoginWithDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade400)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or Login with',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade400)),
      ],
    );
  }

  Widget buildGoogleLoginButton() {
    return InkWell(
      onTap: _isLoading ? null : _signInWithGoogle,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'assets/google_icon.png',
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  Widget buildRegisterNowText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to registration
          },
          child: Text(
            "Register now!",
            style: TextStyle(
              color: Colors.pink,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}















// import 'package:flutter/material.dart';
// import 'package:ems/core/app_colors.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class ExtratechOvalScreen extends StatefulWidget {
//   @override
//   _ExtratechOvalScreenState createState() => _ExtratechOvalScreenState();
// }

// class _ExtratechOvalScreenState extends State<ExtratechOvalScreen> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _rememberMe = false;
//   bool _obscureText = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // Method to handle Google Sign-In
//   Future<void> _signInWithGoogle() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Initialize Google Sign-In
//       final GoogleSignIn googleSignIn = GoogleSignIn();
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (googleUser == null) {
//         // User canceled the sign-in flow
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // Obtain auth details from request
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Create credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Sign in to Firebase with the Google credential
//       final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
//       // Successfully signed in
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Signed in as ${userCredential.user?.displayName}')),
//       );
      
//       // Navigate to home screen or next screen
//       // You can add navigation here
      
//     } catch (e) {
//       // Handle sign-in errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to sign in with Google: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Method to handle email/password sign in
//   Future<void> _signInWithEmailPassword() async {
//     if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter email and password')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Attempt to sign in with email and password
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _usernameController.text.trim(),
//         password: _passwordController.text,
//       );
      
//       // Successfully signed in
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Signed in successfully')),
//       );
      
//       // Navigate to home screen or next screen
//       // You can add navigation here
      
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'An error occurred';
      
//       if (e.code == 'user-not-found') {
//         errorMessage = 'No user found with this email';
//       } else if (e.code == 'wrong-password') {
//         errorMessage = 'Wrong password';
//       } else if (e.code == 'invalid-email') {
//         errorMessage = 'Invalid email format';
//       }
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(errorMessage)),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       // Add AppBar with back button
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: AppColors.primaryBlue),
//           onPressed: () {
//             // Navigate back to HomeScreen
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Background with gradient
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFFA1C7FF), // A1C7FF - 0%
//                   Color(0xFFC4DCFF), // C4DCFF - 11%
//                   Color(0xFFFEF9FC), // FEF9FC - 41%
//                   Color(0xFFFFF4FB), // FFF4FB - 74%
//                   Color(0xFFFDE8F5), // FDE8F5 - 100%
//                 ],
//                 stops: [0.0, 0.11, 0.41, 0.74, 1.0],
//               ),
//             ),
//           ),
          
//           // Main Content
//           SafeArea(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(height: size.height * 0.02), // Reduced top padding to account for AppBar
                    
//                     // Extratech Oval Logo
//                     Image.asset(
//                       'assets/Oval Logo.png',
//                       width: 266,
//                       height: 139,
//                       fit: BoxFit.contain,
//                     ),
                    
//                     SizedBox(height: 30),
                    
//                     // Please login to continue
//                     Container(
//                       width: 327,
//                       height: 31,
//                       child: Center(
//                         child: Text(
//                           'Please, login to continue.',
//                           style: TextStyle(
//                             color: AppColors.primaryBlue,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
                    
//                     SizedBox(height: 20),
                    
//                     // Email/Username TextField
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: TextField(
//                         controller: _usernameController,
//                         keyboardType: TextInputType.emailAddress,
//                         decoration: InputDecoration(
//                           hintText: 'Email or Username',
//                           hintStyle: TextStyle(color: Colors.grey.shade400),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//                           border: InputBorder.none,
//                         ),
//                       ),
//                     ),
                    
//                     SizedBox(height: 16),
                    
//                     // Password TextField
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: TextField(
//                         controller: _passwordController,
//                         obscureText: _obscureText,
//                         decoration: InputDecoration(
//                           hintText: 'Password',
//                           hintStyle: TextStyle(color: Colors.grey.shade400),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//                           border: InputBorder.none,
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _obscureText ? Icons.visibility_off : Icons.visibility,
//                               color: Colors.grey.shade400,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _obscureText = !_obscureText;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
                    
//                     SizedBox(height: 16),
                    
//                     // Remember me and Forgot password
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: Checkbox(
//                                 value: _rememberMe,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _rememberMe = value!;
//                                   });
//                                 },
//                                 activeColor: AppColors.primaryBlue,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             Text(
//                               'Remember me',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             // Handle forgot password
//                           },
//                           child: Text(
//                             'Forgot password',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 14,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: Size(10, 10),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     SizedBox(height: 24),
                    
//                     // Login Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _signInWithEmailPassword,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF205EB5),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           elevation: 0,
//                           disabledBackgroundColor: Color(0xFF205EB5).withOpacity(0.5),
//                         ),
//                         child: _isLoading 
//                           ? SizedBox(
//                               width: 24, 
//                               height: 24, 
//                               child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
//                             )
//                           : Text(
//                               'Login',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                       ),
//                     ),
                    
//                     SizedBox(height: 24),
                    
//                     // Or login with
//                     Row(
//                       children: [
//                         Expanded(child: Divider(color: Colors.grey.shade400)),
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           child: Text(
//                             'or Login with',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                         Expanded(child: Divider(color: Colors.grey.shade400)),
//                       ],
//                     ),
                    
//                     SizedBox(height: 24),
                    
//                     // Google login button
//                     InkWell(
//                       onTap: _isLoading ? null : _signInWithGoogle,
//                       borderRadius: BorderRadius.circular(25),
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(25),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 8,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Center(
//                           child: Image.asset(
//                             'assets/google_icon.png',
//                             width: 24,
//                             height: 24,
//                           ),
//                         ),
//                       ),
//                     ),
                    
//                     SizedBox(height: 30),
                    
//                     // Register now
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Don't have an account? ",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 14,
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             // Navigate to registration
//                           },
//                           child: Text(
//                             "Register now!",
//                             style: TextStyle(
//                               color: Colors.pink,
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
          
//           // Loading overlay
//           if (_isLoading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.3),
//                 child: Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }