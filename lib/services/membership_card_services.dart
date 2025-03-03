import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ems/services/secure_storage_service.dart';
import 'package:http_parser/http_parser.dart';

class MembershipCardService {
  static const String baseUrl = 'https://extratech.extratechweb.com/api';

  // Get membership types from API
  static Future<List<Map<String, dynamic>>> getMembershipTypes() async {
    try {
      String? token = await SecureStorageService.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/student/membership-types'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Changed 'data' to 'membershipTypes' to match the API response
        return List<Map<String, dynamic>>.from(data['membershipTypes'] ?? []);
      } else {
        throw Exception('Failed to load membership types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching membership types: $e');
    }
  }

  // Check if user has membership card
  static Future<Map<String, dynamic>?> getMembershipCard() async {
    try {
      String? token = await SecureStorageService.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/student/membership-detail'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
        return null; // No card found
      } else if (response.statusCode == 404) {
        return null; // No card found
      } else {
        throw Exception('Failed to check membership card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking membership card: $e');
    }
  }

  // Submit membership application with photo upload
  static Future<bool> submitMembershipApplication(Map<String, dynamic> formData) async {
    try {
      String? token = await SecureStorageService.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Create multipart request for photo upload
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/student/store/membership')
      );
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      
      // Get membership type ID from the name
      String membershipTypeName = formData['membershipType'];
      int cardTypeId = await _getMembershipTypeId(membershipTypeName);
      
      // Add text fields according to API requirements
      request.fields['card_type_id'] = cardTypeId.toString();
      request.fields['amount'] = formData['paidAmount'];
      
      // Add payment slip file
      File paymentSlipFile = formData['paymentSlip'];
      var stream = http.ByteStream(paymentSlipFile.openRead());
      var length = await paymentSlipFile.length();
      
      var multipartFile = http.MultipartFile(
        'payment_slip',
        stream,
        length,
        filename: 'payment_slip.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      
      // Send request
      var response = await request.send();
      var responseString = await response.stream.bytesToString();
      var responseData = json.decode(responseString);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to submit application');
      }
    } catch (e) {
      throw Exception('Error submitting application: $e');
    }
  }
  
  // Helper method to get membership type ID from name
  static Future<int> _getMembershipTypeId(String typeName) async {
    // Get all membership types
    List<Map<String, dynamic>> types = await getMembershipTypes();
    
    // Find the type with the matching name - changed 'name' to 'type'
    Map<String, dynamic>? matchingType = types.firstWhere(
      (type) => type['type'] == typeName,
      orElse: () => throw Exception('Invalid membership type: $typeName'),
    );
    
    return matchingType['id'];
  }
}













// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:http_parser/http_parser.dart';

// class MembershipCardService {
//   static const String baseUrl = 'https://extratech.extratechweb.com/api';

//   // Get membership types from API
// // Improved getMembershipTypes method with better error handling
// static Future<List<Map<String, dynamic>>> getMembershipTypes() async {
//   try {
//     String? token = await SecureStorageService.getToken();
    
//     if (token == null) {
//       throw Exception('Authentication token not found');
//     }

//     final response = await http.get(
//       Uri.parse('$baseUrl/student/membership-types'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       // Change this line to access 'membershipTypes' instead of 'data'
//       return List<Map<String, dynamic>>.from(data['membershipTypes'] ?? []);
//     } else {
//       throw Exception('Failed to load membership types: ${response.statusCode}');
//     }
//   } catch (e) {
//     throw Exception('Error fetching membership types: $e');
//   }
// }
//   // static Future<List<Map<String, dynamic>>> getMembershipTypes() async {
//   //   try {
//   //     String? token = await SecureStorageService.getToken();
      
//   //     if (token == null) {
//   //       throw Exception('Authentication token not found');
//   //     }

//   //     final response = await http.get(
//   //       Uri.parse('$baseUrl/student/membership-types'),
//   //       headers: {
//   //         'Authorization': 'Bearer $token',
//   //         'Accept': 'application/json',
//   //       },
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);
//   //       return List<Map<String, dynamic>>.from(data['data'] ?? []);
//   //     } else {
//   //       throw Exception('Failed to load membership types: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     throw Exception('Error fetching membership types: $e');
//   //   }
//   // }

//   // Check if user has membership card
//   static Future<Map<String, dynamic>?> getMembershipCard() async {
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/student/membership-detail'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['data'] != null) {
//           return Map<String, dynamic>.from(data['data']);
//         }
//         return null; // No card found
//       } else if (response.statusCode == 404) {
//         return null; // No card found
//       } else {
//         throw Exception('Failed to check membership card: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error checking membership card: $e');
//     }
//   }

//   // Submit membership application with photo upload
//   static Future<bool> submitMembershipApplication(Map<String, dynamic> formData) async {
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Create multipart request for photo upload
//       var request = http.MultipartRequest(
//         'POST', 
//         Uri.parse('$baseUrl/student/store/membership')
//       );
      
//       // Add headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });
      
//       // Get membership type ID from the name
//       String membershipTypeName = formData['membershipType'];
//       int cardTypeId = await _getMembershipTypeId(membershipTypeName);
      
//       // Add text fields according to API requirements
//       request.fields['card_type_id'] = cardTypeId.toString();
//       request.fields['amount'] = formData['paidAmount'];
      
