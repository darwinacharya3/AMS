import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/user_detail.dart';

class EmergencyContactWidget extends StatelessWidget {
  final UserDetail userDetail;

  const EmergencyContactWidget({
    Key? key,
    required this.userDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSubHeader(),
          _buildEmergencyContactInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Emergency Contact',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Text(
        'Emergency contact of student',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color.fromARGB(255, 227, 10, 169),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmergencyContactInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.person,
            'Full Name',
            userDetail.eContactName,
          ),
          _buildInfoRow(
            Icons.family_restroom,
            'Relation to Student',
            userDetail.relation,
          ),
          _buildInfoRow(
            Icons.phone,
            'Contact No',
            userDetail.eContactNo,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 227, 10, 169),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}