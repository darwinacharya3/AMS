import 'dart:convert';
import 'dart:io';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ems/services/secure_storage_service.dart';

class MembershipCardService {
  static const String baseUrl = 'https://extratech.extratechweb.com/api';

  // Get raw response data
  static Future<Map<String, dynamic>> getRawMembershipData() async {
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
        return data;
      } else {
        throw Exception('Failed to get membership data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting membership data: $e');
    }
  }

  static int min(int a, int b) => a < b ? a : b;
  
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
        
        // Check if the user has a membership card
        if (data.containsKey('membershipCard') && data['membershipCard'] != null) {
          return data['membershipCard'];
        }
        return null; // No card found
      } else {
        throw Exception('Failed to check membership card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking membership card: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMembershipTypes() async {
    try {
      String? token = await SecureStorageService.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Use the correct endpoint from Postman
      final response = await http.get(
        Uri.parse('$baseUrl/student/membership-types'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('types')) {
          return List<Map<String, dynamic>>.from(data['types'].map((x) => x));
        } else if (data is List) {
          // In case the API directly returns an array
          return List<Map<String, dynamic>>.from(data.map((x) => x));
        }
        
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> submitMembershipApplication(Map<String, dynamic> formData) async {
    try {
      String? token = await SecureStorageService.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Create form data for multipart request (for file upload)
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/student/store/membership'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['card_type_id'] = formData['card_type_id'];
      request.fields['amount'] = formData['amount'];

      // Add files
      if (formData['payment_slip'] != null && formData['payment_slip'] is File) {
        request.files.add(await http.MultipartFile.fromPath(
          'payment_slip',
          formData['payment_slip'].path,
        ));
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to submit application: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting application: $e');
    }
  }
}








// import 'dart:convert';
// import 'dart:io';
// // import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:ems/services/secure_storage_service.dart';
// import 'dart:developer' as developer;

// class MembershipCardService {
//   static const String baseUrl = 'https://extratech.extratechweb.com/api';

//   // Get raw response data
//   static Future<Map<String, dynamic>> getRawMembershipData() async {
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
//         developer.log('Raw API response: ${response.body.substring(0, min(200, response.body.length))}...');
//         return data;
//       } else {
//         throw Exception('Failed to get membership data: ${response.statusCode}');
//       }
//     } catch (e) {
//       developer.log('Error getting raw membership data: $e');
//       throw Exception('Error getting membership data: $e');
//     }
//   }

//   static int min(int a, int b) => a < b ? a : b;
  
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
        
//         // Check if the user has a membership card
//         if (data.containsKey('membershipCard') && data['membershipCard'] != null) {
//           return data['membershipCard'];
//         }
//         return null; // No card found
//       } else {
//         throw Exception('Failed to check membership card: ${response.statusCode}');
//       }
//     } catch (e) {
//       developer.log('Error checking membership card: $e');
//       throw Exception('Error checking membership card: $e');
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getMembershipTypes() async {
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Use the correct endpoint from Postman - changed from /student/membership-type to /student/membership-types
//       final response = await http.get(
//         Uri.parse('$baseUrl/student/membership-types'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       developer.log('Membership types API response status: ${response.statusCode}');
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         developer.log('Membership types API response: ${response.body.substring(0, min(100, response.body.length))}...');
        
//         if (data.containsKey('types')) {
//           return List<Map<String, dynamic>>.from(data['types'].map((x) => x));
//         } else if (data is List) {
//           // In case the API directly returns an array
//           return List<Map<String, dynamic>>.from(data.map((x) => x));
//         }
        
//         developer.log('Warning: Unexpected membership types format');
//         return [];
//       } else {
//         developer.log('Failed to get membership types: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       developer.log('Error getting membership types: $e');
//       return [];
//     }
//   }

//   static Future<bool> submitMembershipApplication(Map<String, dynamic> formData) async {
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Create form data for multipart request (for file upload)
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/student/store/membership'), // This should match your API endpoint
//       );

//       // Add headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });

//       // Add text fields
//       request.fields['card_type_id'] = formData['card_type_id'];
//       request.fields['amount'] = formData['amount'];

//       // Add files
//       if (formData['payment_slip'] != null && formData['payment_slip'] is File) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'payment_slip',
//           formData['payment_slip'].path,
//         ));
//       }

//       // Send the request
//       developer.log('Sending membership application...');
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
      
//       developer.log('Membership application response: ${response.statusCode}, ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = json.decode(response.body);
//         developer.log('Application submitted successfully: $responseData');
//         return true;
//       } else {
//         throw Exception('Failed to submit application: ${response.statusCode}, ${response.body}');
//       }
//     } catch (e) {
//       developer.log('Error submitting application: $e');
//       throw Exception('Error submitting application: $e');
//     }
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
//         Uri.parse('$baseUrl/student/membership-detail'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('API Response for membership types: $data');
//         return List<Map<String, dynamic>>.from(data['membershipTypes'] ?? []);
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
//         print('API Response for membership card: $data');
        
//         // Check if the user has a membership card
//         if (data['membershipCardStatus'] == 'YES' && data['membershipCard'] != null) {
//           return Map<String, dynamic>.from(data['membershipCard']);
//         }
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
//       (type) => type['type'] == typeName,
//       orElse: () => throw Exception('Invalid membership type: $typeName'),
//     );
    
//     return matchingType['id'];
//   }
// }
