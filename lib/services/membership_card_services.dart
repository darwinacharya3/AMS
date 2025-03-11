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


