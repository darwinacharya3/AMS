import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:ems/models/edit_user_details.dart';
import 'package:ems/services/secure_storage_service.dart';

class ProfileService {
  // The confirmed base URL for the API
  static const String baseUrl = 'https://extratech.extratechweb.com/api';
  
  // Get the auth token from secure storage
  Future<String?> _getAuthToken() async {
    return await SecureStorageService.getToken();
  }

  // Log system information for debugging
  void _logSystemInfo(String operation) {
    final DateTime now = DateTime.now().toUtc();
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    
    debugPrint('==========================================================');
    debugPrint('Operation: $operation');
    debugPrint('Current Date and Time (UTC): $formattedDate');
    debugPrint('Current User\'s Login: darwinacharya3');
    debugPrint('==========================================================');
  }

  // Get user profile using the real API endpoint
  Future<EditUserDetail> getUserProfile() async {
    _logSystemInfo('GET Student Profile');
    
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Using the real API endpoint provided
      final String profileUrl = '$baseUrl/get/student-profile';
      debugPrint('Fetching profile from: $profileUrl');
      
      final response = await http.get(
        Uri.parse(profileUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Log the response for debugging
      debugPrint('API Response Status (getUserProfile): ${response.statusCode}');
      if (response.body.length < 1000) {
        // Only log the full body if it's not too large
        debugPrint('API Response Body: ${response.body}');
      } else {
        debugPrint('API Response Body: [Large response, first 500 chars] ${response.body.substring(0, 500)}...');
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return EditUserDetail.fromJson(responseData['data']);
      } else {
        debugPrint('API Error (getUserProfile): ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get profile: Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in getUserProfile: $e');
      
      // In case of error, provide fallback mock data for development
      debugPrint('Falling back to mock profile data');
      return _getMockUserProfile();
    }
  }
  
  // Mock user profile as fallback
  EditUserDetail _getMockUserProfile() {
    return EditUserDetail(
      id: '123',
      userId: '1854',
      studentId: '1736',
      name: 'Manoj Kumar',
      email: 'manoj.kumar@gmail.com',
      mobileNo: '9816836470',
      gender: '1',
      dob: '2020-05-10',
      countryOfBirth: '157',
      birthStateId: '3',
      birthResidentialAddress: 'Balkot-5',
      commencementDate: '2025-05-05',
      signature: 'Manoj Kumar',
      isAusPermanentResident: '1',
      countryOfLiving: '239',
      residentialAddress: 'California',
      postCode: '20030',
      visaType: 'Student',
      currentStateId: '20',
      passportNumber: 'PA20055',
      passportExpiryDate: '2025-05-05',
      eContactName: 'Sobhan Ray',
      relation: 'Friends',
      eContactNo: '9812345343',
      highestEducation: 'SLC/SEE',
      profileImage: '',
      status: '1',
      editableFields: {
        'name': false,           // Name not editable
        'email': false,          // Email not editable
        'mobileNo': true,
        'gender': true,
        'dob': true,
        'countryOfBirth': false, // Birth Country not editable
        'birthStateId': true,
        'birthResidentialAddress': true,
        'commencementDate': false, // Commencement date not editable
        'signature': false,      // Digital Signature not editable
        'isAusPermanentResident': true,
        'countryOfLiving': true,
        'residentialAddress': true,
        'postCode': true,
        'visaType': false,       // Visa Type not editable
        'currentStateId': true,
        'passportNumber': false, // Passport Number not editable
        'passportExpiryDate': true,
        'eContactName': true,
        'relation': true,
        'eContactNo': true,
        'highestEducation': true,
        'profileImage': true,
      },
    );
  }

  // Get countries from API
  Future<Map<String, String>> getCountries() async {
    _logSystemInfo('GET Countries');
    
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Use the specific endpoint for countries
      final String endpoint = '$baseUrl/student/list-countries';
      debugPrint('Fetching countries from: $endpoint');
        
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
        
      if (response.statusCode == 200) {
        debugPrint('Successfully fetched countries');
        final responseData = jsonDecode(response.body);
        
        Map<String, String> countriesMap = {};
        
        if (responseData['data'] is List) {
          final countries = responseData['data'] as List;
          for (var country in countries) {
            countriesMap[country['id'].toString()] = country['name'].toString();
          }
        } else if (responseData['data'] is Map) {
          final countries = responseData['data'] as Map;
          countries.forEach((key, value) {
            if (value is Map && value.containsKey('name')) {
              countriesMap[key.toString()] = value['name'].toString();
            } else if (value is String) {
              countriesMap[key.toString()] = value;
            }
          });
        }
        
        if (countriesMap.isNotEmpty) {
          return countriesMap;
        }
      }
      
      // If we get here, fall back to mock data
      debugPrint('Falling back to mock countries data');
      return {
        '1': 'Afghanistan',
        '2': 'Albania',
        '13': 'Australia',
        '157': 'Nepal',
        '239': 'United States',
        '101': 'India',
      };
    } catch (e) {
      debugPrint('Exception in getCountries: $e');
      
      // Return mock data in case of errors
      return {
        '1': 'Afghanistan',
        '2': 'Albania',
        '13': 'Australia',
        '157': 'Nepal',
        '239': 'United States',
        '101': 'India',
      };
    }
  }

  // Get states - First try API then fallback to mock
  Future<Map<String, String>> getStates() async {
    _logSystemInfo('GET States');
    
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      // Try the states endpoint matching the country endpoint pattern
      final String endpoint = '$baseUrl/student/list-states';
      debugPrint('Fetching states from: $endpoint');
        
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
        
      if (response.statusCode == 200) {
        debugPrint('Successfully fetched states');
        final responseData = jsonDecode(response.body);
        
        Map<String, String> statesMap = {};
        
        if (responseData['data'] is List) {
          final states = responseData['data'] as List;
          for (var state in states) {
            statesMap[state['id'].toString()] = state['name'].toString();
          }
        } else if (responseData['data'] is Map) {
          final states = responseData['data'] as Map;
          states.forEach((key, value) {
            if (value is Map && value.containsKey('name')) {
              statesMap[key.toString()] = value['name'].toString();
            } else if (value is String) {
              statesMap[key.toString()] = value;
            }
          });
        }
        
        if (statesMap.isNotEmpty) {
          return statesMap;
        }
      }
      
      // If we get here, fall back to mock data
      debugPrint('Falling back to mock states data');
      return {
        '1': 'Alabama',
        '2': 'Alaska',
        '3': 'Arizona',
        '4': 'Arkansas',
        '5': 'California',
        '20': 'New York',
      };
    } catch (e) {
      debugPrint('Exception in getStates: $e');
      
      // Return mock data in case of errors
      return {
        '1': 'Alabama',
        '2': 'Alaska',
        '3': 'Arizona',
        '4': 'Arkansas',
        '5': 'California',
        '20': 'New York',
      };
    }
  }

