import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PassportCopiesWidget extends StatelessWidget{

  const PassportCopiesWidget({super.key});

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
          _buildSubHeader() 
          
        ],
      ),
    );
    
  }

  Widget _buildHeader(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Passport Copies',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      );
  }
}

Widget _buildSubHeader(){
  return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Text(
        'Click on file to see larger size.',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color.fromARGB(255, 227, 10, 169),
          fontWeight: FontWeight.w500,
        ),
      ),
  );
}