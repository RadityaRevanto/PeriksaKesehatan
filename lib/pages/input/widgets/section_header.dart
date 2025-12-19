import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onConnect;

  const SectionHeader({
    super.key,
    required this.title,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (onConnect != null)
          ElevatedButton(
            onPressed: onConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.infoBg,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.link,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Hubungkan',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