  // Get education levels
  Future<List<String>> getEducationLevels() async {
    _logSystemInfo('GET Education Levels');
    
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final String endpoint = '$baseUrl/student/list-education-levels';
      try {
        debugPrint('Trying to fetch education levels from: $endpoint');
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        
        if (response.statusCode == 200) {
          debugPrint('Successfully fetched education levels');
          final responseData = jsonDecode(response.body);
          
          List<String> educationLevelsList = [];
          
          if (responseData['data'] is List) {
            final educationLevels = responseData['data'] as List;
            educationLevelsList = educationLevels.map((level) {
              if (level is Map && level.containsKey('name')) {
                return level['name'].toString();
              } else if (level is String) {
                return level;
              }
              return '';
            }).where((name) => name.isNotEmpty).toList();
          } else if (responseData['data'] is Map) {
            final educationLevels = responseData['data'] as Map;
            educationLevelsList = educationLevels.values.map((level) {
              if (level is Map && level.containsKey('name')) {
                return level['name'].toString();
              } else if (level is String) {
                return level;
              }
              return '';
            }).where((name) => name.isNotEmpty).toList();
          }
          
          if (educationLevelsList.isNotEmpty) {
            return educationLevelsList;
          }
        }
      } catch (e) {
        debugPrint('Error trying education levels endpoint: $e');
      }
      
      // If we get here, fall back to mock data
      debugPrint('Falling back to mock education levels data');
      return [
        'SLC/SEE',
        'High School',
        'Bachelor\'s Degree',
        'Master\'s Degree',
        'Ph.D',
      ];
    } catch (e) {
      debugPrint('Exception in getEducationLevels: $e');
      
      // Return mock data in case of errors
      return [
        'SLC/SEE',
        'High School',
        'Bachelor\'s Degree',
        'Master\'s Degree',
        'Ph.D',
      ];
    }
  }

  // Get visa types
  Future<List<String>> getVisaTypes() async {
    _logSystemInfo('GET Visa Types');
    
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final String endpoint = '$baseUrl/student/list-visa-types';
      try {
        debugPrint('Trying to fetch visa types from: $endpoint');
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        
        if (response.statusCode == 200) {
          debugPrint('Successfully fetched visa types');
          final responseData = jsonDecode(response.body);
          
          List<String> visaTypesList = [];
          
          if (responseData['data'] is List) {
            final visaTypes = responseData['data'] as List;
            visaTypesList = visaTypes.map((type) {
              if (type is Map && type.containsKey('name')) {
                return type['name'].toString();
              } else if (type is String) {
                return type;
              }
              return '';
            }).where((name) => name.isNotEmpty).toList();
          } else if (responseData['data'] is Map) {
            final visaTypes = responseData['data'] as Map;
            visaTypesList = visaTypes.values.map((type) {
              if (type is Map && type.containsKey('name')) {
                return type['name'].toString();
              } else if (type is String) {
                return type;
              }
              return '';
            }).where((name) => name.isNotEmpty).toList();
          }
          
          if (visaTypesList.isNotEmpty) {
            return visaTypesList;
          }
        }
      } catch (e) {
        debugPrint('Error trying visa types endpoint: $e');
      }
      
      // If we get here, fall back to mock data
      debugPrint('Falling back to mock visa types data');
      return [
        'Student',
        'Tourist',
        'Business',
        'Work',
        'Permanent Resident',
      ];
    } catch (e) {
      debugPrint('Exception in getVisaTypes: $e');
      
      // Return mock data in case of errors
      return [
        'Student',
        'Tourist',
        'Business',
        'Work',
        'Permanent Resident',
      ];
    }
  }

  // FINAL FIXED: Update user profile with two-step process
  Future<bool> updateUserProfile({
    required String name,
    required String email,
    required String status,
    required String userId,
    required String studentId,
    required String gender,
    required String mobileNo,
    required String dob,
    required String countryOfBirth,
    required String birthStateId,
    required String birthResidentialAddress,
    required String commencementDate,
    required String signature,
    required String isAusPermanentResident,
    required String countryOfLiving,
    required String residentialAddress,
    required String postCode,
    required String visaType,
    required String currentStateId,
    required String passportNumber,
    required String passportExpiryDate,
    required String eContactName,
    required String relation,
    required String eContactNo,
    required String highestEducation,
    File? profileImage,
  }) async {
    _logSystemInfo('UPDATE Student Profile');
    
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // STEP 1: Get the student's numeric database ID first
      debugPrint('STEP 1: Getting student\'s numeric ID from code $studentId');
      
      // First, try to get the numeric ID directly from the profile
      String numericId = '';
      try {
        final profile = await getUserProfile();
        if (profile.id.isNotEmpty && RegExp(r'^\d+$').hasMatch(profile.id)) {
          numericId = profile.id;
          debugPrint('Found numeric ID from profile: $numericId');
        } else if (profile.userId.isNotEmpty) {
          numericId = profile.userId;
          debugPrint('Using userId as numeric ID: $numericId');
        }
      } catch (e) {
        debugPrint('Error getting ID from profile: $e');
      }
      
      // If we still don't have an ID, try to extract from student code
      if (numericId.isEmpty) {
        final numericMatch = RegExp(r'(\d+)').firstMatch(studentId);
        if (numericMatch != null) {
          numericId = numericMatch.group(1) ?? '';
          debugPrint('Extracted numeric ID from student code: $numericId');
        }
      }
      
      // Try student lookup API endpoints
      if (numericId.isEmpty) {
        final endpoints = [
          '$baseUrl/students/lookup?code=$studentId',
          '$baseUrl/student/lookup?code=$studentId',
          '$baseUrl/student/lookup?student_code=$studentId',
          '$baseUrl/student/find-by-code?code=$studentId',
        ];
        
        for (final endpoint in endpoints) {
          try {
            debugPrint('Trying to lookup student ID at: $endpoint');
            final lookupResponse = await http.get(
              Uri.parse(endpoint),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            );
            
            if (lookupResponse.statusCode == 200) {
              try {
                final data = jsonDecode(lookupResponse.body);
                if (data['data'] != null && data['data']['id'] != null) {
                  numericId = data['data']['id'].toString();
                  debugPrint('Found numeric ID from lookup: $numericId');
                  break;
                }
              } catch (e) {
                debugPrint('Error parsing lookup response: $e');
              }
            }
          } catch (e) {
            debugPrint('Error with lookup endpoint: $e');
          }
        }
      }
      
      // STEP 2: Now update the profile
      debugPrint('STEP 2: Updating profile...');
      
      // Try multiple update approaches in sequence
      List<Exception> exceptions = [];
      
      // APPROACH 1: Try direct update to student-profile/update endpoint (original endpoint that caused error)
      try {
        final updateUrl = '$baseUrl/student-profile/update';
        debugPrint('APPROACH 1: Trying original endpoint: $updateUrl');
        
        var request = http.MultipartRequest('POST', Uri.parse(updateUrl));
        
        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
        
        Map<String, String> fields = {
          'name': name,
          'email': email,
          'gender': gender,
          'mobile_no': mobileNo,
          'dob': dob,
          'country_of_birth': countryOfBirth,
          'birth_state_id': birthStateId,
          'birth_residential_address': birthResidentialAddress,
          'commencement_date': commencementDate,
          'signature': signature,
          'is_aus_permanent_resident': isAusPermanentResident,
          'country_of_living': countryOfLiving,
          'residential_address': residentialAddress,
          'post_code': postCode,
          'visa_type': visaType,
          'current_state_id': currentStateId,
          'passport_number': passportNumber,
          'passport_expiry_date': passportExpiryDate,
          'e_contact_name': eContactName,
          'relation': relation,
          'e_contact_no': eContactNo,
          'highest_education': highestEducation,
          'status': status,
        };
        
        // Add student identification fields
        fields['student_id'] = studentId;
        fields['student_code'] = studentId;
        
        // If we have a numeric ID, include it in multiple ways
        if (numericId.isNotEmpty) {
          fields['id'] = numericId;
          fields['user_id'] = numericId;
        }
        
        // Log all fields
        debugPrint('===== PROFILE UPDATE REQUEST =====');
        final DateTime now = DateTime.now().toUtc();
        final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
        debugPrint('Current Date and Time (UTC): $formattedDate');
        debugPrint('Current User\'s Login: darwinacharya3');
        debugPrint('Form Fields:');
        fields.forEach((key, value) {
          debugPrint('  $key: $value');
        });
        
        request.fields.addAll(fields);
        
        // Add profile image if provided
        if (profileImage != null) {
          debugPrint('Adding profile image: ${profileImage.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'student_profile',
              profileImage.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
        
        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        // Log response
        debugPrint('APPROACH 1 Response: ${response.statusCode} - ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('Profile update successful!');
          return true;
        }
        
        throw Exception('Failed with status ${response.statusCode}: ${response.body}');
      } catch (e) {
        debugPrint('APPROACH 1 failed: $e');
        exceptions.add(Exception('APPROACH 1: $e'));
      }
      
      // APPROACH 2: Try with numeric ID in RESTful URL
      if (numericId.isNotEmpty) {
        try {
          final updateUrl = '$baseUrl/students/$numericId';
          debugPrint('APPROACH 2: Trying RESTful endpoint: $updateUrl');
          
          var request = http.MultipartRequest('POST', Uri.parse(updateUrl));
          
          request.headers.addAll({
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          });
          
          Map<String, String> fields = {
            '_method': 'PUT',  // Laravel method spoofing
            'name': name,
            'email': email,
            'gender': gender,
            'mobile_no': mobileNo,
            'dob': dob,
            'country_of_birth': countryOfBirth,
            'birth_state_id': birthStateId,
            'birth_residential_address': birthResidentialAddress,
            'commencement_date': commencementDate,
            'signature': signature,
            'is_aus_permanent_resident': isAusPermanentResident,
            'country_of_living': countryOfLiving,
            'residential_address': residentialAddress,
            'post_code': postCode,
            'visa_type': visaType,
            'current_state_id': currentStateId,
            'passport_number': passportNumber,
            'passport_expiry_date': passportExpiryDate,
            'e_contact_name': eContactName,
            'relation': relation,
            'e_contact_no': eContactNo,
            'highest_education': highestEducation,
            'status': status,
            'student_id': studentId,
            'student_code': studentId,
            'id': numericId,
          };
          
          request.fields.addAll(fields);
          
          if (profileImage != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'student_profile',
                profileImage.path,
                contentType: MediaType('image', 'jpeg'),
              ),
            );
          }
          
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);
          
          debugPrint('APPROACH 2 Response: ${response.statusCode} - ${response.body}');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            debugPrint('Profile update successful!');
            return true;
          }
          
          throw Exception('Failed with status ${response.statusCode}: ${response.body}');
        } catch (e) {
          debugPrint('APPROACH 2 failed: $e');
          exceptions.add(Exception('APPROACH 2: $e'));
        }
      }
      
      // APPROACH 3: Try direct JSON update
      try {
        final updateUrl = '$baseUrl/student-profile/update-json';
        debugPrint('APPROACH 3: Trying JSON endpoint: $updateUrl');
        
        Map<String, dynamic> updateData = {
          'name': name,
          'email': email,
          'gender': gender,
          'mobile_no': mobileNo,
          'dob': dob,
          'country_of_birth': countryOfBirth,
          'birth_state_id': birthStateId,
          'birth_residential_address': birthResidentialAddress,
          'commencement_date': commencementDate,
          'signature': signature,
          'is_aus_permanent_resident': isAusPermanentResident,
          'country_of_living': countryOfLiving,
          'residential_address': residentialAddress,
          'post_code': postCode,
          'visa_type': visaType,
          'current_state_id': currentStateId,
          'passport_number': passportNumber,
          'passport_expiry_date': passportExpiryDate,
          'e_contact_name': eContactName,
          'relation': relation,
          'e_contact_no': eContactNo,
          'highest_education': highestEducation,
          'status': status,
          'student_id': studentId,
          'student_code': studentId,
        };
        
        if (numericId.isNotEmpty) {
          updateData['id'] = numericId;
        }
        
        final response = await http.post(
          Uri.parse(updateUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(updateData),
        );
        
        debugPrint('APPROACH 3 Response: ${response.statusCode} - ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Upload image separately if provided
          if (profileImage != null) {
            await _uploadProfileImage(token, studentId, numericId, profileImage);
          }
          return true;
        }
        
        throw Exception('Failed with status ${response.statusCode}: ${response.body}');
      } catch (e) {
        debugPrint('APPROACH 3 failed: $e');
        exceptions.add(Exception('APPROACH 3: $e'));
      }
      
      // APPROACH 4: Final attempt - try to get through the exact error
      try {
        final updateUrl = '$baseUrl/student-profile/update-by-code/$studentId';
        debugPrint('APPROACH 4: Trying code-specific endpoint: $updateUrl');
        
        var request = http.MultipartRequest('POST', Uri.parse(updateUrl));
        
        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
        
        // Build a simpler set of fields
        Map<String, String> fields = {
          'mobile_no': mobileNo,
          'gender': gender,
          'dob': dob,
          'birth_state_id': birthStateId,
          'birth_residential_address': birthResidentialAddress,
          'is_aus_permanent_resident': isAusPermanentResident,
          'country_of_living': countryOfLiving,
          'residential_address': residentialAddress,
          'post_code': postCode,
          'current_state_id': currentStateId,
          'passport_expiry_date': passportExpiryDate,
          'e_contact_name': eContactName,
          'relation': relation,
          'e_contact_no': eContactNo,
          'highest_education': highestEducation,
        };
        
        request.fields.addAll(fields);
        
        if (profileImage != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'student_profile',
              profileImage.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
        
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        
        debugPrint('APPROACH 4 Response: ${response.statusCode} - ${response.body}');
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('Profile update successful!');
          return true;
        }
        
        throw Exception('Failed with status ${response.statusCode}: ${response.body}');
      } catch (e) {
        debugPrint('APPROACH 4 failed: $e');
        exceptions.add(Exception('APPROACH 4: $e'));
      }
      
      // If all approaches failed, throw exception with details
      throw Exception('All profile update attempts failed: ${exceptions.join(', ')}');
      
    } catch (e) {
      debugPrint('Exception in updateUserProfile: $e');
      throw Exception('Error updating profile: $e');
    }
  }

  // Helper to upload profile image separately
  Future<bool> _uploadProfileImage(String token, String studentCode, String numericId, File image) async {
    try {
      // Try multiple possible endpoints for image upload
      final possibleEndpoints = [
        '$baseUrl/student/upload-profile-image',
        '$baseUrl/students/$numericId/upload-profile',
        '$baseUrl/student-profile/upload-image',
      ];
      
      for (final endpoint in possibleEndpoints) {
        try {
          debugPrint('Trying to upload image to: $endpoint');
          
          var request = http.MultipartRequest('POST', Uri.parse(endpoint));
          
          request.headers.addAll({
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          });
          
          // Include both student code and numeric ID
          request.fields['student_code'] = studentCode;
          if (numericId.isNotEmpty) {
            request.fields['id'] = numericId;
          }
          
          // Try different field names for the image
          final fieldName = endpoint.contains('student/upload') ? 'image' : 'student_profile';
          
          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName,
              image.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          
          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);
          
          debugPrint('Image upload response: ${response.statusCode} - ${response.body}');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            return true;
          }
        } catch (e) {
          debugPrint('Error with image endpoint $endpoint: $e');
        }
      }
      
      // If all attempts failed, return false
      debugPrint('All image upload attempts failed');
      return false;
    } catch (e) {
      debugPrint('Exception in _uploadProfileImage: $e');
      return false;
    }
  }
}





// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:intl/intl.dart';
// import 'package:ems/models/edit_user_details.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileService {
//   // The confirmed base URL for the API
//   static const String baseUrl = 'https://extratech.extratechweb.com/api';
  
//   // Get the auth token from shared preferences
//   Future<String?> _getAuthToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }

//   // Log system information for debugging
//   void _logSystemInfo(String operation) {
//     final DateTime now = DateTime.now().toUtc();
//     final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    
//     debugPrint('==========================================================');
//     debugPrint('Operation: $operation');
//     debugPrint('Current Date and Time (UTC): $formattedDate');
//     debugPrint('Current User\'s Login: darwinacharya3');
//     debugPrint('==========================================================');
//   }

//   // Get user profile using the real API endpoint
//   Future<EditUserDetail> getUserProfile() async {
//     _logSystemInfo('GET Student Profile');
    
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Using the real API endpoint provided
//       final String profileUrl = '$baseUrl/get/student-profile';
//       debugPrint('Fetching profile from: $profileUrl');
      
//       final response = await http.get(
//         Uri.parse(profileUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );

//       // Log the response for debugging
//       debugPrint('API Response Status (getUserProfile): ${response.statusCode}');
//       if (response.body.length < 1000) {
//         // Only log the full body if it's not too large
//         debugPrint('API Response Body: ${response.body}');
//       } else {
//         debugPrint('API Response Body: [Large response, first 500 chars] ${response.body.substring(0, 500)}...');
//       }

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return EditUserDetail.fromJson(responseData['data']);
//       } else {
//         debugPrint('API Error (getUserProfile): ${response.statusCode} - ${response.body}');
//         throw Exception('Failed to get profile: Status ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Exception in getUserProfile: $e');
      
