import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:periksa_kesehatan/pages/input/widgets/section_header.dart';
import 'package:periksa_kesehatan/pages/input/widgets/health_input_field.dart';

class HeartRateSection extends StatelessWidget {
  final TextEditingController controller;

  const HeartRateSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Detak Jantung'),
        const SizedBox(height: 12),
        HealthInputField(
          controller: controller,
          label: 'bpm (Normal: 60-100 bpm)',
          helperText: '',
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
        ),
      ],
    );
  }
}
