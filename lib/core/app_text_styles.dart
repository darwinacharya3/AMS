import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Updated styles to match Figma dimensions
  
  static final TextStyle heading1 = TextStyle(
    color: AppColors.primaryBlue,
    fontSize: 22.0, // For 28px height
    fontWeight: FontWeight.bold,
    height: 1.27, // 28/22
  );
  
  static final TextStyle heading2 = TextStyle(
    color: AppColors.primaryBlue,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );
  
  static final TextStyle subtitle = TextStyle(
    color: AppColors.primaryBlue,
    fontSize: 16.0, // For 20px height
    fontWeight: FontWeight.w500,
    height: 1.25, // 20/16
  );
  
  static final TextStyle body = TextStyle(
    color: AppColors.darkGrey,
    fontSize: 13.0, // For 54px height with multiple lines
    height: 1.38, // For proper line spacing
  );
  
  static final TextStyle caption = TextStyle(
    color: AppColors.lightGrey,
    fontSize: 9.0, // For 13px height
    height: 1.44, // 13/9
  );
  
  static final TextStyle link = TextStyle(
    color: AppColors.primaryBlue,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
  );
  
  static final TextStyle menuLabel = TextStyle(
    color: AppColors.darkGrey,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
  );
  
  static final TextStyle eventTitle = TextStyle(
    color: Colors.black87,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
  );
  
  static final TextStyle eventSubtitle = TextStyle(
    color: Colors.black54,
    fontSize: 13.0,
  );
  
  static final TextStyle eventTimer = TextStyle(
    color: Colors.black54,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
  );
}