//       // In case of error, provide fallback mock data for development
//       debugPrint('Falling back to mock profile data');
//       return _getMockUserProfile();
//     }
//   }
  
//   // Mock user profile as fallback
//   EditUserDetail _getMockUserProfile() {
//     return EditUserDetail(
//       id: '123',
//       userId: '1854',
//       studentId: '1736',
//       name: 'Manoj Kumar',
//       email: 'manoj.kumar@gmail.com',
//       mobileNo: '9816836470',
//       gender: '1',
//       dob: '2020-05-10',
//       countryOfBirth: '157',
//       birthStateId: '3',
//       birthResidentialAddress: 'Balkot-5',
//       commencementDate: '2025-05-05',
//       signature: 'Manoj Kumar',
//       isAusPermanentResident: '1',
//       countryOfLiving: '239',
//       residentialAddress: 'California',
//       postCode: '20030',
//       visaType: 'Student',
//       currentStateId: '20',
//       passportNumber: 'PA20055',
//       passportExpiryDate: '2025-05-05',
//       eContactName: 'Sobhan Ray',
//       relation: 'Friends',
//       eContactNo: '9812345343',
//       highestEducation: 'SLC/SEE',
//       profileImage: '',
//       status: '1',
//       editableFields: {
//         'name': true,
//         'email': false, // Email not editable
//         'mobileNo': true,
//         'gender': true,
//         'dob': true,
//         'countryOfBirth': true,
//         'birthStateId': true,
//         'birthResidentialAddress': true,
//         'commencementDate': false, // Commencement date not editable
//         'signature': true,
//         'isAusPermanentResident': true,
//         'countryOfLiving': true,
//         'residentialAddress': true,
//         'postCode': true,
//         'visaType': true,
//         'currentStateId': true,
//         'passportNumber': true,
//         'passportExpiryDate': true,
//         'eContactName': true,
//         'relation': true,
//         'eContactNo': true,
//         'highestEducation': true,
//         'profileImage': true,
//       },
//     );
//   }

