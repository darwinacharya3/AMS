import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/user_detail.dart';

class EmergencyContactWidget extends StatelessWidget {
  final UserDetail userDetail;

  const EmergencyContactWidget({
    super.key,
    required this.userDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA1A1A1).withOpacity(0.25),
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
      padding: const EdgeInsets.all(10),
      child: Text(
        'Emergency Contact',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF111213)
        ),
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
  
      child: Text(
        'Emergency contact of student',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Color(0xFF205EB5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmergencyContactInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF205EB5),
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
                    color: const Color(0xFF111213)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Color(0xFFA1A1A1),
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