import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'supabase_service.dart';

class ReportService {
  ReportService._();

  static SupabaseClient get _client => SupabaseService.client;

  static Future<void> createPendingReport({
    required String spotId,
    required String stallName,
    required String area,
    required String variety,
    required double pricePerKg,
    required String stockStatus,
    String? photoUrl,
  }) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw const AuthException('Sila log masuk untuk menghantar laporan.');
    }

    final trimmedSpotId = spotId.trim();
    final trimmedStallName = stallName.trim();
    final trimmedArea = area.trim();
    final trimmedVariety = variety.trim();
    final trimmedStockStatus = stockStatus.trim();

    if (trimmedStallName.isEmpty) {
      throw const AuthException('Nama gerai atau lokasi diperlukan.');
    }

    if (trimmedArea.isEmpty) {
      throw const AuthException('Kawasan diperlukan.');
    }

    if (trimmedSpotId.isEmpty) {
      throw const AuthException('Lokasi durian diperlukan.');
    }

    if (trimmedVariety.isEmpty) {
      throw const AuthException('Varieti durian diperlukan.');
    }

    if (trimmedStockStatus.isEmpty) {
      throw const AuthException('Status stok diperlukan.');
    }

    if (pricePerKg <= 0) {
      throw const AuthException('Harga mesti lebih daripada RM0.');
    }

    final now = DateTime.now().toUtc();
    final expiresAt = now.add(const Duration(hours: 12));

    final markerLabel = _buildMarkerLabel(trimmedVariety, trimmedStockStatus);
    final mappedStockStatus = _mapStockStatus(trimmedStockStatus);
    final statusText = _mapStatusText(trimmedStockStatus);

    await _client.from('durian_reports').insert({
      'marker_label': markerLabel,
      'stall_name': trimmedStallName,
      'area': trimmedArea,
      'variety': trimmedVariety,
      'price': 'RM${pricePerKg.toStringAsFixed(0)}/kg',
      'price_per_kg': pricePerKg,
      'stock_status': mappedStockStatus,
      'status_text': statusText,
      'updated_time': 'Baru sahaja',
      'note': 'Laporan dihantar melalui aplikasi Durian Radar.',
      'latitude': 3.3400,
      'longitude': 101.2500,
      'reporter_id': user.id,
      'is_approved': false,
      'spot_id': trimmedSpotId,
      'photo_url': photoUrl,
      'reported_by': user.id,
      'reported_at': now.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': 'pending',
    });
  }

  static String _mapStockStatus(String stockStatus) {
    switch (stockStatus) {
      case 'Banyak':
        return 'available';
      case 'Sikit':
        return 'low_stock';
      case 'Habis':
        return 'sold_out';
      default:
        return stockStatus.toLowerCase();
    }
  }

  static String _mapStatusText(String stockStatus) {
    switch (stockStatus) {
      case 'Banyak':
        return 'Masih Ada';
      case 'Sikit':
        return 'Stok Sikit';
      case 'Habis':
        return 'Habis';
      default:
        return stockStatus;
    }
  }

  static String _buildMarkerLabel(String variety, String stockStatus) {
    if (stockStatus == 'Habis') {
      return 'Habis';
    }

    final normalized = variety.trim().toLowerCase();

    if (normalized.contains('musang')) {
      return 'MK';
    }

    if (normalized.contains('d24')) {
      return 'D24';
    }

    if (normalized.contains('kampung')) {
      return 'KG';
    }

    final cleanVariety = variety.trim();

    if (cleanVariety.isEmpty) {
      return 'DR';
    }

    return cleanVariety.length <= 3
        ? cleanVariety.toUpperCase()
        : cleanVariety.substring(0, 3).toUpperCase();
  }

  static String getReadableError(Object error) {
    if (error is AuthException) {
      return error.message;
    }

    if (error is PostgrestException) {
      return error.message;
    }

    return 'Laporan gagal dihantar. Sila cuba lagi.';
  }
}