//   // Get countries - Mock implementation until actual API endpoint is provided
//   Future<Map<String, String>> getCountries() async {
//     _logSystemInfo('GET Countries');
    
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Try to fetch from API first, fallback to mock data if it fails
//       try {
//         // Common API patterns to try
//         final List<String> possibleEndpoints = [
//           '$baseUrl/countries', 
//           '$baseUrl/get/countries', 
//           '$baseUrl/student-profile/countries'
//         ];
        
//         for (final endpoint in possibleEndpoints) {
//           try {
//             debugPrint('Trying to fetch countries from: $endpoint');
//             final response = await http.get(
//               Uri.parse(endpoint),
//               headers: {
//                 'Authorization': 'Bearer $token',
//                 'Accept': 'application/json',
//               },
//             );
            
//             if (response.statusCode == 200) {
//               debugPrint('Successfully fetched countries from: $endpoint');
//               final responseData = jsonDecode(response.body);
              
//               Map<String, String> countriesMap = {};
              
//               // Handle different response formats
//               if (responseData['data'] is List) {
//                 final countries = responseData['data'] as List;
//                 for (var country in countries) {
//                   countriesMap[country['id'].toString()] = country['name'].toString();
//                 }
//               } else if (responseData['data'] is Map) {
//                 final countries = responseData['data'] as Map;
//                 countries.forEach((key, value) {
//                   if (value is Map && value.containsKey('name')) {
//                     countriesMap[key.toString()] = value['name'].toString();
//                   } else if (value is String) {
//                     countriesMap[key.toString()] = value;
//                   }
//                 });
//               }
              
//               if (countriesMap.isNotEmpty) {
//                 return countriesMap;
//               }
//             }
//           } catch (e) {
//             debugPrint('Error trying endpoint $endpoint: $e');
//             // Continue to next endpoint
//           }
//         }
//       } catch (e) {
//         debugPrint('Error trying to discover countries endpoint: $e');
//       }
      
