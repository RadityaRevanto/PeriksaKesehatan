import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class MapsService {
  /// Membuka Google Maps dengan pencarian lokasi terdekat
  /// 
  /// [query] adalah kata kunci pencarian (contoh: "puskesmas terdekat")
  static Future<void> openMapsSearch(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    
    // URL untuk web Google Maps (fallback)
    final webUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
    );

    try {
      // Untuk iOS, coba buka Google Maps app terlebih dahulu
      if (Platform.isIOS) {
        final appUrl = Uri.parse('comgooglemaps://?q=$encodedQuery');
        try {
          if (await canLaunchUrl(appUrl)) {
            await launchUrl(appUrl, mode: LaunchMode.externalApplication);
            return;
          }
        } catch (e) {
          // Jika gagal, lanjut ke web URL
        }
      }
      
      // Untuk Android atau jika iOS app tidak tersedia, gunakan web URL
      // LaunchMode.platformDefault akan membuka di browser atau app yang tersedia
      await launchUrl(
        webUrl,
        mode: LaunchMode.platformDefault,
      );
    } catch (e) {
      // Jika platformDefault gagal, coba externalApplication
      try {
        await launchUrl(
          webUrl,
          mode: LaunchMode.externalApplication,
        );
      } catch (error) {
        throw Exception(
          'Tidak dapat membuka Google Maps. Pastikan browser atau aplikasi Google Maps tersedia.\nError: $error',
        );
      }
    }
  }

  /// Membuka Google Maps dengan koordinat spesifik
  /// 
  /// [latitude] dan [longitude] adalah koordinat lokasi
  static Future<void> openMapsLocation(
    double latitude,
    double longitude,
  ) async {
    final webUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      if (Platform.isIOS) {
        final appUrl = Uri.parse('comgooglemaps://?q=$latitude,$longitude');
        try {
          if (await canLaunchUrl(appUrl)) {
            await launchUrl(appUrl, mode: LaunchMode.externalApplication);
            return;
          }
        } catch (e) {
          // Fallback ke web URL
        }
      }
      
      await launchUrl(webUrl, mode: LaunchMode.platformDefault);
    } catch (e) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (error) {
        throw Exception('Tidak dapat membuka Google Maps: $error');
      }
    }
  }

  /// Membuka Google Maps dengan arah ke lokasi
  /// 
  /// [latitude] dan [longitude] adalah koordinat tujuan
  static Future<void> openMapsDirections(
    double latitude,
    double longitude,
  ) async {
    final webUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    try {
      if (Platform.isIOS) {
        final appUrl = Uri.parse(
          'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving',
        );
        try {
          if (await canLaunchUrl(appUrl)) {
            await launchUrl(appUrl, mode: LaunchMode.externalApplication);
            return;
          }
        } catch (e) {
          // Fallback ke web URL
        }
      }
      
      await launchUrl(webUrl, mode: LaunchMode.platformDefault);
    } catch (e) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (error) {
        throw Exception('Tidak dapat membuka Google Maps: $error');
      }
    }
  }
}
