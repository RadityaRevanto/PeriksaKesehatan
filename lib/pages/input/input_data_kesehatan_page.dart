import 'package:flutter/material.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/widgets/buttons/primary_button.dart';
import 'package:periksa_kesehatan/widgets/buttons/outlined_dashed_button.dart';
import 'package:periksa_kesehatan/widgets/input/custom_text_field.dart';

class InputDataKesehatanPage extends StatefulWidget {
  const InputDataKesehatanPage({super.key});

  @override
  State<InputDataKesehatanPage> createState() => _InputDataKesehatanPageState();
}

class _InputDataKesehatanPageState extends State<InputDataKesehatanPage> {
  int _selectedTabIndex = 0;

  final TextEditingController _sistolikController = TextEditingController(text: '120');
  final TextEditingController _diastolikController = TextEditingController(text: '80');
  final TextEditingController _detakJantungController = TextEditingController(text: '72');

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Tekanan\nDarah', 'icon': Icons.favorite},
    {'title': 'Gula Darah', 'icon': Icons.water_drop},
    {'title': 'Berat Badan', 'icon': Icons.monitor_weight},
    {'title': 'Aktivitas', 'icon': Icons.directions_walk},
  ];

  @override
  void dispose() {
    _sistolikController.dispose();
    _diastolikController.dispose();
    _detakJantungController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Input Data Kesehatan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          
          // Horizontal scrollable tabs
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _tabs[index]['icon'],
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tabs[index]['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Rentang normal tekanan darah: ',
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: '90/60 - 120/80 mmHg',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: '. Detak jantung normal: ',
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: '60-100 bpm',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: '.',
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input fields using CustomTextField
                  CustomTextField(
                    controller: _sistolikController,
                    label: 'Tekanan Sistolik',
                    hint: '120',
                    helperText: 'mmHg (angka atas)',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _diastolikController,
                    label: 'Tekanan Diastolik',
                    hint: '80',
                    helperText: 'mmHg (angka bawah)',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  CustomTextField(
                    controller: _detakJantungController,
                    label: 'Detak Jantung',
                    hint: '72',
                    helperText: 'bpm (detak per menit)',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  // Hubungkan Alat Pengukur button
                  OutlinedDashedButton(
                    text: 'Hubungkan Alat Pengukur',
                    icon: Icons.bluetooth,
                    onPressed: () {
                      // TODO: Implement bluetooth connection
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Fixed Simpan Data button at bottom
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: PrimaryButton(
                text: 'Simpan Data',
                onPressed: () {
                  // TODO: Implement save data
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
