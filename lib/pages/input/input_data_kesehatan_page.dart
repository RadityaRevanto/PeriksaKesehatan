import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/pages/input/widgets/info_box.dart';
import 'package:periksa_kesehatan/pages/input/widgets/blood_pressure_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/blood_sugar_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/weight_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/heart_rate_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/activity_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/connectable_devices_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/save_data_button.dart';

class InputDataKesehatanPage extends StatefulWidget {
  const InputDataKesehatanPage({super.key});

  @override
  State<InputDataKesehatanPage> createState() => _InputDataKesehatanPageState();
}

class _InputDataKesehatanPageState extends State<InputDataKesehatanPage> {
  // Controllers untuk input fields
  final TextEditingController _sistolikController = TextEditingController();
  final TextEditingController _diastolikController = TextEditingController();
  final TextEditingController _gulaDarahController = TextEditingController();
  final TextEditingController _beratBadanController = TextEditingController();
  final TextEditingController _detakJantungController = TextEditingController();
  final TextEditingController _aktivitasController = TextEditingController();

  @override
  void dispose() {
    _sistolikController.dispose();
    _diastolikController.dispose();
    _gulaDarahController.dispose();
    _beratBadanController.dispose();
    _detakJantungController.dispose();
    _aktivitasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Input Data Kesehatan',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const InfoBox(),
            const SizedBox(height: 24),
            BloodPressureSection(
              sistolikController: _sistolikController,
              diastolikController: _diastolikController,
              onConnect: () {
                // TODO: Implement connect device
              },
            ),
            const SizedBox(height: 16),
            BloodSugarSection(
              controller: _gulaDarahController,
              onConnect: () {
                // TODO: Implement connect device
              },
            ),
            WeightSection(
              controller: _beratBadanController,
              onConnect: () {
                // TODO: Implement connect device
              },
            ),
            HeartRateSection(
              controller: _detakJantungController,
            ),
            ActivitySection(
              controller: _aktivitasController,
            ),
            const SizedBox(height: 16),
            ConnectableDevicesSection(
              onTensimeterConnect: () {},
              onPulseOximeterConnect: () {},
              onGlucometerConnect: () {},
              onScaleConnect: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: SaveDataButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil disimpan'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }
}