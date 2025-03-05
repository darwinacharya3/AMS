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
        Uri.parse('$baseUrl/student/membership-detail'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response for membership types: $data');
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
        print('API Response for membership card: $data');
        
        // Check if the user has a membership card
        if (data['membershipCardStatus'] == 'YES' && data['membershipCard'] != null) {
          return Map<String, dynamic>.from(data['membershipCard']);
        }
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
    
    // Find the type with the matching name
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
//         // Changed 'data' to 'membershipTypes' to match the API response
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
    
//     // Find the type with the matching name - changed 'name' to 'type'
//     Map<String, dynamic>? matchingType = types.firstWhere(
//       (type) => type['type'] == typeName,
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

//       // print('Fetching membership types...');
//       final response = await http.get(
//         Uri.parse('$baseUrl/student/membership-types'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       // print('Membership types response: ${response.statusCode}');
//       // print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         // Handle different possible response structures
//         List<Map<String, dynamic>> types = [];
        
//         if (data['membershipTypes'] != null) {
//           types = List<Map<String, dynamic>>.from(data['membershipTypes']);
//         } else if (data['data'] != null) {
//           types = List<Map<String, dynamic>>.from(data['data']);
//         } else if (data is List) {
//           types = List<Map<String, dynamic>>.from(data);
//         }
        
//         // print('Membership types found: ${types.length}');
//         return types;
//       } else {
//         throw Exception('Failed to load membership types: ${response.statusCode}');
//       }
//     } catch (e) {
//       // print('Error fetching membership types: $e');
//       throw Exception('Error fetching membership types: $e');
//     }
//   }

//   // Check if user has membership card
//  static Future<Map<String, dynamic>> getMembershipCard() async {
//     try {
//       String? token = await SecureStorageService.getToken();
      
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       print('Fetching membership card details...');
//       final response = await http.get(
//         Uri.parse('$baseUrl/student/membership-detail'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       print('Membership card response: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
        
//         // Return the complete response to handle in the UI
//         return Map<String, dynamic>.from(data);
//       } else {
//         throw Exception('Failed to check membership card: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error checking membership card: $e');
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

//       // print('Submitting membership application...');
//       // print('Form data: $formData');
      
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
//       // print('Getting ID for membership type: $membershipTypeName');
//       int cardTypeId = await _getMembershipTypeId(membershipTypeName);
//       // print('Found card type ID: $cardTypeId');
      
//       // Add text fields according to API requirements
//       request.fields['card_type_id'] = cardTypeId.toString();
//       request.fields['amount'] = formData['paidAmount'];
      
//       // Add payment slip file
//       File paymentSlipFile = formData['paymentSlip'];
//       var stream = http.ByteStream(paymentSlipFile.openRead());
//       var length = await paymentSlipFile.length();
      
//       // print('Adding payment slip file: ${paymentSlipFile.path}');
//       var multipartFile = http.MultipartFile(
//         'payment_slip',
//         stream,
//         length,
//         filename: 'payment_slip.jpg',
//         contentType: MediaType('image', 'jpeg'),
//       );
      
//       request.files.add(multipartFile);
      
//       // Send request
//       // print('Sending membership application request...');
//       var response = await request.send();
//       var responseString = await response.stream.bytesToString();
      
//       // print('Response status: ${response.statusCode}');
//       // print('Response body: $responseString');
      
//       var responseData = json.decode(responseString);
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // print('Membership application submitted successfully');
//         return true;
//       } else {
//         throw Exception(responseData['message'] ?? 'Failed to submit application');
//       }
//     } catch (e) {
//       // print('Error submitting application: $e');
//       throw Exception('Error submitting application: $e');
//     }
//   }
  
//   // Helper method to get membership type ID from name
//   static Future<int> _getMembershipTypeId(String typeName) async {
//     // Get all membership types
//     List<Map<String, dynamic>> types = await getMembershipTypes();
//     // print('Searching for membership type: $typeName among ${types.length} types');
    
//     // Find the type with the matching name - try different field names
//     Map<String, dynamic>? matchingType;
    
//     // Check for 'type' field
//     matchingType = types.firstWhere(
//       (type) => type['type']?.toString().toLowerCase() == typeName.toLowerCase(),
//       orElse: () => <String, dynamic>{},
//     );
    
//     // If not found, check for 'name' field
//     if (matchingType.isEmpty) {
//       matchingType = types.firstWhere(
//         (type) => type['name']?.toString().toLowerCase() == typeName.toLowerCase(),
//         orElse: () => <String, dynamic>{},
//       );
//     }
    
//     // If not found, check for 'membershipType' field
//     if (matchingType.isEmpty) {
//       matchingType = types.firstWhere(
//         (type) => type['membershipType']?.toString().toLowerCase() == typeName.toLowerCase(),
//         orElse: () => <String, dynamic>{},
//       );
//     }
    
//     // If not found, check for partial matches
//     if (matchingType.isEmpty) {
//       matchingType = types.firstWhere(
//         (type) {
//           final typeValue = type['type']?.toString().toLowerCase() ?? '';
//           final nameValue = type['name']?.toString().toLowerCase() ?? '';
//           final membershipTypeValue = type['membershipType']?.toString().toLowerCase() ?? '';
          
//           return typeValue.contains(typeName.toLowerCase()) || 
//                  nameValue.contains(typeName.toLowerCase()) ||
//                  membershipTypeValue.contains(typeName.toLowerCase());
//         },
//         orElse: () => throw Exception('Invalid membership type: $typeName'),
//       );
//     }
    
//     // print('Found matching type: $matchingType');
    
//     // Check different field names for the ID
//     int? id;
    
//     if (matchingType['id'] != null) {
//       id = int.parse(matchingType['id'].toString());
//     } else if (matchingType['cardTypeId'] != null) {
//       id = int.parse(matchingType['cardTypeId'].toString());
//     } else if (matchingType['card_type_id'] != null) {
//       id = int.parse(matchingType['card_type_id'].toString());
//     } else if (matchingType['typeId'] != null) {
//       id = int.parse(matchingType['typeId'].toString());
//     } else if (matchingType['type_id'] != null) {
//       id = int.parse(matchingType['type_id'].toString());
//     }
    
//     if (id == null) {
//       throw Exception('Could not find ID for membership type: $typeName');
//     }
    
//     return id;
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
//         // Changed 'data' to 'membershipTypes' to match the API response
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
    
//     // Find the type with the matching name - changed 'name' to 'type'
//     Map<String, dynamic>? matchingType = types.firstWhere(
//       (type) => type['type'] == typeName,
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