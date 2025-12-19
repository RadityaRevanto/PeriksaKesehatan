import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:periksa_kesehatan/pages/input/widgets/section_header.dart';
import 'package:periksa_kesehatan/pages/input/widgets/health_input_field.dart';

class WeightSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onConnect;

  const WeightSection({
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
          title: 'Berat Badan',
          onConnect: onConnect,
        ),
        const SizedBox(height: 12),
        HealthInputField(
          controller: controller,
          label: 'kg',
          helperText: '',
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
        ),
      ],
    );
  }
}
