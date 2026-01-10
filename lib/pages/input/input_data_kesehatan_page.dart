import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/domain/entities/health_data.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/health/health_state.dart';
import 'package:periksa_kesehatan/pages/input/widgets/info_box.dart';
import 'package:periksa_kesehatan/pages/input/widgets/blood_pressure_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/blood_sugar_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/weight_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/heart_rate_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/activity_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/connectable_devices_section.dart';
import 'package:periksa_kesehatan/pages/input/widgets/save_data_button.dart';
import 'package:periksa_kesehatan/pages/input/widgets/height_section.dart';

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
  final TextEditingController _tinggiBadanController = TextEditingController();
  final TextEditingController _detakJantungController = TextEditingController();
  final TextEditingController _aktivitasController = TextEditingController();

  @override
  void dispose() {
    _sistolikController.dispose();
    _diastolikController.dispose();
    _gulaDarahController.dispose();
    _beratBadanController.dispose();
    _tinggiBadanController.dispose();
    _detakJantungController.dispose();
    _aktivitasController.dispose();
    super.dispose();
  }

  void _handleSaveData() {
    print('--- DEBUG: DATA SUBMISSION START ---');
    print('Raw Input - Sistolik: "${_sistolikController.text}"');
    print('Raw Input - Diastolik: "${_diastolikController.text}"');
    print('Raw Input - Gula Darah: "${_gulaDarahController.text}"');
    print('Raw Input - Berat Badan: "${_beratBadanController.text}"');
    print('Raw Input - Tinggi Badan: "${_tinggiBadanController.text}"');
    print('Raw Input - Detak Jantung: "${_detakJantungController.text}"');
    print('Raw Input - Aktivitas: "${_aktivitasController.text}"');

    // Parse data dari controllers (nullable)
    final systolic = _sistolikController.text.isNotEmpty
        ? int.tryParse(_sistolikController.text)
        : null;
    final diastolic = _diastolikController.text.isNotEmpty
        ? int.tryParse(_diastolikController.text)
        : null;
    final bloodSugar = _gulaDarahController.text.isNotEmpty
        ? int.tryParse(_gulaDarahController.text)
        : null;
    
    // Handle decimal separator for comma (Indonesia) -> dot (Standard)
    final weightText = _beratBadanController.text.replaceAll(',', '.');
    final weight = weightText.isNotEmpty
        ? double.tryParse(weightText)
        : null;
        
    // Backend expects int for height, so we round to nearest int
    final heightText = _tinggiBadanController.text.replaceAll(',', '.');
    final height = heightText.isNotEmpty
        ? double.tryParse(heightText)
        : null;
        
    final heartRate = _detakJantungController.text.isNotEmpty
        ? int.tryParse(_detakJantungController.text)
        : null;
    final activity = _aktivitasController.text.isNotEmpty
        ? _aktivitasController.text
        : null;

    print('Parsed Data - Weight: $weight');
    print('Parsed Data - Height: $height');

    // Create health data entity with current date/time
    final healthData = HealthData(
      systolic: systolic,
      diastolic: diastolic,
      bloodSugar: bloodSugar,
      weight: weight,
      height: height,
      heartRate: heartRate,
      activity: activity,
      date: DateTime.now(), // Otomatis menggunakan tanggal saat input
    );
    
    print('Constructed HealthData: $healthData');
    print('Is Empty? ${healthData.isEmpty}');

    // Trigger save event
    context.read<HealthBloc>().add(SaveHealthDataEvent(healthData: healthData));
  }

  void _clearForm() {
    _sistolikController.clear();
    _diastolikController.clear();
    _gulaDarahController.clear();
    _beratBadanController.clear();
    _tinggiBadanController.clear();
    _detakJantungController.clear();
    _aktivitasController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HealthBloc, HealthState>(
      listener: (context, state) {
        if (state is HealthSaveSuccess) {
          // Clear form after successful save
          _clearForm();
          // Reset state
          context.read<HealthBloc>().add(const ResetHealthStateEvent());
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Navigate back to HomePage
          Navigator.of(context).pop();
        } else if (state is HealthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
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
              const SizedBox(height: 16),
              HeightSection(
                controller: _tinggiBadanController,

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
        bottomNavigationBar: BlocBuilder<HealthBloc, HealthState>(
          builder: (context, state) {
            final isLoading = state is HealthLoading;
            return SaveDataButton(
              onPressed: isLoading ? null : _handleSaveData,
              isLoading: isLoading,
            );
          },
        ),
      ),
    );
  }
}