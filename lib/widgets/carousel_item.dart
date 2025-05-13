import 'package:flutter/material.dart';
import 'package:ems/core/app_colors.dart';
import 'package:ems/core/app_text_styles.dart';


class CarouselItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;

  const CarouselItem({
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading1,
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.subtitle,
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.accentPink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.school,
                    color: AppColors.accentPink,
                    size: 60,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}