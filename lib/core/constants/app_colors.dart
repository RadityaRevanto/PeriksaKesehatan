import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF66D9B8);
  static const Color primaryDark = Color(0xFF388E3C);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Health Metric Colors
  static const Color heartRate = Color(0xFF4CAF50);
  static const Color bloodSugar = Color(0xFF2196F3);
  static const Color weight = Color(0xFF2196F3);
  static const Color activity = Color(0xFF9C27B0);
  
  // Background Colors for Icons
  static const Color heartRateBg = Color(0xFFE8F5E9);
  static const Color bloodSugarBg = Color(0xFFE3F2FD);
  static const Color weightBg = Color(0xFFE3F2FD);
  static const Color activityBg = Color(0xFFF3E5F5);
  
  // Alert Colors
  static const Color warningBg = Color(0xFFFFF8E1);
  static const Color infoBg = Color(0xFFE8F5E9);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
}
