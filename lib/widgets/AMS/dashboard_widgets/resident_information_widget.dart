import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ems/models/user_detail.dart';
import 'package:ems/models/location_model.dart';


class ResidentialInformationWidget extends StatelessWidget {
  final UserDetail userDetail;
  final List<Country> countries;
  final List<StateModel> states;
  
  const ResidentialInformationWidget({
    super.key,
    required this.userDetail,
    required this.countries,
    required this.states,
  });

   String _getCountryName(String countryId) {
    final country = countries.firstWhere(
      (country) => country.id.toString() == countryId,
      orElse: () => Country(id: 0, name: 'Unknown'),
    );
    return country.name;
  }

  
 String _getStateName(String stateId) {
    final state = states.firstWhere(
      (state) => state.id.toString() == stateId,
      orElse: () => StateModel(id: 0, countryId: 0, stateName: 'Unknown'),
    );
    return state.stateName;
  }

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
            spreadRadius: 0.5,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSubHeader(),
          _buildPermanentResidenceQuestion(),
          _buildResidentialInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        'Current Residential Information',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color : const Color(0xFF111213)
        ),
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Residential information',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF205EB5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

   Widget _buildPermanentResidenceQuestion() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you an permanent residence?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111213)
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userDetail.isAusPermanentResident == '1' ? 'Yes' : 'No',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Color(0xFFA1A1A1),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildResidentialInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.flag_outlined,
            'Currently Living Country',
            _getCountryName(userDetail.countryOfLiving),
          ),
          _buildInfoRow(
            Icons.account_balance,
            'State',
            _getStateName(userDetail.currentStateId),
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Residential Address',
            userDetail.residentialAddress,
          ),
          _buildInfoRow(
            Icons.mail_outline,
            'Postal Code',
            userDetail.postCode,
          ),
          _buildInfoRow(
            Icons.card_travel,
            'Visa Type',
            userDetail.visaType,
          ),
          _buildInfoRow(
            Icons.badge_outlined,
            'Passport Number',
            userDetail.passportNumber,
          ),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Passport Expiry Date',
            userDetail.passportExpiryDate,
          ),
        ],
      ),
    );
  }
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
