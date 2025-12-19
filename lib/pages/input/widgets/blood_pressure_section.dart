import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:periksa_kesehatan/pages/input/widgets/section_header.dart';
import 'package:periksa_kesehatan/pages/input/widgets/health_input_field.dart';

class BloodPressureSection extends StatelessWidget {
  final TextEditingController sistolikController;
  final TextEditingController diastolikController;
  final VoidCallback? onConnect;

  const BloodPressureSection({
    super.key,
    required this.sistolikController,
    required this.diastolikController,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Tekanan Darah',
          onConnect: onConnect,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: HealthInputField(
                controller: sistolikController,
                label: 'Sistolik (mmHg)',
                helperText: 'Normal: 90/60 - 120/80 mmHg',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HealthInputField(
                controller: diastolikController,
                label: 'Diastolik (mmHg)',
                helperText: '',
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
