import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:periksa_kesehatan/core/constants/app_colors.dart';
import 'package:periksa_kesehatan/pages/auth/register/register_page.dart';
import 'package:periksa_kesehatan/pages/home/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;

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

              const SizedBox(height: 16),

              /// TITLE
              Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Masuk ke akun Anda untuk melanjutkan',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 15,
                  color: const Color(0xFF666666),
                ),
              ),

              const SizedBox(height: 24),

              buildInputField(
                'Email atau Username',
                'Masukkan email atau username',
              ),

              buildInputField(
                'Kata Sandi',
                'Masukkan kata sandi',
                isPassword: true,
              ),

              /// REMEMBER ME + FORGOT PASSWORD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.authPrimary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ingat saya',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13.5,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Lupa kata sandi?',
                      style: GoogleFonts.nunitoSans(
                        color: AppColors.linkColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// LOGIN BUTTON
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomePage(),
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
                  'Masuk',
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
                    child: Text('Atau Masuk dengan'),
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

              /// REGISTER LINK
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
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
                        TextSpan(text: 'Belum punya akun? '),
                        TextSpan(
                          text: 'Daftar sekarang',
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
