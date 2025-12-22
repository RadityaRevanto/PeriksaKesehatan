import 'package:flutter/material.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      // LayoutBuilder adalah kunci agar tampilan adaptif (HP & Desktop)
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Jika lebar layar lebih dari 800px, tampilkan mode Desktop (2 Kolom)
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout();
          } else {
            // Jika layar kecil (HP), tampilkan mode Mobile (1 Kolom)
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // ----------------------------------------------------------------------
  // 1. TAMPILAN DESKTOP (2 KOLOM)
  // ----------------------------------------------------------------------
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // SISI KIRI (Profil & Stats) - Lebar Tetap
        Container(
          width: 350,
          color: Colors.white,
          child: Column(
            children: [
              _buildHeader(isDesktop: true),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsCard(),
              ),
              const Spacer(),
              _buildLogoutButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
        // SISI KANAN (Informasi Detail) - Scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Informasi Pribadi"),
                _buildInfoCard(),
                const SizedBox(height: 30),
                _buildSectionTitle("Target Kesehatan"),
                // Grid untuk Target Kesehatan agar tidak terlalu panjang ke bawah di desktop
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    SizedBox(width: 300, child: _buildHealthCard("Tekanan Darah", "120/80 mmHg", 0.85, "85% target", Colors.green)),
                    SizedBox(width: 300, child: _buildHealthCard("Gula Darah", "< 140 mg/dL", 0.6, "Perlu peningkatan", Colors.orange)),
                    SizedBox(width: 300, child: _buildHealthCard("Berat Badan", "60 kg", 0.92, "92% target", Colors.green)),
                  ],
                ),
                const SizedBox(height: 30),
                _buildSectionTitle("Pengaturan Aplikasi"),
                _buildSettingCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  // 2. TAMPILAN MOBILE (Kodingan Asli Anda)
  // ----------------------------------------------------------------------
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
                  _buildSectionTitle("Target Kesehatan"),
                  _buildHealthCard("Tekanan Darah", "120/80 mmHg", 0.85, "85% mencapai target", Colors.green),
                  _buildHealthCard("Gula Darah", "< 140 mg/dL", 0.6, "Perlu peningkatan", Colors.orange),
                  _buildHealthCard("Berat Badan", "60 kg", 0.92, "92% mencapai target", Colors.green),
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

  // ----------------------------------------------------------------------
  // 3. HELPER WIDGETS (Logika Tampilan Tetap Sama)
  // ----------------------------------------------------------------------

  Widget _buildHeader({bool isDesktop = false}) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, isDesktop ? 60 : 50, 20, 30),
      decoration: const BoxDecoration(color: AppColors.authPrimary),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Profil Saya", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=siti'),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ibu Siti", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("sitirahmawati@email.com", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("65", "kg"),
          _statItem("158", "cm"),
          _statItem("52", "tahun"),
        ],
      ),
    );
  }

  Widget _statItem(String value, String unit) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D473E))),
        Text(unit, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D473E))),
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
          _infoTile(Icons.person, "Nama Lengkap", "Siti Rahmawati"),
          _buildDivider(),
          _infoTile(Icons.calendar_today, "Tanggal Lahir", "15 Januari 1973"),
          _buildDivider(),
          _infoTile(Icons.phone, "Nomor Telepon", "+62 812-3456-7890"),
          _buildDivider(),
          _infoTile(Icons.location_on, "Alamat", "Jl. Merdeka No. 123, Jakarta", isLast: true),
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
    return ListTile(
      leading: Icon(icon, color: AppColors.authPrimary),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, {String? trailing, bool isLast = false}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.authPrimary),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) Text(trailing, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text("Edit", style: TextStyle(color: AppColors.authPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          Text("Target: $target", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5)
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFFFFEBEB), borderRadius: BorderRadius.circular(10)),
        child: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}