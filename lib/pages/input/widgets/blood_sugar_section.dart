import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:periksa_kesehatan/pages/input/widgets/section_header.dart';
import 'package:periksa_kesehatan/pages/input/widgets/health_input_field.dart';

class BloodSugarSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onConnect;

  const BloodSugarSection({
    super.key,
    required this.controller,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Gula Darah',
          onConnect: onConnect,
        ),
        const SizedBox(height: 12),
        HealthInputField(
          controller: controller,
          label: 'mg/dL (Normal puasa: 70-100 mg/dL)',
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
