import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/pages/input/widgets/device_item.dart';

class ConnectableDevicesSection extends StatelessWidget {
  final VoidCallback? onTensimeterConnect;
  final VoidCallback? onPulseOximeterConnect;
  final VoidCallback? onGlucometerConnect;
  final VoidCallback? onScaleConnect;

  const ConnectableDevicesSection({
    super.key,
    this.onTensimeterConnect,
    this.onPulseOximeterConnect,
    this.onGlucometerConnect,
    this.onScaleConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Alat yang Dapat Dihubungkan',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DeviceItem(
          icon: Icons.favorite,
          name: 'Tensimeter Digital',
          description: 'Tekanan darah otomatis',
          iconColor: AppColors.primary,
          onConnect: onTensimeterConnect ?? () {},
        ),
        DeviceItem(
          icon: Icons.favorite_border,
          name: 'Pulse Oximeter',
          description: 'Detak jantung & oksigen',
          iconColor: Colors.blue,
          onConnect: onPulseOximeterConnect ?? () {},
        ),
        DeviceItem(
          icon: Icons.water_drop_outlined,
          name: 'Glucometer Digital',
          description: 'Gula darah otomatis',
          iconColor: Colors.orange,
          onConnect: onGlucometerConnect ?? () {},
        ),
        DeviceItem(
          icon: Icons.monitor_weight_outlined,
          name: 'Timbangan Digital',
          description: 'Berat badan otomatis',
          iconColor: Colors.blue.shade300,
          onConnect: onScaleConnect ?? () {},
        ),
      ],
    );
  }
}
