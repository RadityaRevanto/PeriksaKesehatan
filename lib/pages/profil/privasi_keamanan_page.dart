import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';

class PrivasiKeamananPage extends StatefulWidget {
  const PrivasiKeamananPage({super.key});

  @override
  State<PrivasiKeamananPage> createState() => _PrivasiKeamananPageState();
}

class _PrivasiKeamananPageState extends State<PrivasiKeamananPage> {
  // State untuk toggle switches
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _dataEncryptionEnabled = true;
  bool _shareDataWithDoctors = true;
  bool _shareDataForResearch = false;
  bool _showProfilePublicly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: _buildMobileLayout(),
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
                  const SizedBox(height: 20),
                  _buildSectionTitle("Keamanan Akun"),
                  _buildSecurityCard(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Privasi Data"),
                  _buildPrivacyCard(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Pengaturan Lainnya"),
                  _buildOtherSettingsCard(),
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
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Privasi & Keamanan",
              style: GoogleFonts.nunitoSans(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
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

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.lock_outline,
            title: "Ubah Password",
            subtitle: "Terakhir diubah 30 hari yang lalu",
            onTap: () => _showChangePasswordDialog(),
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: "Autentikasi Biometrik",
            subtitle: "Gunakan sidik jari atau Face ID",
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
              _showSnackBar(
                value
                    ? "Autentikasi biometrik diaktifkan"
                    : "Autentikasi biometrik dinonaktifkan",
              );
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.verified_user_outlined,
            title: "Verifikasi Dua Langkah",
            subtitle: "Tambahkan lapisan keamanan ekstra",
            value: _twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _twoFactorEnabled = value;
              });
              if (value) {
                _showTwoFactorSetupDialog();
              } else {
                _showSnackBar("Verifikasi dua langkah dinonaktifkan");
              }
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.enhanced_encryption_outlined,
            title: "Enkripsi Data",
            subtitle: "Data kesehatan Anda dienkripsi",
            value: _dataEncryptionEnabled,
            onChanged: (value) {
              setState(() {
                _dataEncryptionEnabled = value;
              });
              _showSnackBar(
                value
                    ? "Enkripsi data diaktifkan"
                    : "Enkripsi data dinonaktifkan",
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.devices_outlined,
            title: "Perangkat Terhubung",
            subtitle: "Kelola perangkat yang terhubung",
            onTap: () => _showConnectedDevicesDialog(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.medical_services_outlined,
            title: "Bagikan Data dengan Dokter",
            subtitle: "Izinkan dokter mengakses data kesehatan",
            value: _shareDataWithDoctors,
            onChanged: (value) {
              setState(() {
                _shareDataWithDoctors = value;
              });
              _showSnackBar(
                value
                    ? "Berbagi data dengan dokter diaktifkan"
                    : "Berbagi data dengan dokter dinonaktifkan",
              );
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.science_outlined,
            title: "Bagikan Data untuk Riset",
            subtitle: "Data anonim untuk penelitian kesehatan",
            value: _shareDataForResearch,
            onChanged: (value) {
              setState(() {
                _shareDataForResearch = value;
              });
              _showSnackBar(
                value
                    ? "Berbagi data untuk riset diaktifkan"
                    : "Berbagi data untuk riset dinonaktifkan",
              );
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.public_outlined,
            title: "Profil Publik",
            subtitle: "Tampilkan profil Anda secara publik",
            value: _showProfilePublicly,
            onChanged: (value) {
              setState(() {
                _showProfilePublicly = value;
              });
              _showSnackBar(
                value ? "Profil publik diaktifkan" : "Profil publik dinonaktifkan",
              );
            },
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.download_outlined,
            title: "Unduh Data Saya",
            subtitle: "Dapatkan salinan data kesehatan Anda",
            onTap: () => _showDownloadDataDialog(),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.delete_outline,
            title: "Hapus Akun",
            subtitle: "Hapus akun dan semua data Anda",
            onTap: () => _showDeleteAccountDialog(),
            isLast: true,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.policy_outlined,
            title: "Kebijakan Privasi",
            subtitle: "Baca kebijakan privasi kami",
            onTap: () => _showPrivacyPolicyDialog(),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.gavel_outlined,
            title: "Syarat & Ketentuan",
            subtitle: "Baca syarat dan ketentuan penggunaan",
            onTap: () => _showTermsDialog(),
          ),
          _buildDivider(),
          _buildSettingTile(
            icon: Icons.history_outlined,
            title: "Riwayat Aktivitas",
            subtitle: "Lihat riwayat login dan aktivitas",
            onTap: () => _showActivityHistoryDialog(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 55,
      endIndent: 15,
      color: Color(0xFFF0F0F0),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isLast = false,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : Radius.zero,
          bottom: isLast ? const Radius.circular(15) : Radius.zero,
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDanger
                  ? Colors.red.withOpacity(0.1)
                  : AppColors.authPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDanger ? Colors.red : AppColors.authPrimary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDanger ? Colors.red : const Color(0xFF2D473E),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.authPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.authPrimary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D473E),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunitoSans(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.authPrimary,
      ),
    );
  }

  // Dialog Methods
  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.authPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.lock_outline,
                color: AppColors.authPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Ubah Password",
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password Lama",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password Baru",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Konfirmasi Password Baru",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              // TODO: Implement password change logic
              Navigator.pop(context);
              _showSnackBar("Password berhasil diubah");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Simpan",
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.authPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.verified_user_outlined,
                color: AppColors.authPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Verifikasi Dua Langkah",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pilih metode verifikasi:",
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 15),
            _buildVerificationOption(
              icon: Icons.sms_outlined,
              title: "SMS",
              subtitle: "Kirim kode ke nomor telepon",
            ),
            const SizedBox(height: 10),
            _buildVerificationOption(
              icon: Icons.email_outlined,
              title: "Email",
              subtitle: "Kirim kode ke email",
            ),
            const SizedBox(height: 10),
            _buildVerificationOption(
              icon: Icons.qr_code_outlined,
              title: "Aplikasi Authenticator",
              subtitle: "Gunakan Google Authenticator",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _twoFactorEnabled = false;
              });
              Navigator.pop(context);
            },
            child: Text(
              "Batal",
              style: GoogleFonts.nunitoSans(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _showSnackBar("Verifikasi dua langkah diaktifkan via $title");
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.authPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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

  void _showConnectedDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.authPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.devices_outlined,
                color: AppColors.authPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Perangkat Terhubung",
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeviceItem(
              deviceName: "iPhone 13 Pro",
              location: "Jakarta, Indonesia",
              lastActive: "Aktif sekarang",
              isCurrentDevice: true,
            ),
            const SizedBox(height: 10),
            _buildDeviceItem(
              deviceName: "MacBook Pro",
              location: "Jakarta, Indonesia",
              lastActive: "2 jam yang lalu",
              isCurrentDevice: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.nunitoSans(
                color: AppColors.authPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem({
    required String deviceName,
    required String location,
    required String lastActive,
    required bool isCurrentDevice,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrentDevice
              ? AppColors.authPrimary.withOpacity(0.3)
              : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(10),
        color: isCurrentDevice
            ? AppColors.authPrimary.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(
            Icons.phone_iphone,
            color: isCurrentDevice ? AppColors.authPrimary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      deviceName,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentDevice) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.authPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Perangkat ini",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  lastActive,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrentDevice)
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar("Perangkat berhasil dihapus");
              },
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.authPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.download_outlined,
                color: AppColors.authPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Unduh Data Saya",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "Kami akan mengirimkan salinan data kesehatan Anda dalam format PDF ke email yang terdaftar. Proses ini mungkin memakan waktu beberapa menit.",
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              Navigator.pop(context);
              _showSnackBar("Permintaan unduh data berhasil dikirim");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.authPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Unduh",
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Hapus Akun",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apakah Anda yakin ingin menghapus akun?",
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tindakan ini tidak dapat dibatalkan. Semua data kesehatan Anda akan dihapus secara permanen.",
              style: GoogleFonts.nunitoSans(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              // TODO: Implement account deletion logic
              Navigator.pop(context);
              _showSnackBar("Akun berhasil dihapus");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Hapus Akun",
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.authPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.policy_outlined,
                color: AppColors.authPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Kebijakan Privasi",
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            "Kebijakan Privasi Periksa Kesehatan\n\n"
            "Terakhir diperbarui: 9 Januari 2026\n\n"
            "1. Pengumpulan Data\n"
            "Kami mengumpulkan data kesehatan Anda termasuk tekanan darah, gula darah, berat badan, dan aktivitas fisik untuk memberikan layanan pemantauan kesehatan.\n\n"
            "2. Penggunaan Data\n"
            "Data Anda digunakan untuk:\n"
            "- Memberikan analisis kesehatan personal\n"
            "- Mengirimkan peringatan kesehatan\n"
            "- Meningkatkan layanan kami\n\n"
            "3. Keamanan Data\n"
            "Kami menggunakan enkripsi end-to-end untuk melindungi data kesehatan Anda.\n\n"
            "4. Berbagi Data\n"
            "Data Anda tidak akan dibagikan kepada pihak ketiga tanpa persetujuan eksplisit Anda.\n\n"
            "5. Hak Anda\n"
            "Anda memiliki hak untuk mengakses, mengubah, atau menghapus data Anda kapan saja.",
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.nunitoSans(
                color: AppColors.authPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.authPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.gavel_outlined,
                color: AppColors.authPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Syarat & Ketentuan",
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            "Syarat & Ketentuan Penggunaan\n\n"
            "Terakhir diperbarui: 9 Januari 2026\n\n"
            "1. Penerimaan Ketentuan\n"
            "Dengan menggunakan aplikasi Periksa Kesehatan, Anda menyetujui syarat dan ketentuan ini.\n\n"
            "2. Penggunaan Layanan\n"
            "Anda bertanggung jawab untuk:\n"
            "- Memberikan informasi yang akurat\n"
            "- Menjaga kerahasiaan akun Anda\n"
            "- Menggunakan layanan sesuai hukum yang berlaku\n\n"
            "3. Batasan Tanggung Jawab\n"
            "Aplikasi ini adalah alat bantu pemantauan kesehatan dan bukan pengganti konsultasi medis profesional.\n\n"
            "4. Perubahan Layanan\n"
            "Kami berhak mengubah atau menghentikan layanan kapan saja dengan pemberitahuan sebelumnya.\n\n"
            "5. Hukum yang Berlaku\n"
            "Syarat dan ketentuan ini diatur oleh hukum Republik Indonesia.",
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.nunitoSans(
                color: AppColors.authPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.authPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.history_outlined,
                color: AppColors.authPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Riwayat Aktivitas",
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActivityItem(
              icon: Icons.login,
              activity: "Login",
              time: "Hari ini, 14:30",
              location: "Jakarta, Indonesia",
            ),
            const SizedBox(height: 10),
            _buildActivityItem(
              icon: Icons.edit,
              activity: "Edit Profil",
              time: "Kemarin, 10:15",
              location: "Jakarta, Indonesia",
            ),
            const SizedBox(height: 10),
            _buildActivityItem(
              icon: Icons.login,
              activity: "Login",
              time: "2 hari yang lalu, 08:45",
              location: "Jakarta, Indonesia",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tutup",
              style: GoogleFonts.nunitoSans(
                color: AppColors.authPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String activity,
    required String time,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.authPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  location,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.nunitoSans(),
        ),
        backgroundColor: AppColors.authPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
