import 'package:flutter/material.dart';
import 'login_page.dart'; // Import agar bisa beralih ke halaman Login

// 1. Ubah menjadi StatefulWidget
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 2. Buat variabel untuk menyimpan state checkbox
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    // Definisi warna yang digunakan
    const Color primaryColor = Color(0xFF38A562);
    const Color linkColor = primaryColor;

    // Fungsi untuk membuat kolom input
    Widget buildInputField(String label, String hint, {bool isPassword = false}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 8),
          TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFA0A0A0), fontStyle: FontStyle.italic, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // Fungsi untuk tombol sosial
    Widget buildSocialButton(String iconPath, String text) {
      return Expanded(
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menggunakan Icon Data karena tidak ada aset gambar di Flutter standard
              iconPath == 'G'
                  ? const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black))
                  : const Icon(Icons.facebook, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Background body
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400), // Max lebar kartu (simulasi HP)
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header (Ikon Hati)
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Buat Akun',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Daftar untuk memulai perjalanan Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 25),

                // Form Input
                buildInputField('Nama Lengkap', 'Masukkan nama lengkap Anda'),
                buildInputField('Email', 'Masukkan email Anda'),
                buildInputField('Kata Sandi', 'Buat kata sandi', isPassword: true),
                buildInputField('Konfirmasi Kata Sandi', 'Masukkan kembali kata sandi', isPassword: true),

                // Checkbox Persetujuan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3. Update Checkbox untuk menggunakan state
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _agreeToTerms = newValue ?? false;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF666666)),
                            children: <TextSpan>[
                              const TextSpan(text: 'Saya setuju dengan '),
                              TextSpan(
                                text: 'Syarat & Ketentuan',
                                style: const TextStyle(color: linkColor, fontWeight: FontWeight.w500),
                                // onTap: () {} (untuk InkWell jika di luar RichText)
                              ),
                              const TextSpan(text: ' dan '),
                              TextSpan(
                                text: 'Kebijakan Privasi',
                                style: const TextStyle(color: linkColor, fontWeight: FontWeight.w500),
                                // onTap: () {}
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Tombol Daftar
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Daftar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 25),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Atau Daftar dengan', style: TextStyle(color: Color(0xFF999999), fontSize: 14)),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                  ],
                ),
                const SizedBox(height: 25),

                // Social Login Buttons
                Row(
                  children: <Widget>[
                    buildSocialButton('G', 'Google'),
                    const SizedBox(width: 10),
                    buildSocialButton('f', 'Facebook'),
                  ],
                ),
                const SizedBox(height: 25),

                // Footer Link
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14.5, color: Color(0xFF666666)),
                        children: <TextSpan>[
                          const TextSpan(text: 'Sudah punya akun? '),
                          TextSpan(
                            text: 'Masuk sekarang',
                            style: TextStyle(color: linkColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
