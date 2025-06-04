import 'package:flutter/material.dart';
import 'package:ems/core/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ems/screens/extratech-oval/membership/membership_card_oval_screen.dart';
import 'package:ems/services/secure_storage_service.dart';
import 'package:flutter/services.dart';

class ExtratechOvalScreen extends StatefulWidget {
  const ExtratechOvalScreen({Key? key}) : super(key: key);

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
  void initState() {
    super.initState();
    // Check if user is already logged in
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final token = await SecureStorageService.getToken();
      final currentUser = FirebaseAuth.instance.currentUser;
      
      // If user is logged in, navigate to membership card screen
      if (token != null && currentUser != null && mounted) {
        // Save user email for later use
        await SecureStorageService.saveUserEmail(currentUser.email ?? '');
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GeneralMembershipScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to handle Google Sign-In with proper sign out first
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // Sign out first to ensure we get the account picker dialog
      try {
        await googleSignIn.signOut();
        await FirebaseAuth.instance.signOut();
        debugPrint('Signed out from previous sessions');
      } catch (signOutError) {
        debugPrint('Error signing out before sign in: $signOutError');
        // Continue with sign in even if sign out fails
      }
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Google Sign-In cancelled by user');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      debugPrint('Signed in with Google as: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Save user info to secure storage
      if (userCredential.user != null) {
        await SecureStorageService.saveUserEmail(userCredential.user?.email ?? '');
        // Save token for authentication checks
        await SecureStorageService.saveToken(await userCredential.user?.getIdToken() ?? '');
        debugPrint('User credentials saved to secure storage');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ${userCredential.user?.displayName}')),
        );
        
        // Navigate to MembershipCardScreen on successful sign in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GeneralMembershipScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in with Google: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithEmailPassword() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign out first to ensure clean state
      try {
        await FirebaseAuth.instance.signOut();
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (signOutError) {
        debugPrint('Error signing out before email sign in: $signOutError');
        // Continue with sign in even if sign out fails
      }
      
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      
      // Save user info to secure storage
      if (userCredential.user != null) {
        await SecureStorageService.saveUserEmail(userCredential.user?.email ?? '');
        // Save token for authentication checks
        await SecureStorageService.saveToken(await userCredential.user?.getIdToken() ?? '');
        
        // Save password if remember me is checked
        if (_rememberMe) {
          await SecureStorageService.saveUserPassword(_passwordController.text);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in successfully')),
        );
        
        // Navigate to MembershipCardScreen on successful sign in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GeneralMembershipScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    
    // Calculate responsive sizes
    final isSmallScreen = screenHeight < 700;
    final verticalSpacing = isSmallScreen ? 12.0 : 24.0;
    final logoHeight = isSmallScreen ? screenHeight * 0.12 : 139.0;
    
    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06, // Responsive padding
                vertical: screenHeight * 0.02,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: isSmallScreen ? 10 : screenHeight * 0.02),
                    
                    // Logo
                    Image.asset(
                      'assets/Oval Logo.png',
                      width: screenWidth * 0.6,
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                    
                    SizedBox(height: verticalSpacing),
                    
                    // Login message
                    Text(
                      'Please, login to continue.',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    SizedBox(height: verticalSpacing * 0.8),
                    
                    // Username/email field
                    buildTextField('Email or Username', _usernameController),
                    
                    SizedBox(height: verticalSpacing * 0.6),
                    
                    // Password field
                    buildPasswordField(),
                    
                    SizedBox(height: verticalSpacing * 0.6),
                    
                    // Remember me & Forgot password
                    buildRememberMeAndForgotPassword(isSmallScreen),
                    
                    SizedBox(height: verticalSpacing),
                    
                    // Login button
                    buildLoginButton(),
                    
                    SizedBox(height: verticalSpacing),
                    
                    // Divider
                    buildOrLoginWithDivider(),
                    
                    SizedBox(height: verticalSpacing),
                    
                    // Google login button
                    buildGoogleLoginButton(),
                    
                    SizedBox(height: verticalSpacing),
                    
                    // Register now
                    buildRegisterNowText(isSmallScreen),
                    
                    SizedBox(height: verticalSpacing * 0.8),
                  ],
                ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 20,
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
    );
  }

  Widget buildRememberMeAndForgotPassword(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me checkbox
        Row(
          children: [
            Transform.scale(
              scale: isSmallScreen ? 0.9 : 1.0,
              child: SizedBox(
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
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ],
        ),
        
        // Forgot password link
        TextButton(
          onPressed: () {
            // Handle forgot password
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot password',
            style: TextStyle(
              color: Colors.black,
              fontSize: isSmallScreen ? 12 : 14,
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
          backgroundColor: const Color(0xFF205EB5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          disabledBackgroundColor: const Color(0xFF205EB5).withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
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
        Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or Login with',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
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
              offset: const Offset(0, 2),
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

  Widget buildRegisterNowText(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.black,
            fontSize: isSmallScreen ? 12 : 14,
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
              fontSize: isSmallScreen ? 12 : 14,
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
// import 'package:ems/screens/extratech-oval/membership/membership_card_oval_screen.dart';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:flutter/services.dart';

// class ExtratechOvalScreen extends StatefulWidget {
//   const ExtratechOvalScreen({Key? key}) : super(key: key);

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
//   void initState() {
//     super.initState();
//     // Check if user is already logged in
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     final token = await SecureStorageService.getToken();
//     final currentUser = FirebaseAuth.instance.currentUser;
    
//     // If user is logged in, navigate to membership card screen
//     if (token != null && currentUser != null && mounted) {
//       // Save user email for later use
//       await SecureStorageService.saveUserEmail(currentUser.email ?? '');
      
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const GeneralMembershipScreen()),
//       );
//     }
//   }

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
//       final GoogleSignIn googleSignIn = GoogleSignIn();
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (googleUser == null) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
//       // Save user info to secure storage
//       if (userCredential.user != null) {
//         await SecureStorageService.saveUserEmail(userCredential.user?.email ?? '');
//         // Save token for authentication checks
//         await SecureStorageService.saveToken(await userCredential.user?.getIdToken() ?? '');
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Signed in as ${userCredential.user?.displayName}')),
//         );
        
//         // Navigate to MembershipCardScreen on successful sign in
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const GeneralMembershipScreen()),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to sign in with Google: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _signInWithEmailPassword() async {
//     if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter email and password')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _usernameController.text.trim(),
//         password: _passwordController.text,
//       );
      
//       // Save user info to secure storage
//       if (userCredential.user != null) {
//         await SecureStorageService.saveUserEmail(userCredential.user?.email ?? '');
//         // Save token for authentication checks
//         await SecureStorageService.saveToken(await userCredential.user?.getIdToken() ?? '');
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Signed in successfully')),
//         );
        
//         // Navigate to MembershipCardScreen on successful sign in
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const GeneralMembershipScreen()),
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'An error occurred';
//       if (e.code == 'user-not-found') {
//         errorMessage = 'No user found with this email';
//       } else if (e.code == 'wrong-password') {
//         errorMessage = 'Wrong password';
//       } else if (e.code == 'invalid-email') {
//         errorMessage = 'Invalid email format';
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions
//     final size = MediaQuery.of(context).size;
//     final screenHeight = size.height;
//     final screenWidth = size.width;
    
//     // Calculate responsive sizes
//     final isSmallScreen = screenHeight < 700;
//     final verticalSpacing = isSmallScreen ? 12.0 : 24.0;
//     final logoHeight = isSmallScreen ? screenHeight * 0.12 : 139.0;
    
//     // Set status bar color
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ));

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: AppColors.primaryBlue),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFA1C7FF), // 0%
//               Color(0xFFC4DCFF), // 11%
//               Color(0xFFDBE7FE), // 23%
//               Color(0xFFFEF9FC), // 41%
//               Color(0xFFFFF4FB), // 74%
//               Color(0xFFFDE8F5), // 100%
//             ],
//             stops: [0.0, 0.11, 0.23, 0.41, 0.74, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             physics: const ClampingScrollPhysics(),
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.06, // Responsive padding
//                 vertical: screenHeight * 0.02,
//               ),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: screenHeight - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(height: isSmallScreen ? 10 : screenHeight * 0.02),
                    
//                     // Logo
//                     Image.asset(
//                       'assets/Oval Logo.png',
//                       width: screenWidth * 0.6,
//                       height: logoHeight,
//                       fit: BoxFit.contain,
//                     ),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Login message
//                     Text(
//                       'Please, login to continue.',
//                       style: TextStyle(
//                         color: AppColors.primaryBlue,
//                         fontSize: isSmallScreen ? 16 : 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
                    
//                     SizedBox(height: verticalSpacing * 0.8),
                    
//                     // Username/email field
//                     buildTextField('Email or Username', _usernameController),
                    
//                     SizedBox(height: verticalSpacing * 0.6),
                    
//                     // Password field
//                     buildPasswordField(),
                    
//                     SizedBox(height: verticalSpacing * 0.6),
                    
//                     // Remember me & Forgot password
//                     buildRememberMeAndForgotPassword(isSmallScreen),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Login button
//                     buildLoginButton(),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Divider
//                     buildOrLoginWithDivider(),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Google login button
//                     buildGoogleLoginButton(),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Register now
//                     buildRegisterNowText(isSmallScreen),
                    
//                     SizedBox(height: verticalSpacing * 0.8),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(String hintText, TextEditingController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: TextInputType.emailAddress,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey.shade400),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }

//   Widget buildPasswordField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _passwordController,
//         obscureText: _obscureText,
//         decoration: InputDecoration(
//           hintText: 'Password',
//           hintStyle: TextStyle(color: Colors.grey.shade400),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//           border: InputBorder.none,
//           suffixIcon: IconButton(
//             icon: Icon(
//               _obscureText ? Icons.visibility_off : Icons.visibility,
//               color: Colors.grey.shade400,
//             ),
//             onPressed: () {
//               setState(() {
//                 _obscureText = !_obscureText;
//               });
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             splashRadius: 20,
//           ),
//           suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
//         ),
//       ),
//     );
//   }

//   Widget buildRememberMeAndForgotPassword(bool isSmallScreen) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Remember me checkbox
//         Row(
//           children: [
//             Transform.scale(
//               scale: isSmallScreen ? 0.9 : 1.0,
//               child: SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: Checkbox(
//                   value: _rememberMe,
//                   onChanged: (value) {
//                     setState(() {
//                       _rememberMe = value!;
//                     });
//                   },
//                   activeColor: AppColors.primaryBlue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Remember me',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ],
//         ),
        
//         // Forgot password link
//         TextButton(
//           onPressed: () {
//             // Handle forgot password
//           },
//           style: TextButton.styleFrom(
//             padding: EdgeInsets.zero,
//             minimumSize: Size.zero,
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//           child: Text(
//             'Forgot password',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: isSmallScreen ? 12 : 14,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildLoginButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _signInWithEmailPassword,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF205EB5),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           elevation: 0,
//           disabledBackgroundColor: const Color(0xFF205EB5).withOpacity(0.5),
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//               )
//             : const Text(
//                 'Login',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget buildOrLoginWithDivider() {
//     return Row(
//       children: [
//         Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'or Login with',
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 14,
//             ),
//           ),
//         ),
//         Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
//       ],
//     );
//   }

//   Widget buildGoogleLoginButton() {
//     return InkWell(
//       onTap: _isLoading ? null : _signInWithGoogle,
//       borderRadius: BorderRadius.circular(25),
//       child: Container(
//         width: 50,
//         height: 50,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Image.asset(
//             'assets/google_icon.png',
//             width: 24,
//             height: 24,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildRegisterNowText(bool isSmallScreen) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "Don't have an account? ",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: isSmallScreen ? 12 : 14,
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             // Navigate to registration
//           },
//           child: Text(
//             "Register now!",
//             style: TextStyle(
//               color: Colors.pink,
//               fontSize: isSmallScreen ? 12 : 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:ems/core/app_colors.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:ems/screens/extratech-oval/membership/membership_card_oval_screen.dart';
// import 'package:flutter/services.dart';

// class ExtratechOvalScreen extends StatefulWidget {
//   const ExtratechOvalScreen({Key? key}) : super(key: key);

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
//       final GoogleSignIn googleSignIn = GoogleSignIn();
//       final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

//       if (googleUser == null) {
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Signed in as ${userCredential.user?.displayName}')),
//         );
        
//         // Navigate to MembershipCardScreen on successful sign in
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => const MembershipScreen(userEmail: "acharyadarwin@gmail.com")),
//         // );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to sign in with Google: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _signInWithEmailPassword() async {
//     if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter email and password')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _usernameController.text.trim(),
//         password: _passwordController.text,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Signed in successfully')),
//         );
        
//         // Navigate to MembershipCardScreen on successful sign in
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const GeneralMembershipScreen()),
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'An error occurred';
//       if (e.code == 'user-not-found') {
//         errorMessage = 'No user found with this email';
//       } else if (e.code == 'wrong-password') {
//         errorMessage = 'Wrong password';
//       } else if (e.code == 'invalid-email') {
//         errorMessage = 'Invalid email format';
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage)),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen dimensions
//     final size = MediaQuery.of(context).size;
//     final screenHeight = size.height;
//     final screenWidth = size.width;
    
//     // Calculate responsive sizes
//     final isSmallScreen = screenHeight < 700;
//     final verticalSpacing = isSmallScreen ? 12.0 : 24.0;
//     final logoHeight = isSmallScreen ? screenHeight * 0.12 : 139.0;
    
//     // Set status bar color
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.dark,
//     ));

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: AppColors.primaryBlue),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFA1C7FF), // 0%
//               Color(0xFFC4DCFF), // 11%
//               Color(0xFFDBE7FE), // 23%
//               Color(0xFFFEF9FC), // 41%
//               Color(0xFFFFF4FB), // 74%
//               Color(0xFFFDE8F5), // 100%
//             ],
//             stops: [0.0, 0.11, 0.23, 0.41, 0.74, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             physics: const ClampingScrollPhysics(),
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: screenWidth * 0.06, // Responsive padding
//                 vertical: screenHeight * 0.02,
//               ),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: screenHeight - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(height: isSmallScreen ? 10 : screenHeight * 0.02),
                    
