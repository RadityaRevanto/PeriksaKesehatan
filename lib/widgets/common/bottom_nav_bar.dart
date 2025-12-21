import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../pages/home/home_page.dart';
import '../../pages/riwayat/riwayat_kesehatan_page.dart';
import '../../pages/edukasi/edukasi_page.dart';
import '../../pages/profil/profil_page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const RiwayatKesehatanPage(),
    const EdukasiPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            currentIndex: currentIndex,
            selectedLabelStyle: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: const Color(0xff49454f),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: PhosphorIcon(
                  PhosphorIcons.house(),
                  size: 24,
                  color: currentIndex == 0
                      ? AppColors.primary
                      : const Color(0xff49454f),
                ),
                activeIcon: PhosphorIcon(
                  PhosphorIcons.house(),
                  size: 24,
                  color: AppColors.primary,
                ),
                label: "Beranda",
              ),
              BottomNavigationBarItem(
                icon: PhosphorIcon(
                  PhosphorIcons.clipboardText(),
                  size: 24,
                  color: currentIndex == 1
                      ? AppColors.primary
                      : const Color(0xff49454f),
                ),
                activeIcon: PhosphorIcon(
                  PhosphorIcons.clipboardText(),
                  size: 24,
                  color: AppColors.primary,
                ),
                label: "Riwayat",
              ),
              BottomNavigationBarItem(
                icon: PhosphorIcon(
                  PhosphorIcons.book(),
                  size: 24,
                  color: currentIndex == 2
                      ? AppColors.primary
                      : const Color(0xff49454f),
                ),
                activeIcon: PhosphorIcon(
                  PhosphorIcons.book(),
                  size: 24,
                  color: AppColors.primary,
                ),
                label: "Edukasi",
              ),
              BottomNavigationBarItem(
                icon: PhosphorIcon(
                  PhosphorIcons.user(),
                  size: 24,
                  color: currentIndex == 3
                      ? AppColors.primary
                      : const Color(0xff49454f),
                ),
                activeIcon: PhosphorIcon(
                  PhosphorIcons.user(),
                  size: 24,
                  color: AppColors.primary,
                ),
                label: "Profil",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
