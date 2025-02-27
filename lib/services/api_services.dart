// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:ems/models/user_detail.dart';

// class ApiService {
//   static const String baseUrl = 'https://extratech.extratechweb.com/api';

//   static Future<UserDetail> getUserDetails(String email) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/student/detail/$email'),
//         headers: {
//           'Content-Type': 'application/json',
//           // Add any required headers (like authentication tokens) here
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         return UserDetail.fromJson(data);
//       } else {
//         throw Exception('Failed to load user details: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching user details: $e');
//     }
//   }
// }
