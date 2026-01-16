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
  late TextEditingController _weightController;
  late TextEditingController _heightController;
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

    // Initialize weight and height from the latest available state
    final state = context.read<PersonalInfoBloc>().state;
    double? initialWeight;
    double? initialHeight;
    if (state is PersonalInfoLoaded) {
      initialWeight = state.personalInfo?.weight;
      initialHeight = state.personalInfo?.height;
    }

    _weightController = TextEditingController(
      text: initialWeight != null ? initialWeight.toString() : ""
    );
    _heightController = TextEditingController(
      text: initialHeight != null ? initialHeight.toString() : ""
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _weightController.dispose();
    _heightController.dispose();
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
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                        // Info Banner
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.authPrimary.withOpacity(0.08),
                                AppColors.authPrimary.withOpacity(0.03),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.authPrimary.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.authPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.authPrimary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Pastikan data yang Anda masukkan sudah benar dan sesuai",
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 12.5,
                                    color: const Color(0xFF2D473E),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Personal Information Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.authPrimary,
                                          AppColors.authPrimary.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Informasi Pribadi",
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2D473E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Nama Lengkap
                              _buildModernFormField(
                                label: "Nama Lengkap",
                                controller: _nameController,
                                hint: "Masukkan nama lengkap (opsional)",
                                prefixIcon: Icons.badge_outlined,
                              ),
                              const SizedBox(height: 16),

                              // Tanggal Lahir
                              _buildModernFormField(
                                label: "Tanggal Lahir",
                                controller: _birthDateController,
                                hint: "Pilih tanggal lahir (opsional)",
                                prefixIcon: Icons.cake_outlined,
                                readOnly: true,
                                suffixIcon: _selectedDate != null || _birthDateController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear_rounded, color: Colors.grey.shade400),
                                        onPressed: () {
                                          setState(() {
                                            _selectedDate = null;
                                            _birthDateController.clear();
                                          });
                                        },
                                      )
                                    : Icon(Icons.calendar_today_rounded, color: Colors.grey.shade400, size: 20),
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
                                },
                              ),
                              const SizedBox(height: 16),

                              // Nomor Telepon
                              _buildModernFormField(
                                label: "Nomor Telepon",
                                controller: _phoneController,
                                hint: "Masukkan nomor telepon (opsional)",
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),

                              // Alamat
                              _buildModernFormField(
                                label: "Alamat",
                                controller: _addressController,
                                hint: "Masukkan alamat lengkap (opsional)",
                                prefixIcon: Icons.location_on_outlined,
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

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
        bottomNavigationBar: _buildBottomButton(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.authPrimary,
            AppColors.authPrimary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.authPrimary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
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
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (prefixIcon != null) ...[
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.authPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  prefixIcon,
                  size: 16,
                  color: AppColors.authPrimary,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D473E),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.nunitoSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D473E),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.nunitoSans(
                color: Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 14 : 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.authPrimary, width: 2.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2.5),
              ),
              errorStyle: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -4),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        child: BlocBuilder<PersonalInfoBloc, PersonalInfoState>(
          builder: (context, state) {
            final isLoading = state is PersonalInfoLoading;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                    color: AppColors.authPrimary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Menyimpan...",
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            "Simpan Perubahan",
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
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
      weight: double.tryParse(_weightController.text),
      height: double.tryParse(_heightController.text),
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
