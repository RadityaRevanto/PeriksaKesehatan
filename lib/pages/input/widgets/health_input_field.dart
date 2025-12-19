import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';

class HealthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String helperText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const HealthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.helperText,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.number,
            inputFormatters: inputFormatters,
            style: GoogleFonts.nunitoSans(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: '0',
              hintStyle: GoogleFonts.nunitoSans(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helperText,
          style: GoogleFonts.nunitoSans(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
