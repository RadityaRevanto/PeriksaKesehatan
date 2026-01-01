import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/core/storage/storage_service.dart';
import 'package:periksa_kesehatan/pages/auth/login/login_page.dart';
import 'package:periksa_kesehatan/pages/profil/edit_profil_page.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_state.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_bloc.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/personal_info/personal_info_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for edit form
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Siti Rahmawati");
  final _birthDateController = TextEditingController(text: "15 Januari 1973");
  final _phoneController = TextEditingController(text: "+62 812-3456-7890");
  final _addressController = TextEditingController(text: "Jl. Merdeka No. 123, Jakarta");
  DateTime? _selectedDate = DateTime(1973, 1, 15);

  @override
  void initState() {
    super.initState();
    _loadPersonalInfo();
  }

  void _loadPersonalInfo() {
    final token = StorageService.instance.getToken();
    if (token != null) {
      context.read<PersonalInfoBloc>().add(LoadPersonalInfo(token));
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
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              // Navigasi ke halaman login setelah logout
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            } else if (state is AuthError) {
              // Tampilkan error jika logout gagal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<PersonalInfoBloc, PersonalInfoState>(
          listener: (context, state) {
            if (state is PersonalInfoLoaded) {
              // Update controllers with loaded data
              if (state.personalInfo != null) {
                setState(() {
                  _nameController.text = state.personalInfo!.name ?? "Siti Rahmawati";
                  _birthDateController.text = state.personalInfo!.birthDate ?? "15 Januari 1973";
                  _phoneController.text = state.personalInfo!.phone ?? "+62 812-3456-7890";
                  _addressController.text = state.personalInfo!.address ?? "Jl. Merdeka No. 123, Jakarta";
                  // Parse birth date if needed
                  // _selectedDate = ...
                });
              }
            } else if (state is PersonalInfoError) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F8),
        body: _buildMobileLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 15),
                  _buildStatsCard(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Informasi Pribadi"),
                  _buildInfoCard(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Pengaturan Aplikasi"),
                  _buildSettingCard(),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
      decoration: BoxDecoration(
        color: AppColors.authPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profil Saya",
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.settings, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              // Avatar dengan border modern
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=siti'),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ibu Siti",
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "sitirahmawati@email.com",
                          style: GoogleFonts.nunitoSans(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("65", "kg", Icons.monitor_weight_outlined, AppColors.primary),
          _buildStatDivider(),
          _statItem("158", "cm", Icons.height_outlined, AppColors.primaryLight),
          _buildStatDivider(),
          _statItem("52", "tahun", Icons.cake_outlined, AppColors.primaryDark),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade200,
    );
  }

  Widget _statItem(String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D473E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: GoogleFonts.nunitoSans(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2D473E),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        children: [
          _infoTile(Icons.person, "Nama Lengkap", _nameController.text),
          _buildDivider(),
          _infoTile(Icons.calendar_today, "Tanggal Lahir", _birthDateController.text),
          _buildDivider(),
          _infoTile(Icons.phone, "Nomor Telepon", _phoneController.text),
          _buildDivider(),
          _infoTile(Icons.location_on, "Alamat", _addressController.text, isLast: true),
        ],
      ),
    );
  }


  Widget _buildSettingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingTile(Icons.notifications, "Notifikasi", trailing: "Aktif"),
          _buildDivider(),
          _buildSettingTile(Icons.verified_user, "Privasi & Keamanan"),
          _buildDivider(),
          _buildSettingTile(Icons.language, "Bahasa", trailing: "Bahasa Indonesia"),
          _buildDivider(),
          _buildSettingTile(Icons.help, "Bantuan & Dukungan"),
          _buildDivider(),
          _buildSettingTile(Icons.description, "Syarat & Ketentuan"),
          _buildDivider(),
          _buildSettingTile(Icons.info, "Tentang Aplikasi", trailing: "v1.0.5", isLast: true),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, indent: 55, endIndent: 15, color: Color(0xFFF0F0F0));

  Widget _infoTile(IconData icon, String title, String subtitle, {bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilPage(
                initialName: _nameController.text,
                initialBirthDate: _birthDateController.text,
                initialPhone: _phoneController.text,
                initialAddress: _addressController.text,
                initialSelectedDate: _selectedDate,
              ),
            ),
          );

          // Update data if returned from edit page
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _nameController.text = result['name'];
              _birthDateController.text = result['birthDate'];
              _phoneController.text = result['phone'];
              _addressController.text = result['address'];
              _selectedDate = result['selectedDate'];
            });
          }
        },
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.authPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.authPrimary, size: 20),
          ),
          title: Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.nunitoSans(
              color: const Color(0xFF2D473E),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }


  Widget _buildSettingTile(IconData icon, String title, {String? trailing, bool isLast = false}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.authPrimary),
      title: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: GoogleFonts.nunitoSans(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildHealthCard(String title, String target, double progress, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Edit",
                style: GoogleFonts.nunitoSans(
                  color: AppColors.authPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            "Target: $target",
            style: GoogleFonts.nunitoSans(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5)
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton.icon(
          onPressed: () => _showLogoutDialog(context),
          icon: const Icon(Icons.logout, color: Colors.red),
          label: Text(
            "Keluar",
            style: GoogleFonts.nunitoSans(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Tampilkan dialog konfirmasi logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Konfirmasi Keluar",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin keluar dari aplikasi?",
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                "Batal",
                style: GoogleFonts.nunitoSans(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Tutup dialog
                Navigator.of(dialogContext).pop();
                // Trigger logout event
                context.read<AuthBloc>().add(const LogoutEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                "Keluar",
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}