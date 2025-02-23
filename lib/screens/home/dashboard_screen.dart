import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/widgets/custom_app_bar.dart';
import 'package:ems/widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_navigation.dart';
import 'package:ems/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ems/models/user_detail.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedItem = 'General';
  DateTime? _lastBackPressed;
  UserDetail? _userDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final email = await SecureStorageService.getUserEmail();
      debugPrint('Retrieved email from storage: $email');

      if (email != null) {
        final url = 'https://extratech.extratechweb.com/api/student/detail/$email';
        debugPrint('Making API request to: $url');

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        debugPrint('API Response Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _userDetail = UserDetail.fromJson(data);
              _isLoading = false;
            });
          }
        } else {
          throw Exception('Failed to load user details: ${response.statusCode}');
        }
      } else {
        throw Exception('No stored email found');
      }
    } catch (e) {
      debugPrint('Error in _loadUserDetails: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_lastBackPressed == null ||
        DateTime.now().difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  void _onItemSelected(String item) {
    setState(() {
      _selectedItem = item;
    });
    if (item == 'Logout') {
      SecureStorageService.clearCredentials().then((_) {
        CustomNavigation.navigateToScreen(item, context);
      });
    } else {
      CustomNavigation.navigateToScreen(item, context);
    }
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Student ID', _userDetail?.etId ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('Name', _userDetail?.name ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('Email', _userDetail?.email ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('Phone', _userDetail?.mobileNo ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('Address', _userDetail?.residentialAddress ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('Course', _userDetail?.courseName ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('Batch', _userDetail?.batchName ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('Visa Type', _userDetail?.visaType ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('DOB', _userDetail?.dob ?? 'N/A'),
            const Divider(height: 24),
            _buildInfoRow('Passport', _userDetail?.passportNumber ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading data:',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadUserDetails,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, ${_userDetail?.name ?? "User"}',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildInfoCard(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          title: _selectedItem,
          icon: Icons.person,
          showBackButton: false,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: _selectedItem,
          onItemSelected: _onItemSelected,
        ),
        body: _buildContent(),
      ),
    );
  }
}













