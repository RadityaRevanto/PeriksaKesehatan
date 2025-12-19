import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/pages/auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    Widget buildInputField(
      String label,
      String hint, {
      bool isPassword = false,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.nunitoSans(
                color: const Color(0xFFA0A0A0),
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.authPrimary,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    Widget buildSocialButton(String icon, String text) {
      return Expanded(
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon == 'G'
                  ? Text(
                      'G',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : const Icon(Icons.facebook, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.nunitoSans(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// ICON
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.authPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 12),

              /// TITLE
              Text(
                'Buat Akun',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Daftar untuk memulai perjalanan Anda',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 15,
                  color: const Color(0xFF666666),
                ),
              ),

              const SizedBox(height: 24),

              buildInputField('Nama Lengkap', 'Masukkan nama lengkap Anda'),
              buildInputField('Email', 'Masukkan email Anda'),
              buildInputField('Kata Sandi', 'Buat kata sandi',
                  isPassword: true),

              /// KONFIRMASI PASSWORD
              buildInputField(
                'Konfirmasi Kata Sandi',
                'Masukkan kembali kata sandi',
                isPassword: true,
              ),

              /// TERMS
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    SizedBox(
      width: 24, // lebar checkbox tanpa padding berlebih
      height: 24,
      child: Checkbox(
        value: _agreeToTerms,
        activeColor: AppColors.authPrimary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        onChanged: (value) {
          setState(() {
            _agreeToTerms = value ?? false;
          });
        },
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.nunitoSans(
            fontSize: 13.5,
            color: const Color(0xFF666666),
          ),
          children: const [
            TextSpan(text: 'Saya setuju dengan '),
            TextSpan(
              text: 'Syarat & Ketentuan',
              style: TextStyle(
                color: AppColors.linkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(text: ' dan '),
            TextSpan(
              text: 'Kebijakan Privasi',
              style: TextStyle(
                color: AppColors.linkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),

              const SizedBox(height: 20),

              /// BUTTON REGISTER
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.authPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Daftar',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// DIVIDER
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('Atau Daftar dengan'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              /// SOCIAL LOGIN
              Row(
                children: [
                  buildSocialButton('G', 'Google'),
                  const SizedBox(width: 10),
                  buildSocialButton('f', 'Facebook'),
                ],
              ),

              const SizedBox(height: 24),

              /// LOGIN LINK
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.5,
                        color: const Color(0xFF666666),
                      ),
                      children: const [
                        TextSpan(text: 'Sudah punya akun? '),
                        TextSpan(
                          text: 'Masuk sekarang',
                          style: TextStyle(
                            color: AppColors.linkColor,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