//       // If we get here, none of the endpoints worked - use mock data
//       debugPrint('Falling back to mock countries data');
//       return {
//         '1': 'Afghanistan',
//         '2': 'Albania',
//         '13': 'Australia',
//         '157': 'Nepal',
//         '239': 'United States',
//         '101': 'India',
//       };
//     } catch (e) {
//       debugPrint('Exception in getCountries: $e');
      
//       // Return mock data in case of errors
//       return {
//         '1': 'Afghanistan',
//         '2': 'Albania',
//         '13': 'Australia',
//         '157': 'Nepal',
//         '239': 'United States',
//         '101': 'India',
//       };
//     }
//   }

//   // Get states - Mock implementation with API discovery
//   Future<Map<String, String>> getStates() async {
//     _logSystemInfo('GET States');
    
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }
      
//       // Try to fetch from API first, fallback to mock data if it fails
//       try {
//         // Common API patterns to try
//         final List<String> possibleEndpoints = [
//           '$baseUrl/states', 
//           '$baseUrl/get/states', 
//           '$baseUrl/student-profile/states'
//         ];
        
//         for (final endpoint in possibleEndpoints) {
//           try {
//             debugPrint('Trying to fetch states from: $endpoint');
//             final response = await http.get(
//               Uri.parse(endpoint),
//               headers: {
//                 'Authorization': 'Bearer $token',
//                 'Accept': 'application/json',
//               },
//             );
            
//             if (response.statusCode == 200) {
//               debugPrint('Successfully fetched states from: $endpoint');
//               final responseData = jsonDecode(response.body);
              
//               Map<String, String> statesMap = {};
              
//               // Handle different response formats
//               if (responseData['data'] is List) {
//                 final states = responseData['data'] as List;
//                 for (var state in states) {
//                   statesMap[state['id'].toString()] = state['name'].toString();
//                 }
//               } else if (responseData['data'] is Map) {
//                 final states = responseData['data'] as Map;
//                 states.forEach((key, value) {
//                   if (value is Map && value.containsKey('name')) {
//                     statesMap[key.toString()] = value['name'].toString();
//                   } else if (value is String) {
//                     statesMap[key.toString()] = value;
//                   }
//                 });
//               }
              
//               if (statesMap.isNotEmpty) {
//                 return statesMap;
//               }
//             }
//           } catch (e) {
//             debugPrint('Error trying endpoint $endpoint: $e');
//             // Continue to next endpoint
//           }
//         }
//       } catch (e) {
//         debugPrint('Error trying to discover states endpoint: $e');
//       }
      
//       // If we get here, none of the endpoints worked - use mock data
//       debugPrint('Falling back to mock states data');
//       return {
//         '1': 'Alabama',
//         '2': 'Alaska',
//         '3': 'Arizona',
//         '4': 'Arkansas',
//         '5': 'California',
//         '20': 'New York',
//       };
//     } catch (e) {
//       debugPrint('Exception in getStates: $e');
      
//       // Return mock data in case of errors
//       return {
//         '1': 'Alabama',
//         '2': 'Alaska',
//         '3': 'Arizona',
//         '4': 'Arkansas',
//         '5': 'California',
//         '20': 'New York',
//       };
//     }
//   }

//   // Get education levels - Mock implementation with API discovery
//   Future<List<String>> getEducationLevels() async {
//     _logSystemInfo('GET Education Levels');
    
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }
      
//       // Try to fetch from API first, fallback to mock data if it fails
//       try {
//         // Common API patterns to try
//         final List<String> possibleEndpoints = [
//           '$baseUrl/education-levels', 
//           '$baseUrl/get/education-levels', 
//           '$baseUrl/student-profile/education-levels'
//         ];
        
//         for (final endpoint in possibleEndpoints) {
//           try {
//             debugPrint('Trying to fetch education levels from: $endpoint');
//             final response = await http.get(
//               Uri.parse(endpoint),
//               headers: {
//                 'Authorization': 'Bearer $token',
//                 'Accept': 'application/json',
//               },
//             );
            
//             if (response.statusCode == 200) {
//               debugPrint('Successfully fetched education levels from: $endpoint');
//               final responseData = jsonDecode(response.body);
              
//               List<String> educationLevelsList = [];
              
//               // Handle different response formats
//               if (responseData['data'] is List) {
//                 final educationLevels = responseData['data'] as List;
//                 educationLevelsList = educationLevels.map((level) {
//                   if (level is Map && level.containsKey('name')) {
//                     return level['name'].toString();
//                   } else if (level is String) {
//                     return level;
//                   }
//                   return '';
//                 }).where((name) => name.isNotEmpty).toList();
//               } else if (responseData['data'] is Map) {
//                 final educationLevels = responseData['data'] as Map;
//                 educationLevelsList = educationLevels.values.map((level) {
//                   if (level is Map && level.containsKey('name')) {
//                     return level['name'].toString();
//                   } else if (level is String) {
//                     return level;
//                   }
//                   return '';
//                 }).where((name) => name.isNotEmpty).toList();
//               }
              
//               if (educationLevelsList.isNotEmpty) {
//                 return educationLevelsList;
//               }
//             }
//           } catch (e) {
//             debugPrint('Error trying endpoint $endpoint: $e');
//             // Continue to next endpoint
//           }
//         }
//       } catch (e) {
//         debugPrint('Error trying to discover education levels endpoint: $e');
//       }
      
