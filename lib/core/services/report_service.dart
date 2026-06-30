import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'supabase_service.dart';

class ReportService {
  ReportService._();

  static SupabaseClient get _client => SupabaseService.client;

  static Future<void> createPendingReport({
    required String spotId,
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
    final trimmedVariety = variety.trim();
    final trimmedStockStatus = stockStatus.trim();

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

    await _client.from('durian_reports').insert({
      'spot_id': trimmedSpotId,
      'variety': trimmedVariety,
      'price_per_kg': pricePerKg,
      'stock_status': trimmedStockStatus,
      'photo_url': photoUrl,
      'reported_by': user.id,
      'reported_at': now.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': 'pending',
    });
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