//                     // Logo
//                     Image.asset(
//                       'assets/Oval Logo.png',
//                       width: screenWidth * 0.6,
//                       height: logoHeight,
//                       fit: BoxFit.contain,
//                     ),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Login message
//                     Text(
//                       'Please, login to continue.',
//                       style: TextStyle(
//                         color: AppColors.primaryBlue,
//                         fontSize: isSmallScreen ? 16 : 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
                    
//                     SizedBox(height: verticalSpacing * 0.8),
                    
//                     // Username/email field
//                     buildTextField('Email or Username', _usernameController),
                    
//                     SizedBox(height: verticalSpacing * 0.6),
                    
//                     // Password field
//                     buildPasswordField(),
                    
//                     SizedBox(height: verticalSpacing * 0.6),
                    
//                     // Remember me & Forgot password
//                     buildRememberMeAndForgotPassword(isSmallScreen),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Login button
//                     buildLoginButton(),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Divider
//                     buildOrLoginWithDivider(),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Google login button
//                     buildGoogleLoginButton(),
                    
//                     SizedBox(height: verticalSpacing),
                    
//                     // Register now
//                     buildRegisterNowText(isSmallScreen),
                    
//                     SizedBox(height: verticalSpacing * 0.8),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(String hintText, TextEditingController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: controller,
//         keyboardType: TextInputType.emailAddress,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey.shade400),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }

//   Widget buildPasswordField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _passwordController,
//         obscureText: _obscureText,
//         decoration: InputDecoration(
//           hintText: 'Password',
//           hintStyle: TextStyle(color: Colors.grey.shade400),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//           border: InputBorder.none,
//           suffixIcon: IconButton(
//             icon: Icon(
//               _obscureText ? Icons.visibility_off : Icons.visibility,
//               color: Colors.grey.shade400,
//             ),
//             onPressed: () {
//               setState(() {
//                 _obscureText = !_obscureText;
//               });
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             splashRadius: 20,
//           ),
//           suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
//         ),
//       ),
//     );
//   }

//   Widget buildRememberMeAndForgotPassword(bool isSmallScreen) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Remember me checkbox
//         Row(
//           children: [
//             Transform.scale(
//               scale: isSmallScreen ? 0.9 : 1.0,
//               child: SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: Checkbox(
//                   value: _rememberMe,
//                   onChanged: (value) {
//                     setState(() {
//                       _rememberMe = value!;
//                     });
//                   },
//                   activeColor: AppColors.primaryBlue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Remember me',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ],
//         ),
        
//         // Forgot password link
//         TextButton(
//           onPressed: () {
//             // Handle forgot password
//           },
//           style: TextButton.styleFrom(
//             padding: EdgeInsets.zero,
//             minimumSize: Size.zero,
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//           child: Text(
//             'Forgot password',
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: isSmallScreen ? 12 : 14,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildLoginButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _signInWithEmailPassword,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF205EB5),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           elevation: 0,
//           disabledBackgroundColor: const Color(0xFF205EB5).withOpacity(0.5),
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 width: 24,
//                 height: 24,
//                 child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//               )
//             : const Text(
//                 'Login',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget buildOrLoginWithDivider() {
//     return Row(
//       children: [
//         Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'or Login with',
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 14,
//             ),
//           ),
//         ),
//         Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
//       ],
//     );
//   }

//   Widget buildGoogleLoginButton() {
//     return InkWell(
//       onTap: _isLoading ? null : _signInWithGoogle,
//       borderRadius: BorderRadius.circular(25),
//       child: Container(
//         width: 50,
//         height: 50,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Image.asset(
//             'assets/google_icon.png',
//             width: 24,
//             height: 24,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildRegisterNowText(bool isSmallScreen) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "Don't have an account? ",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: isSmallScreen ? 12 : 14,
//           ),
//         ),
//         GestureDetector(
//           onTap: () {
//             // Navigate to registration
//           },
//           child: Text(
//             "Register now!",
//             style: TextStyle(
//               color: Colors.pink,
//               fontSize: isSmallScreen ? 12 : 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