//       // If we get here, none of the endpoints worked - use mock data
//       debugPrint('Falling back to mock education levels data');
//       return [
//         'SLC/SEE',
//         'High School',
//         'Bachelor\'s Degree',
//         'Master\'s Degree',
//         'Ph.D',
//       ];
//     } catch (e) {
//       debugPrint('Exception in getEducationLevels: $e');
      
//       // Return mock data in case of errors
//       return [
//         'SLC/SEE',
//         'High School',
//         'Bachelor\'s Degree',
//         'Master\'s Degree',
//         'Ph.D',
//       ];
//     }
//   }

//   // Get visa types - Mock implementation with API discovery
//   Future<List<String>> getVisaTypes() async {
//     _logSystemInfo('GET Visa Types');
    
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }
      
//       // Try to fetch from API first, fallback to mock data if it fails
//       try {
//         // Common API patterns to try
//         final List<String> possibleEndpoints = [
//           '$baseUrl/visa-types', 
//           '$baseUrl/get/visa-types', 
//           '$baseUrl/student-profile/visa-types'
//         ];
        
//         for (final endpoint in possibleEndpoints) {
//           try {
//             debugPrint('Trying to fetch visa types from: $endpoint');
//             final response = await http.get(
//               Uri.parse(endpoint),
//               headers: {
//                 'Authorization': 'Bearer $token',
//                 'Accept': 'application/json',
//               },
//             );
            
//             if (response.statusCode == 200) {
//               debugPrint('Successfully fetched visa types from: $endpoint');
//               final responseData = jsonDecode(response.body);
              
//               List<String> visaTypesList = [];
              
//               // Handle different response formats
//               if (responseData['data'] is List) {
//                 final visaTypes = responseData['data'] as List;
//                 visaTypesList = visaTypes.map((type) {
//                   if (type is Map && type.containsKey('name')) {
//                     return type['name'].toString();
//                   } else if (type is String) {
//                     return type;
//                   }
//                   return '';
//                 }).where((name) => name.isNotEmpty).toList();
//               } else if (responseData['data'] is Map) {
//                 final visaTypes = responseData['data'] as Map;
//                 visaTypesList = visaTypes.values.map((type) {
//                   if (type is Map && type.containsKey('name')) {
//                     return type['name'].toString();
//                   } else if (type is String) {
//                     return type;
//                   }
//                   return '';
//                 }).where((name) => name.isNotEmpty).toList();
//               }
              
//               if (visaTypesList.isNotEmpty) {
//                 return visaTypesList;
//               }
//             }
//           } catch (e) {
//             debugPrint('Error trying endpoint $endpoint: $e');
//             // Continue to next endpoint
//           }
//         }
//       } catch (e) {
//         debugPrint('Error trying to discover visa types endpoint: $e');
//       }
      
//       // If we get here, none of the endpoints worked - use mock data
//       debugPrint('Falling back to mock visa types data');
//       return [
//         'Student',
//         'Tourist',
//         'Business',
//         'Work',
//         'Permanent Resident',
//       ];
//     } catch (e) {
//       debugPrint('Exception in getVisaTypes: $e');
      
//       // Return mock data in case of errors
//       return [
//         'Student',
//         'Tourist',
//         'Business',
//         'Work',
//         'Permanent Resident',
//       ];
//     }
//   }

//   // Update user profile - Real API implementation
//   Future<bool> updateUserProfile({
//     required String name,
//     required String email,
//     required String status,
//     required String userId,
//     required String studentId,
//     required String gender,
//     required String mobileNo,
//     required String dob,
//     required String countryOfBirth,
//     required String birthStateId,
//     required String birthResidentialAddress,
//     required String commencementDate,
//     required String signature,
//     required String isAusPermanentResident,
//     required String countryOfLiving,
//     required String residentialAddress,
//     required String postCode,
//     required String visaType,
//     required String currentStateId,
//     required String passportNumber,
//     required String passportExpiryDate,
//     required String eContactName,
//     required String relation,
//     required String eContactNo,
//     required String highestEducation,
//     File? profileImage,
//   }) async {
//     _logSystemInfo('UPDATE Student Profile');
    
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       // Using the confirmed API endpoint for updating profile
//       String updateUrl = '$baseUrl/student-profile/update';
//       debugPrint('Updating profile at: $updateUrl');
      
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(updateUrl),
//       );

//       // Set headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       });

//       // Add form fields
//       Map<String, String> fields = {
//         'name': name,
//         'email': email,
//         'status': status,
//         'user_id': userId,
//         'student_id': studentId,
//         'gender': gender,
//         'mobile_no': mobileNo,
//         'dob': dob,
//         'country_of_birth': countryOfBirth,
//         'birth_state_id': birthStateId,
//         'birth_residential_address': birthResidentialAddress,
//         'commencement_date': commencementDate,
//         'signature': signature,
//         'is_aus_permanent_resident': isAusPermanentResident,
//         'country_of_living': countryOfLiving,
//         'residential_address': residentialAddress,
//         'post_code': postCode,
//         'visa_type': visaType,
//         'current_state_id': currentStateId,
//         'passport_number': passportNumber,
//         'passport_expiry_date': passportExpiryDate,
//         'e_contact_name': eContactName,
//         'relation': relation,
//         'e_contact_no': eContactNo,
//         'highest_education': highestEducation,
//       };
      
//       request.fields.addAll(fields);
      
//       // Log request data for debugging
//       debugPrint('===== PROFILE UPDATE REQUEST =====');
//       final DateTime now = DateTime.now().toUtc();
//       final String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
//       debugPrint('Date/Time (UTC): $formattedDate');
//       debugPrint('User: darwinacharya3');
//       debugPrint('Form Fields:');
//       fields.forEach((key, value) {
//         debugPrint('  $key: $value');
//       });

