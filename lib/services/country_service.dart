import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ems/services/secure_storage_service.dart';

class CountryService {
  static const String baseUrl = 'https://extratech.extratechweb.com/api';
  
  // Store countries in memory to avoid repeated API calls
  static Map<int, String>? _countriesCache;
  
  // Get all countries from API
  static Future<Map<int, String>> getAllCountries() async {
    // Return cached data if available
    if (_countriesCache != null) {
      return _countriesCache!;
    }
    
    try {
      // Get stored credentials
      String? email = await SecureStorageService.getUserEmail();
      String? password = await SecureStorageService.getUserPassword();
      
      if (password == null) {
        throw Exception('User credentials not found');
      }

      // Make login request to get countries data
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password
        }),
      );

      if (loginResponse.statusCode == 200) {
        final data = json.decode(loginResponse.body);
        
        // Check if countries data exists in response
        if (data['countries'] != null) {
          // Create a map of country_id -> country_name
          Map<int, String> countries = {};
          for (var country in data['countries']) {
            countries[country['id']] = country['name'];
          }
          
          // Cache the result
          _countriesCache = countries;
          
          // Save the new token if it was provided
          if (data['token'] != null) {
            await SecureStorageService.saveToken(data['token']);
          }
          
          return countries;
        } else {
          throw Exception('Countries data not found in response');
        }
      } else {
        throw Exception('Failed to load countries: ${loginResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching countries: $e');
      return {}; // Return empty map in case of error
    }
  }
  
  // Get a specific country name by ID
  static Future<String> getCountryName(int? countryId) async {
    if (countryId == null) return 'Unknown';
    
    try {
      Map<int, String> countries = await getAllCountries();
      return countries[countryId] ?? 'Unknown';
    } catch (e) {
      debugPrint('Error getting country name: $e');
      return 'Unknown';
    }
  }
}