import 'package:flutter/material.dart';
import 'package:ems/core/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems/services/secure_storage_service.dart';
import 'package:ems/screens/AMS/home/dashboard_screen.dart';

class AmsScreen extends StatefulWidget {
  const AmsScreen({Key? key}) : super(key: key);

  @override
  _AmsScreenState createState() => _AmsScreenState();
}

class _AmsScreenState extends State<AmsScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSavedCredentials();
  }

  // Check if credentials are saved and auto-fill the form
  Future<void> _checkSavedCredentials() async {
    final email = await SecureStorageService.getUserEmail();
    final password = await SecureStorageService.getUserPassword();
    
    if (email != null && password != null) {
      setState(() {
        _usernameController.text = email;
        _passwordController.text = password;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // API login method
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
      debugPrint('Making API request to: https://extratech.extratechweb.com/api/auth/login');

      // Make API request
      final response = await http.post(
        Uri.parse('https://extratech.extratechweb.com/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': _usernameController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      debugPrint('API Response Status Code: ${response.statusCode}');

      if (mounted) {
        if (response.statusCode == 200) {
          // Parse response data
          final Map<String, dynamic> data = json.decode(response.body);
          
          // DETAILED DEBUGGING OF RESPONSE FOR USER ID & UUID
          debugPrint('========== LOGIN RESPONSE DEBUG ==========');
          debugPrint('Response keys: ${data.keys.join(", ")}');

          // First, save token to secure storage
          if (data.containsKey('token') && data['token'] != null) {
            await SecureStorageService.saveToken(data['token']);
            debugPrint('Token saved to secure storage');
          } else {
            debugPrint('Warning: Token not found in API response');
          }

          // Look for the user ID and UUID in different possible locations
          bool userIdFound = false;
          bool uuidFound = false;

          // Check in the user object first
          if (data.containsKey('user') && data['user'] != null) {
            if (data['user'] is Map) {
              Map<String, dynamic> user = data['user'];
              debugPrint('USER OBJECT: Keys available: ${user.keys.join(", ")}');
              
              // Common ID field names to check
              final idFields = ['id', 'user_id', 'uid', 'student_id'];
              
              for (var field in idFields) {
                if (user.containsKey(field) && user[field] != null) {
                  await SecureStorageService.saveUserId(user[field].toString());
                  debugPrint('Found and saved user.$field: ${user[field]}');
                  userIdFound = true;
                  break;
                }
              }
              
              // Check for UUID fields - THIS IS THE IMPORTANT ADDITION
              final uuidFields = [
                'uuid', 'student_uuid', 'attendance_uuid', 
                'id_uuid', 'user_uuid', 'uid_uuid'
              ];
              
              for (var field in uuidFields) {
                if (user.containsKey(field) && user[field] != null) {
                  await SecureStorageService.saveUuid(user[field].toString());
                  debugPrint('Found and saved user.$field as UUID: ${user[field]}');
                  uuidFound = true;
                  break;
                }
              }
            } else if (data['user'] is String || data['user'] is int) {
              // If user is directly the ID
              await SecureStorageService.saveUserId(data['user'].toString());
              debugPrint('Saved direct user value as ID: ${data['user']}');
              userIdFound = true;
            }
          }
          
          // If UUID not found in user object, check at root level
          if (!uuidFound) {
            final rootUuidFields = [
              'uuid', 'student_uuid', 'attendance_uuid', 
              'id_uuid', 'user_uuid', 'uid_uuid'
            ];
            
            for (var field in rootUuidFields) {
              if (data.containsKey(field) && data[field] != null) {
                await SecureStorageService.saveUuid(data[field].toString());
                debugPrint('Found and saved root $field as UUID: ${data[field]}');
                uuidFound = true;
                break;
              }
            }
          }
          
          // If user ID not found in user object, check at root level
          if (!userIdFound) {
            final rootIdFields = ['id', 'user_id', 'uid', 'student_id'];
            
            for (var field in rootIdFields) {
              if (data.containsKey(field) && data[field] != null) {
                await SecureStorageService.saveUserId(data[field].toString());
                debugPrint('Found and saved root $field: ${data[field]}');
                userIdFound = true;
                break;
              }
            }
          }
          
          // If UUID still not found, try to extract from the response body
          if (!uuidFound) {
            try {
              final responseStr = response.body;
              debugPrint('UUID not found in standard locations. Examining response...');
              
              // Try to find patterns like "uuid":"1234-5678" or "attendance_uuid":"1234-5678" in the JSON
              RegExp uuidRegex = RegExp(r'"(?:uuid|student_uuid|attendance_uuid|id_uuid|user_uuid)"\s*:\s*"([^"]+)"');
              final match = uuidRegex.firstMatch(responseStr);
              
              if (match != null && match.group(1) != null) {
                final extractedUuid = match.group(1)!;
                await SecureStorageService.saveUuid(extractedUuid);
                debugPrint('Extracted UUID from response: $extractedUuid');
                uuidFound = true;
              }
            } catch (e) {
              debugPrint('Error extracting UUID from response: $e');
            }
          }
          
          // If UUID still not found and we have a userId, use that as fallback
          if (!uuidFound && userIdFound) {
            final userId = await SecureStorageService.getUserId();
            if (userId != null) {
              await SecureStorageService.saveUuid(userId);
              debugPrint('No UUID found. Using user ID as fallback UUID: $userId');
              uuidFound = true;
            }
          }

          // Save credentials if "Remember me" is checked
          if (_rememberMe) {
            await SecureStorageService.saveUserCredentials(
              _usernameController.text.trim(),
              _passwordController.text,
            );
            debugPrint('Credentials saved for Remember Me');
          } else {
            // If Remember Me is not checked, clear saved credentials
            // but still keep the token, user ID, and UUID for this session
            final token = await SecureStorageService.getToken();
            final userId = await SecureStorageService.getUserId();
            final uuid = await SecureStorageService.getUuid();
            
            await SecureStorageService.clearCredentials();
            
            if (token != null) {
              await SecureStorageService.saveToken(token);
            }
            if (userId != null) {
              await SecureStorageService.saveUserId(userId);
            }
            if (uuid != null) {
              await SecureStorageService.saveUuid(uuid);
            }
          }
          
          // Print all stored values for debugging
          await SecureStorageService.debugPrintAllStoredValues();
          
          debugPrint('========== END LOGIN RESPONSE DEBUG ==========');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully')),
          );
          
          // Navigate to Dashboard screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false, // Remove all previous routes
          );
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        } else {
          // Try to extract error message from response if available
          String errorMessage = 'Login failed';
          try {
            final Map<String, dynamic> errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? 'Login failed';
          } catch (e) {
            // If response body isn't valid JSON
            errorMessage = 'Login failed with status: ${response.statusCode}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: ${e.toString()}')),
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
                      'assets/logo.png',
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
                    
                    SizedBox(height: verticalSpacing * 2),
                    
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
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';

// class AmsScreen extends StatefulWidget {
//   const AmsScreen({Key? key}) : super(key: key);

//   @override
//   _AmsScreenState createState() => _AmsScreenState();
// }

// class _AmsScreenState extends State<AmsScreen> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _rememberMe = false;
//   bool _obscureText = true;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkSavedCredentials();
//   }

//   // Check if credentials are saved and auto-fill the form
//   Future<void> _checkSavedCredentials() async {
//     final email = await SecureStorageService.getUserEmail();
//     final password = await SecureStorageService.getUserPassword();
    
//     if (email != null && password != null) {
//       setState(() {
//         _usernameController.text = email;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // API login method
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
//       debugPrint('Making API request to: https://extratech.extratechweb.com/api/auth/login');

//       // Make API request
//       final response = await http.post(
//         Uri.parse('https://extratech.extratechweb.com/api/auth/login'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode({
//           'email': _usernameController.text.trim(),
//           'password': _passwordController.text,
//         }),
//       );

//       debugPrint('API Response Status Code: ${response.statusCode}');

//       if (mounted) {
//         if (response.statusCode == 200) {
//           // Parse response data
//           final Map<String, dynamic> data = json.decode(response.body);
          
//           // DETAILED DEBUGGING OF RESPONSE FOR USER ID
//           debugPrint('========== LOGIN RESPONSE DEBUG ==========');
//           debugPrint('Response keys: ${data.keys.join(", ")}');

//           // First, save token to secure storage
//           if (data.containsKey('token') && data['token'] != null) {
//             await SecureStorageService.saveToken(data['token']);
//             debugPrint('Token saved to secure storage');
//           } else {
//             debugPrint('Warning: Token not found in API response');
//           }

//           // Look for the user ID in different possible locations
//           bool userIdFound = false;

//           // Check in the user object first
//           if (data.containsKey('user') && data['user'] != null) {
//             if (data['user'] is Map) {
//               Map<String, dynamic> user = data['user'];
//               debugPrint('USER OBJECT: Keys available: ${user.keys.join(", ")}');
              
//               // Common ID field names to check
//               final idFields = ['id', 'user_id', 'uid', 'student_id'];
              
//               for (var field in idFields) {
//                 if (user.containsKey(field) && user[field] != null) {
//                   await SecureStorageService.saveUserId(user[field].toString());
//                   debugPrint('Found and saved user.$field: ${user[field]}');
//                   userIdFound = true;
//                   break;
//                 }
//               }
//             } else if (data['user'] is String || data['user'] is int) {
//               // If user is directly the ID
//               await SecureStorageService.saveUserId(data['user'].toString());
//               debugPrint('Saved direct user value as ID: ${data['user']}');
//               userIdFound = true;
//             }
//           }
          
//           // If not found in user object, check at root level
//           if (!userIdFound) {
//             final rootIdFields = ['id', 'user_id', 'uid', 'student_id'];
            
//             for (var field in rootIdFields) {
//               if (data.containsKey(field) && data[field] != null) {
//                 await SecureStorageService.saveUserId(data[field].toString());
//                 debugPrint('Found and saved root $field: ${data[field]}');
//                 userIdFound = true;
//                 break;
//               }
//             }
//           }
          
//           // If still not found, try to extract from the response body
//           if (!userIdFound) {
//             try {
//               final responseStr = response.body;
//               debugPrint('User ID not found in standard locations. Examining response...');
              
//               // Try to find patterns like "user_id":1828 or "uid":"1828" in the JSON
//               RegExp userIdRegex = RegExp(r'"(?:user_id|uid|id|student_id)"\s*:\s*"?(\d+)"?');
//               final match = userIdRegex.firstMatch(responseStr);
              
//               if (match != null && match.group(1) != null) {
//                 final extractedId = match.group(1)!;
//                 await SecureStorageService.saveUserId(extractedId);
//                 debugPrint('Extracted user ID from response: $extractedId');
//                 userIdFound = true;
//               }
//             } catch (e) {
//               debugPrint('Error extracting user ID from response: $e');
//             }
//           }

//           // Save credentials if "Remember me" is checked
//           if (_rememberMe) {
//             await SecureStorageService.saveUserCredentials(
//               _usernameController.text.trim(),
//               _passwordController.text,
//             );
//             debugPrint('Credentials saved for Remember Me');
//           } else {
//             // If Remember Me is not checked, clear saved credentials
//             // but still keep the token and user ID for this session
//             final token = await SecureStorageService.getToken();
//             final userId = await SecureStorageService.getUserId();
//             await SecureStorageService.clearCredentials();
            
//             if (token != null) {
//               await SecureStorageService.saveToken(token);
//             }
//             if (userId != null) {
//               await SecureStorageService.saveUserId(userId);
//             }
//           }
          
//           // Print all stored values for debugging
//           await SecureStorageService.debugPrintAllStoredValues();
          
//           debugPrint('========== END LOGIN RESPONSE DEBUG ==========');
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Signed in successfully')),
//           );
          
//           // Navigate to Dashboard screen
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const DashboardScreen()),
//             (route) => false, // Remove all previous routes
//           );
//         } else if (response.statusCode == 401) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Invalid email or password')),
//           );
//         } else {
//           // Try to extract error message from response if available
//           String errorMessage = 'Login failed';
//           try {
//             final Map<String, dynamic> errorData = json.decode(response.body);
//             errorMessage = errorData['message'] ?? 'Login failed';
//           } catch (e) {
//             // If response body isn't valid JSON
//             errorMessage = 'Login failed with status: ${response.statusCode}';
//           }
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(errorMessage)),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Network error: ${e.toString()}')),
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
//                       'assets/logo.png',
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
                    
//                     SizedBox(height: verticalSpacing * 2),
                    
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
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';

// class AmsScreen extends StatefulWidget {
//   const AmsScreen({Key? key}) : super(key: key);

//   @override
//   _AmsScreenState createState() => _AmsScreenState();
// }

// class _AmsScreenState extends State<AmsScreen> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _rememberMe = false;
//   bool _obscureText = true;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkSavedCredentials();
//   }

//   // Check if credentials are saved and auto-fill the form
//   Future<void> _checkSavedCredentials() async {
//     final email = await SecureStorageService.getUserEmail();
//     final password = await SecureStorageService.getUserPassword();
    
//     if (email != null && password != null) {
//       setState(() {
//         _usernameController.text = email;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // API login method
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
//       // Make API request to the correct endpoint
//       final response = await http.post(
//         Uri.parse('https://extratech.extratechweb.com/api/auth/login'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode({
//           'email': _usernameController.text.trim(),
//           'password': _passwordController.text,
//         }),
//       );

//       debugPrint('API Response Status Code: ${response.statusCode}');
//       debugPrint('API Response Body: ${response.body}');

//       if (mounted) {
//         if (response.statusCode == 200) {
//           // Parse response data
//           final Map<String, dynamic> data = json.decode(response.body);
          
//           // Save token to secure storage
//           if (data.containsKey('token') && data['token'] != null) {
//             await SecureStorageService.saveToken(data['token']);
//             debugPrint('Token saved to secure storage');
//           } else {
//             debugPrint('Warning: Token not found in API response');
//           }
          
//           // Save credentials if "Remember me" is checked
//           if (_rememberMe) {
//             await SecureStorageService.saveUserCredentials(
//               _usernameController.text.trim(),
//               _passwordController.text,
//             );
//             debugPrint('Credentials saved for Remember Me');
//           } else {
//             // If Remember Me is not checked, clear saved credentials
//             // but still keep the token for this session
//             final token = await SecureStorageService.getToken();
//             await SecureStorageService.clearCredentials();
//             if (token != null) {
//               await SecureStorageService.saveToken(token);
//             }
//           }
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Signed in successfully')),
//           );
          
//           // Navigate to Dashboard screen
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const DashboardScreen()),
//             (route) => false, // Remove all previous routes
//           );
//         } else if (response.statusCode == 401) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Invalid email or password')),
//           );
//         } else {
//           // Try to extract error message from response if available
//           String errorMessage = 'Login failed';
//           try {
//             final Map<String, dynamic> errorData = json.decode(response.body);
//             errorMessage = errorData['message'] ?? 'Login failed';
//           } catch (e) {
//             // If response body isn't valid JSON
//             errorMessage = 'Login failed with status: ${response.statusCode}';
//           }
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(errorMessage)),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Network error: ${e.toString()}')),
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
//                       'assets/logo.png',
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
                    
//                     SizedBox(height: verticalSpacing * 2),
                    
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

//   // Widget builders remain unchanged...
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
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';

// class AmsScreen extends StatefulWidget {
//   const AmsScreen({Key? key}) : super(key: key);

//   @override
//   _AmsScreenState createState() => _AmsScreenState();
// }

// class _AmsScreenState extends State<AmsScreen> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _rememberMe = false;
//   bool _obscureText = true;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkSavedCredentials();
//   }

//   // Check if credentials are saved and auto-fill the form
//   Future<void> _checkSavedCredentials() async {
//     final email = await SecureStorageService.getUserEmail();
//     final password = await SecureStorageService.getUserPassword();
    
//     if (email != null && password != null) {
//       setState(() {
//         _usernameController.text = email;
//         _passwordController.text = password;
//         _rememberMe = true;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // API login method
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
//       // Make API request
//       final response = await http.post(
//         Uri.parse('https://extratech.extratechweb.com/api/auth/login'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode({
//           'email': _usernameController.text.trim(),
//           'password': _passwordController.text,
//         }),
//       );

//       if (mounted) {
//         if (response.statusCode == 200) {
//           // Parse response data
//           final Map<String, dynamic> data = json.decode(response.body);
          
//           // Save token to secure storage
//           if (data.containsKey('token') && data['token'] != null) {
//             await SecureStorageService.saveToken(data['token']);
//             debugPrint('Token saved to secure storage');
//           } else {
//             debugPrint('Warning: Token not found in API response');
//           }
          
//           // Save credentials if "Remember me" is checked
//           if (_rememberMe) {
//             await SecureStorageService.saveUserCredentials(
//               _usernameController.text.trim(),
//               _passwordController.text,
//             );
//             debugPrint('Credentials saved for Remember Me');
//           } else {
//             // If Remember Me is not checked, clear saved credentials
//             // but still keep the token for this session
//             final token = await SecureStorageService.getToken();
//             await SecureStorageService.clearCredentials();
//             if (token != null) {
//               await SecureStorageService.saveToken(token);
//             }
//           }
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Signed in successfully')),
//           );
          
//           // Navigate to Dashboard screen
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const DashboardScreen()),
//             (route) => false, // Remove all previous routes
//           );
//         } else if (response.statusCode == 401) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Invalid email or password')),
//           );
//         } else {
//           // Try to extract error message from response if available
//           String errorMessage = 'Login failed';
//           try {
//             final Map<String, dynamic> errorData = json.decode(response.body);
//             errorMessage = errorData['message'] ?? 'Login failed';
//           } catch (e) {
//             // If response body isn't valid JSON
//             errorMessage = 'Login failed with status: ${response.statusCode}';
//           }
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(errorMessage)),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Network error: ${e.toString()}')),
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
//                       'assets/logo.png',
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
                    
//                     SizedBox(height: verticalSpacing * 2),
                    
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
// import 'package:flutter/services.dart';

// class AmsScreen extends StatefulWidget {
//   const AmsScreen({Key? key}) : super(key: key);

//   @override
//   _AmsScreenState createState() => _AmsScreenState();
// }

// class _AmsScreenState extends State<AmsScreen> {
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
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => const MembershipCardScreen()),
//         // );
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
//                       'assets/logo.png',
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
                    
//                     SizedBox(height: verticalSpacing * 2),
                    
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







