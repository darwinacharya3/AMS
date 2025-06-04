import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ems/services/secure_storage_service.dart';

class GeneralMembershipCardService {
  static const String baseUrl = 'https://extratech.extratechweb.com/api';
  
  // Cache for country-state data
  static Map<String, dynamic>? _countryStateData;
  // Cache for membership card data
  static Map<String, dynamic>? _membershipCardCache;
  // Cache time for membership data
  static DateTime? _membershipCacheTime;

  /// Get membership card data
  /// 
  /// Returns membership card data if the user has an active membership
  static Future<Map<String, dynamic>?> getMembershipCard() async {
    try {
      // Check if we have a valid cache (less than 15 minutes old)
      final currentTime = DateTime.now();
      if (_membershipCardCache != null && _membershipCacheTime != null) {
        final difference = currentTime.difference(_membershipCacheTime!);
        if (difference.inMinutes < 15) {
          debugPrint('Returning cached membership data');
          return _membershipCardCache;
        }
      }

      String? token = await SecureStorageService.getToken();
      if (token == null) {
        debugPrint('No authentication token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/general-membership'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      debugPrint('Membership card API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data != null && data.containsKey('membership') && data['membership'] != null) {
          // Update cache
          _membershipCardCache = Map<String, dynamic>.from(data['membership']);
          _membershipCacheTime = currentTime;
          
          debugPrint('Membership data retrieved and cached');
          return _membershipCardCache;
        } else {
          debugPrint('No membership found or pending approval');
          return null;
        }
      } else if (response.statusCode == 404) {
        // User doesn't have a membership yet
        debugPrint('User does not have a membership (404)');
        return null;
      } else {
        debugPrint('Failed to get membership card: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in getMembershipCard: $e');
      return null;
    }
  }

  /// Get available membership types
  /// 
  /// Fetches membership types from the API
  static Future<List<Map<String, dynamic>>> getMembershipTypes() async {
    try {
      String? token = await SecureStorageService.getToken();

      // Use student-membership endpoint as specified
      final response = await http.get(
        Uri.parse('$baseUrl/student-membership'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      // Log response for debugging
      debugPrint('Membership types API response status: ${response.statusCode}');
      debugPrint('Membership types API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check for membershipTypes key in the response as per API structure
        if (data.containsKey('membershipTypes')) {
          debugPrint('Found membershipTypes in response, length: ${data['membershipTypes'].length}');
          return List<Map<String, dynamic>>.from(data['membershipTypes'].map((x) => x));
        } else if (data.containsKey('types')) {
          debugPrint('Found types in response, length: ${data['types'].length}');
          return List<Map<String, dynamic>>.from(data['types'].map((x) => x));
        } else if (data is List) {
          debugPrint('Response is a List, length: ${data.length}');
          return List<Map<String, dynamic>>.from(data.map((x) => x));
        }
        
        debugPrint('No membership types found in response structure');
        return [];
      } else {
        debugPrint('Failed to get membership types: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error in getMembershipTypes: $e');
      return [];
    }
  }

  /// Fetch country and state data from the combined API endpoint
  /// 
  /// Gets both country and state data in a single API call
  static Future<Map<String, dynamic>> _fetchCountryStateData() async {
    if (_countryStateData != null) {
      // Return cached data if available
      return _countryStateData!;
    }

    try {
      String? token = await SecureStorageService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/country-state-list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      // Log response for debugging
      debugPrint('Country-State API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Successfully retrieved country-state data');
        
        // Cache the data for future use
        _countryStateData = data;
        return data;
      } else {
        debugPrint('Failed to get country-state list: ${response.statusCode}');
        throw Exception('Failed to load country-state data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in _fetchCountryStateData: $e');
      throw Exception('Error fetching country-state data: $e');
    }
  }

  /// Get list of countries
  /// 
  /// Extracts countries from the combined country-state data
  static Future<List<Map<String, dynamic>>> getCountryList() async {
    try {
      final data = await _fetchCountryStateData();
      
      // Extract countries from the response
      if (data.containsKey('countries')) {
        debugPrint('Found countries key, length: ${data['countries'].length}');
        return List<Map<String, dynamic>>.from(data['countries'].map((x) => x));
      } else if (data.containsKey('data') && data['data'].containsKey('countries')) {
        debugPrint('Found countries under data key, length: ${data['data']['countries'].length}');
        return List<Map<String, dynamic>>.from(data['data']['countries'].map((x) => x));
      }
      
      debugPrint('No countries found in response structure');
      return [];
    } catch (e) {
      debugPrint('Error in getCountryList: $e');
      return [];
    }
  }

  /// Get states by country ID
  /// 
  /// Extracts states for a specific country from the combined country-state data
  static Future<List<Map<String, dynamic>>> getStateList(int countryId) async {
    try {
      debugPrint('Fetching states for country ID: $countryId');
      
      final data = await _fetchCountryStateData();
      
      // Extract states for the specific country
      if (data.containsKey('states')) {
        // Filter states by country ID
        final allStates = List<Map<String, dynamic>>.from(data['states']);
        final filteredStates = allStates.where(
          (state) => state['country_id'] == countryId
        ).toList();
        
        debugPrint('Found ${filteredStates.length} states for country $countryId');
        return filteredStates;
      } else if (data.containsKey('data') && data['data'].containsKey('states')) {
        // Filter states by country ID
        final allStates = List<Map<String, dynamic>>.from(data['data']['states']);
        final filteredStates = allStates.where(
          (state) => state['country_id'] == countryId
        ).toList();
        
        debugPrint('Found ${filteredStates.length} states for country $countryId under data key');
        return filteredStates;
      }
      
      debugPrint('No states found in response structure for country $countryId');
      return [];
    } catch (e) {
      debugPrint('Error in getStateList: $e');
      return [];
    }
  }

  /// Submit a new membership application
  /// 
  /// Submits form data with required files to the API
  static Future<bool> submitMembershipApplication(Map<String, dynamic> formData) async {
    try {
      String? token = await SecureStorageService.getToken();

      // Create form data for multipart request (for file uploads)
      var request = http.MultipartRequest(
        'POST',
        // Use exactly the correct endpoint URL
        Uri.parse('$baseUrl/store-general-membership-request'),
      );

      // Log the request URL for debugging
      debugPrint('Submitting general membership to: ${request.url}');

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Validate required fields before submission
      final requiredFields = ['first_name', 'email', 'amount', 'dob', 'card_type_id', 'phone', 'address', 'country_id'];
      for (final field in requiredFields) {
        if (formData[field] == null || formData[field].toString().trim().isEmpty) {
          throw Exception('$field is required but is empty or missing');
        }
      }

      // Add text fields with trimming to remove any spaces
      request.fields['card_type_id'] = formData['card_type_id'].toString().trim();
      request.fields['first_name'] = (formData['first_name'] ?? '').toString().trim();
      request.fields['middle_name'] = (formData['middle_name'] ?? '').toString().trim();
      request.fields['last_name'] = (formData['last_name'] ?? '').toString().trim();
      request.fields['email'] = (formData['email'] ?? '').toString().trim();
      request.fields['phone'] = (formData['phone'] ?? '').toString().trim();
      request.fields['address'] = (formData['address'] ?? '').toString().trim();
      request.fields['amount'] = (formData['amount'] ?? '').toString().trim();
      request.fields['dob'] = (formData['dob'] ?? '').toString().trim();
      request.fields['country_id'] = formData['country_id'].toString().trim();
      
      // Log field values for debugging
      debugPrint('Sending fields:');
      request.fields.forEach((key, value) {
        debugPrint('$key: $value');
      });
      
      // Add optional fields if present
      if (formData.containsKey('state_id') && formData['state_id'] != null) {
        request.fields['state_id'] = formData['state_id'].toString().trim();
      }
      
      if (formData.containsKey('comment') && formData['comment'] != null && formData['comment'].toString().trim().isNotEmpty) {
        request.fields['comment'] = formData['comment'].toString().trim();
      }

      // Add required files
      if (formData['payment_slip'] != null && formData['payment_slip'] is File) {
        debugPrint('Adding payment slip file: ${formData['payment_slip'].path}');
        request.files.add(await http.MultipartFile.fromPath(
          'payment_slip',
          formData['payment_slip'].path,
        ));
      } else {
        throw Exception('Payment slip is required');
      }

      if (formData['photo'] != null && formData['photo'] is File) {
        debugPrint('Adding photo file: ${formData['photo'].path}');
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          formData['photo'].path,
        ));
      } else {
        throw Exception('Photo is required');
      }

      if (formData['citizenship_front'] != null && formData['citizenship_front'] is File) {
        debugPrint('Adding citizenship front file: ${formData['citizenship_front'].path}');
        request.files.add(await http.MultipartFile.fromPath(
          'citizenship_front',
          formData['citizenship_front'].path,
        ));
      } else {
        throw Exception('Citizenship front is required');
      }

      if (formData['citizenship_back'] != null && formData['citizenship_back'] is File) {
        debugPrint('Adding citizenship back file: ${formData['citizenship_back'].path}');
        request.files.add(await http.MultipartFile.fromPath(
          'citizenship_back',
          formData['citizenship_back'].path,
        ));
      } else {
        throw Exception('Citizenship back is required');
      }

      // Send the request
      debugPrint('Sending multipart request with ${request.files.length} files and ${request.fields.length} fields');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Log response for debugging
      debugPrint('Submit membership API response status: ${response.statusCode}');
      debugPrint('Submit membership API response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Membership application submitted successfully');
        
        // Clear membership cache so we fetch fresh data next time
        _membershipCardCache = null;
        _membershipCacheTime = null;
        
        return true;
      } else {
        Map<String, dynamic> errorData;
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          errorData = {"message": "Failed to parse error response"};
        }
        
        String errorMessage = 'Failed to submit application';
        if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
        
        // Check for validation errors
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          final errors = errorData['errors'] as Map;
          final List<String> errorList = [];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorList.add(value.first.toString());
            }
          });
          
          if (errorList.isNotEmpty) {
            errorMessage = errorList.join(', ');
          }
        }
        
        throw Exception('$errorMessage (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error in submitMembershipApplication: $e');
      throw Exception('Error submitting application: $e');
    }
  }
  
  /// Clear cached country-state data
  /// 
  /// Useful for refreshing the data or for testing
  static void clearCache() {
    _countryStateData = null;
    _membershipCardCache = null;
    _membershipCacheTime = null;
    debugPrint('All cache cleared (country-state and membership data)');
  }
}