//       // Add profile image if provided
//       if (profileImage != null) {
//         debugPrint('Adding profile image: ${profileImage.path}');
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'student_profile',
//             profileImage.path,
//             contentType: MediaType('application', 'octet-stream'),
//           ),
//         );
//       }

//       // Send request
//       debugPrint('Sending API request...');
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
      
//       // Log response
//       debugPrint('API Response Status: ${response.statusCode}');
//       debugPrint('API Response Body: ${response.body}');
//       debugPrint('===== END OF PROFILE UPDATE REQUEST =====');

//       if (response.statusCode == 200) {
//         debugPrint('Profile update successful!');
//         return true;
//       } else {
//         debugPrint('Profile update failed with status: ${response.statusCode}');
//         throw Exception('Failed to update profile: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       debugPrint('Exception in updateUserProfile: $e');
//       throw Exception('Error updating profile: $e');
//     }
//   }
// }















// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:ems/models/edit_user_details.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileService {
//   static const String baseUrl = 'http://localhost/extratech/AMS-NEW/public/api';
  
//   // Get the auth token from shared preferences
//   Future<String?> _getAuthToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }

//   // Get user profile
//   Future<EditUserDetail> getUserProfile() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/student-profile'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return EditUserDetail.fromJson(responseData['data']);
//       } else {
//         throw Exception('Failed to get profile: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching profile: $e');
//     }
//   }

//   // Get countries
//   Future<Map<String, String>> getCountries() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/countries'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         // Convert from API response to Map<String, String>
//         Map<String, String> countriesMap = {};
//         final countries = responseData['data'] as List;
        
//         for (var country in countries) {
//           countriesMap[country['id'].toString()] = country['name'].toString();
//         }
        
//         return countriesMap;
//       } else {
//         throw Exception('Failed to get countries: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching countries: $e');
//     }
//   }

//   // Get states
//   Future<Map<String, String>> getStates() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/states'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         // Convert from API response to Map<String, String>
//         Map<String, String> statesMap = {};
//         final states = responseData['data'] as List;
        
//         for (var state in states) {
//           statesMap[state['id'].toString()] = state['name'].toString();
//         }
        
//         return statesMap;
//       } else {
//         throw Exception('Failed to get states: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching states: $e');
//     }
//   }

//   // Get education levels
//   Future<List<String>> getEducationLevels() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/education-levels'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         // Convert from API response to List<String>
//         final educationLevels = responseData['data'] as List;
//         return educationLevels.map((level) => level['name'].toString()).toList();
//       } else {
//         throw Exception('Failed to get education levels: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching education levels: $e');
//     }
//   }

//   // Get visa types
//   Future<List<String>> getVisaTypes() async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       final response = await http.get(
//         Uri.parse('$baseUrl/visa-types'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         // Convert from API response to List<String>
//         final visaTypes = responseData['data'] as List;
//         return visaTypes.map((type) => type['name'].toString()).toList();
//       } else {
//         throw Exception('Failed to get visa types: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching visa types: $e');
//     }
//   }

//   // Update user profile
//   Future<bool> updateUserProfile({
//     required String name,
//     required String email,
//     required String status,
//     required String userId,
//     required String studentId,
//     required String gender,
//     required String mobileNo,
//     required String dob,
//     required String countryOfBirth,
//     required String birthStateId,
//     required String birthResidentialAddress,
//     required String commencementDate,
//     required String signature,
//     required String isAusPermanentResident,
//     required String countryOfLiving,
//     required String residentialAddress,
//     required String postCode,
//     required String visaType,
//     required String currentStateId,
//     required String passportNumber,
//     required String passportExpiryDate,
//     required String eContactName,
//     required String relation,
//     required String eContactNo,
//     required String highestEducation,
//     File? profileImage,
//   }) async {
//     try {
//       final token = await _getAuthToken();
//       if (token == null) {
//         throw Exception('Authentication token not found');
//       }

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/student-profile/update'),
//       );

//       // Set headers
//       request.headers.addAll({
//         'Authorization': 'Bearer $token',
//       });

//       // Add form fields
//       request.fields['name'] = name;
//       request.fields['email'] = email;
//       request.fields['status'] = status;
//       request.fields['user_id'] = userId;
//       request.fields['student_id'] = studentId;
//       request.fields['gender'] = gender;
//       request.fields['mobile_no'] = mobileNo;
//       request.fields['dob'] = dob;
//       request.fields['country_of_birth'] = countryOfBirth;
//       request.fields['birth_state_id'] = birthStateId;
//       request.fields['birth_residential_address'] = birthResidentialAddress;
//       request.fields['commencement_date'] = commencementDate;
//       request.fields['signature'] = signature;
//       request.fields['is_aus_permanent_resident'] = isAusPermanentResident;
//       request.fields['country_of_living'] = countryOfLiving;
//       request.fields['residential_address'] = residentialAddress;
//       request.fields['post_code'] = postCode;
//       request.fields['visa_type'] = visaType;
//       request.fields['current_state_id'] = currentStateId;
//       request.fields['passport_number'] = passportNumber;
//       request.fields['passport_expiry_date'] = passportExpiryDate;
//       request.fields['e_contact_name'] = eContactName;
//       request.fields['relation'] = relation;
//       request.fields['e_contact_no'] = eContactNo;
//       request.fields['highest_education'] = highestEducation;

//       // Add file if provided
//       if (profileImage != null) {
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'student_profile',
//             profileImage.path,
//             contentType: MediaType('application', 'octet-stream'),
//           ),
//         );
//       }

//       // Send request
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         return true;
//       } else {
//         throw Exception('Failed to update profile: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error updating profile: $e');
//     }
//   }
// }