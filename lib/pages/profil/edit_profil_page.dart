import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/data/models/profile/personal_info_model.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_state.dart';

class EditProfilPage extends StatefulWidget {
  final String initialName;
  final String initialBirthDate;
  final String initialPhone;
  final String initialAddress;
  final DateTime? initialSelectedDate;
  final bool hasExistingProfile; // Flag untuk mengetahui apakah profil sudah ada

  const EditProfilPage({
    super.key,
    required this.initialName,
    required this.initialBirthDate,
    required this.initialPhone,
    required this.initialAddress,
    this.initialSelectedDate,
    this.hasExistingProfile = false, // Default false (belum ada profil)
  });

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _birthDateController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  DateTime? _selectedDate;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName == "-" ? "" : widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone == "-" ? "" : widget.initialPhone);
    _addressController = TextEditingController(text: widget.initialAddress == "-" ? "" : widget.initialAddress);
    
    // Parse birth date from API format (yyyy-MM-dd) or use initial selected date
    if (widget.initialSelectedDate != null) {
      _selectedDate = widget.initialSelectedDate;
      _birthDateController = TextEditingController(
        text: "${widget.initialSelectedDate!.day} ${_getMonthName(widget.initialSelectedDate!.month)} ${widget.initialSelectedDate!.year}"
      );
    } else if (widget.initialBirthDate.isNotEmpty && 
               widget.initialBirthDate != "-") {
      // Try to parse from yyyy-MM-dd format
      try {
        final parsedDate = DateTime.tryParse(widget.initialBirthDate);
        if (parsedDate != null) {
          _selectedDate = parsedDate;
          _birthDateController = TextEditingController(
            text: "${parsedDate.day} ${_getMonthName(parsedDate.month)} ${parsedDate.year}"
          );
        } else {
          _birthDateController = TextEditingController(text: widget.initialBirthDate);
        }
      } catch (e) {
        _birthDateController = TextEditingController(text: widget.initialBirthDate);
      }
    } else {
      _birthDateController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalInfoBloc, PersonalInfoState>(
      listener: (context, state) {
        if (state is PersonalInfoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.message,
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is PersonalInfoUpdated) {
          // Success message will be shown after pop
          Navigator.pop(context, {
            'name': _nameController.text,
            'birthDate': _birthDateController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'selectedDate': _selectedDate,
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Profil berhasil disimpan',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F8),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<PersonalInfoBloc, PersonalInfoState>(
                builder: (context, state) {
                  final isLoading = state is PersonalInfoLoading;
                  
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.authPrimary.withOpacity(0.1),
                                AppColors.authPrimary.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.authPrimary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "Pastikan data yang Anda masukkan sudah benar dan sesuai",
                            style: GoogleFonts.nunitoSans(
                              fontSize: 13,
                              color: const Color(0xFF2D473E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Nama Lengkap
                        _buildModernFormField(
                          label: "Nama Lengkap",
                          controller: _nameController,
                          hint: "Masukkan nama lengkap (opsional)",
                        ),
                        const SizedBox(height: 24),

                        // Tanggal Lahir
                        _buildModernFormField(
                          label: "Tanggal Lahir",
                          controller: _birthDateController,
                          hint: "Pilih tanggal lahir (opsional)",
                          readOnly: true,
                          suffixIcon: _selectedDate != null || _birthDateController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDate = null;
                                      _birthDateController.clear();
                                    });
                                  },
                                )
                              : null,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate ?? DateTime(1973, 1, 15),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.authPrimary,
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                    dialogBackgroundColor: Colors.white,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                                _birthDateController.text = 
                                  "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
                              });
                            }
                            // Jika user cancel, tidak mengubah apapun
                          },
                        ),
                        const SizedBox(height: 24),

                        // Nomor Telepon
                        _buildModernFormField(
                          label: "Nomor Telepon",
                          controller: _phoneController,
                          hint: "Masukkan nomor telepon (opsional)",
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),

                        // Alamat
                        _buildModernFormField(
                          label: "Alamat",
                          controller: _addressController,
                          hint: "Masukkan alamat lengkap (opsional)",
                          maxLines: 4,
                        ),
                        const SizedBox(height: 40),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _saveChanges,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.authPrimary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            elevation: 0,
                                            shadowColor: AppColors.authPrimary.withOpacity(0.3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            disabledBackgroundColor: Colors.grey.shade300,
                                          ),
                                          child: isLoading
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  "Simpan Perubahan",
                                                  style: GoogleFonts.nunitoSans(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isLoading)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.authPrimary,
            AppColors.authPrimary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.authPrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit Informasi Pribadi",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D473E),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.nunitoSans(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2D473E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunitoSans(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.authPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  void _saveChanges() {
    // Tidak perlu validasi form, semua field optional
    final token = StorageService.instance.getToken();
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token tidak ditemukan. Silakan login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Format birth date to yyyy-MM-dd for API
    // Pastikan selalu ada format yang valid atau string kosong untuk create
    String? formattedBirthDate;
    if (_selectedDate != null) {
      formattedBirthDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    } else if (_birthDateController.text.isNotEmpty && 
               _birthDateController.text != "-") {
      // Try to parse existing date if _selectedDate is null but text exists
      try {
        final parsedDate = DateTime.tryParse(_birthDateController.text);
        if (parsedDate != null) {
          formattedBirthDate = DateFormat('yyyy-MM-dd').format(parsedDate);
        } else {
          // Jika tidak bisa parse, set ke null (akan menjadi string kosong saat create)
          formattedBirthDate = null;
        }
      } catch (e) {
        // If parsing fails, set to null
        formattedBirthDate = null;
      }
    } else {
      // Jika tidak ada tanggal, set ke null (akan menjadi string kosong saat create)
      formattedBirthDate = null;
    }

    // Create PersonalInfoModel - semua field bisa null
    // Saat create, toJsonForCreate() akan mengubah null menjadi string kosong untuk name dan birth_date
    final personalInfo = PersonalInfoModel(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      birthDate: formattedBirthDate,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
    );

    // Jika profil sudah ada, gunakan PUT (update) - semua field optional
    // Jika profil belum ada, gunakan PUT (create) - name dan birth_date required (minimal string kosong)
    if (widget.hasExistingProfile) {
      // Update existing profile
      context.read<PersonalInfoBloc>().add(
        UpdatePersonalInfo(token, personalInfo, imageFile: _selectedImageFile),
      );
    } else {
      // Create new profile
      context.read<PersonalInfoBloc>().add(
        CreatePersonalInfo(token, personalInfo, imageFile: _selectedImageFile),
      );
    }
    
    // Note: Success/error handling is done in BlocListener
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}