//       // Add payment slip file
//       File paymentSlipFile = formData['paymentSlip'];
//       var stream = http.ByteStream(paymentSlipFile.openRead());
//       var length = await paymentSlipFile.length();
      
//       var multipartFile = http.MultipartFile(
//         'payment_slip',
//         stream,
//         length,
//         filename: 'payment_slip.jpg',
//         contentType: MediaType('image', 'jpeg'),
//       );
      
//       request.files.add(multipartFile);
      
//       // Send request
//       var response = await request.send();
//       var responseString = await response.stream.bytesToString();
//       var responseData = json.decode(responseString);
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return true;
//       } else {
//         throw Exception(responseData['message'] ?? 'Failed to submit application');
//       }
//     } catch (e) {
//       throw Exception('Error submitting application: $e');
//     }
//   }
  
//   // Helper method to get membership type ID from name
//   static Future<int> _getMembershipTypeId(String typeName) async {
//     // Get all membership types
//     List<Map<String, dynamic>> types = await getMembershipTypes();
    
//     // Find the type with the matching name
//     Map<String, dynamic>? matchingType = types.firstWhere(
//       (type) => type['name'] == typeName,
//       orElse: () => throw Exception('Invalid membership type: $typeName'),
//     );
    
//     return matchingType['id'];
//   }
// }








// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:http_parser/http_parser.dart';

// class MembershipCardService {
//   static const String baseUrl = 'https://extratech.extratechweb.com/api';

//   // Get membership types from API
//   static Future<List<Map<String, dynamic>>> getMembershipTypes() async {
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/student/membership-types'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return List<Map<String, dynamic>>.from(data['data'] ?? []);
//       } else {
//         throw Exception('Failed to load membership types: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching membership types: $e');
//     }
//   }

//   // Check if user has membership card
//   static Future<Map<String, dynamic>?> getMembershipCard() async {
//     try {
//       String? token = await SecureStorageService.getToken();
//       String? email = await SecureStorageService.getUserEmail();
      
//       if (token == null || email == null) {
//         throw Exception('Authentication information not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/student/membership-card'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['data'] != null) {
//           return Map<String, dynamic>.from(data['data']);
//         }
//         return null; // No card found
//       } else if (response.statusCode == 404) {
//         return null; // No card found
//       } else {
//         throw Exception('Failed to check membership card: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error checking membership card: $e');
//     }
//   }

//   // Submit membership application with photo upload
//   static Future<bool> submitMembershipApplication(Map<String, dynamic> formData) async {
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Create multipart request for photo upload
//       var request = http.MultipartRequest(
//         'POST', 
//         Uri.parse('$baseUrl/student/apply-membership')
//       );
      
//       // Add headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });
      
//       // Add text fields
//       request.fields['membership_type'] = formData['membershipType'];
//       request.fields['paid_amount'] = formData['paidAmount'];
      
//       // Add payment slip file
//       File paymentSlipFile = formData['paymentSlip'];
//       var stream = http.ByteStream(paymentSlipFile.openRead());
//       var length = await paymentSlipFile.length();
      
//       var multipartFile = http.MultipartFile(
//         'payment_slip',
//         stream,
//         length,
//         filename: 'payment_slip.jpg',
//         contentType: MediaType('image', 'jpeg'),
//       );
      
//       request.files.add(multipartFile);
      
//       // Send request
//       var response = await request.send();
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return true;
//       } else {
//         final responseData = await response.stream.bytesToString();
//         final parsedData = json.decode(responseData);
//         throw Exception(parsedData['message'] ?? 'Failed to submit application');
//       }
//     } catch (e) {
//       throw Exception('Error submitting application: $e');
//     }
//   }
// }








// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:ems/services/secure_storage_service.dart';

// class MembershipCardService {
//   static const String baseUrl = 'https://extratech.extratechweb.com/api';

//   // Get membership types from API
//   static Future<List<Map<String, dynamic>>> getMembershipTypes() async {
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/student/membership-types'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return List<Map<String, dynamic>>.from(data['data'] ?? []);
//       } else {
//         throw Exception('Failed to load membership types: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching membership types: $e');
//     }
//   }

//   // Check if user has membership card
//   static Future<Map<String, dynamic>?> getMembershipCard() async {
//     try {
//       String? token = await SecureStorageService.getToken();
//       String? email = await SecureStorageService.getUserEmail();
      
//       if (token == null || email == null) {
//         throw Exception('Authentication information not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/student/membership-card'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['data'] != null) {
//           return Map<String, dynamic>.from(data['data']);
//         }
//         return null; // No card found
//       } else if (response.statusCode == 404) {
//         return null; // No card found
//       } else {
//         throw Exception('Failed to check membership card: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error checking membership card: $e');
//     }
//   }

//   // Submit membership application
//   static Future<bool> submitMembershipApplication(Map<String, dynamic> formData) async {
//     // Note: In a real implementation, you would use a multi-part request
//     // to upload the payment slip file.
    
//     // This is just a placeholder for future implementation
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Here you would create a multipart request and send the form data
//       // For now, we'll just simulate success
//       await Future.delayed(const Duration(seconds: 2));
//       return true;
//     } catch (e) {
//       throw Exception('Error submitting application: $e');
//     }
//   }
// }