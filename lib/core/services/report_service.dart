import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'supabase_service.dart';

class DurianReportSummary {
  const DurianReportSummary({
    required this.id,
    required this.markerLabel,
    required this.stallName,
    required this.area,
    required this.variety,
    required this.price,
    required this.stockStatus,
    required this.statusText,
    required this.updatedTime,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.isApproved,
    required this.sellerPhone,
    required this.photoUrl,
  });

  final String id;
  final String markerLabel;
  final String stallName;
  final String area;
  final String variety;
  final String price;
  final String stockStatus;
  final String statusText;
  final String updatedTime;
  final String note;
  final double latitude;
  final double longitude;
  final bool isApproved;
  final String sellerPhone;
  final String photoUrl;

  factory DurianReportSummary.fromMap(Map<String, dynamic> map) {
    return DurianReportSummary(
      id: (map['id'] ?? '').toString(),
      markerLabel: (map['marker_label'] ?? 'DR').toString(),
      stallName: (map['stall_name'] ?? 'Lokasi Durian').toString(),
      area: (map['area'] ?? 'Kawasan tidak dinyatakan').toString(),
      variety: (map['variety'] ?? 'Durian').toString(),
      price: (map['price'] ?? _formatPrice(map['price_per_kg'])).toString(),
      stockStatus: (map['stock_status'] ?? 'available').toString(),
      statusText: (map['status_text'] ?? 'Status belum dikemaskini').toString(),
      updatedTime: (map['updated_time'] ?? 'Baru dikemaskini').toString(),
      note: (map['note'] ?? '').toString(),
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      isApproved: map['is_approved'] == true,
      sellerPhone: (map['seller_phone'] ?? '').toString(),
      photoUrl: (map['photo_url'] ?? '').toString(),
    );
  }

  static String _formatPrice(dynamic value) {
    final parsed = _toDouble(value);

    if (parsed <= 0) {
      return 'Harga tidak dinyatakan';
    }

    return 'RM${parsed.toStringAsFixed(0)}/kg';
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}

class ReportService {
  ReportService._();

  static SupabaseClient get _client => SupabaseService.client;

  static const String _stallImagesBucket = 'stall-images';

  static Future<String> uploadReportPhoto({
    required Uint8List bytes,
    required String originalFileName,
  }) async {
    final user = AuthService.currentUser;

    if (user == null) {
      throw const AuthException('Sila log masuk untuk upload gambar gerai.');
    }

    if (bytes.isEmpty) {
      throw const AuthException(
        'Gambar gerai tidak sah. Sila pilih gambar lain.',
      );
    }

    final extension = _extractImageExtension(originalFileName);
    final storagePath =
        'reports/${user.id}/${DateTime.now().millisecondsSinceEpoch}$extension';

    await _client.storage
        .from(_stallImagesBucket)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentTypeForExtension(extension),
            upsert: false,
          ),
        );

    return _client.storage.from(_stallImagesBucket).getPublicUrl(storagePath);
  }

  static Future<void> createPendingReport({
    required String spotId,
    required String stallName,
    required String area,
    required String variety,
    required double pricePerKg,
    required String stockStatus,
    double? latitude,
    double? longitude,
    String? sellerPhone,
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
    final trimmedSellerPhone = sellerPhone?.trim() ?? '';
    final reportLatitude = latitude ?? 3.3400;
    final reportLongitude = longitude ?? 101.2500;
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
      'seller_phone': trimmedSellerPhone,
      'area': trimmedArea,
      'variety': trimmedVariety,
      'price': 'RM${pricePerKg.toStringAsFixed(0)}/kg',
      'price_per_kg': pricePerKg,
      'stock_status': mappedStockStatus,
      'status_text': statusText,
      'updated_time': 'Baru sahaja',
      'note': 'Laporan dihantar melalui aplikasi Durian Radar.',
      'latitude': reportLatitude,
      'longitude': reportLongitude,
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

  static Future<List<DurianReportSummary>> fetchLatestReports({
    bool approvedOnly = false,
    int limit = 20,
  }) async {
    dynamic query = _client.from('durian_reports').select('''
      id,
      marker_label,
      stall_name,
      seller_phone,
      photo_url,
      area,
      variety,
      price,
      price_per_kg,
      stock_status,
      status_text,
      updated_time,
      note,
      latitude,
      longitude,
      is_approved,
      reported_at,
      status
    ''');

    if (approvedOnly) {
      query = query.eq('is_approved', true);
    }

    final response = await query
        .order('reported_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map(
          (item) => DurianReportSummary.fromMap(item as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<List<DurianReportSummary>> fetchApprovedReports({
    int limit = 20,
  }) {
    return fetchLatestReports(approvedOnly: true, limit: limit);
  }

  static String _extractImageExtension(String originalFileName) {
    final lowerName = originalFileName.toLowerCase();

    if (lowerName.endsWith('.png')) {
      return '.png';
    }

    if (lowerName.endsWith('.webp')) {
      return '.webp';
    }

    if (lowerName.endsWith('.heic')) {
      return '.heic';
    }

    if (lowerName.endsWith('.jpeg')) {
      return '.jpeg';
    }

    return '.jpg';
  }

  static String _contentTypeForExtension(String extension) {
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      case '.jpeg':
      case '.jpg':
      default:
        return 'image/jpeg';
    }
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

  static Future<List<DurianReportSummary>> fetchPendingReports({
    int limit = 50,
  }) async {
    final response = await _client
        .from('durian_reports')
        .select('''
          id,
          marker_label,
          stall_name,
          seller_phone,
          photo_url,
          area,
          variety,
          price,
          price_per_kg,
          stock_status,
          status_text,
          updated_time,
          note,
          latitude,
          longitude,
          is_approved,
          reported_at,
          status
        ''')
        .eq('status', 'pending')
        .order('reported_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map(
          (item) => DurianReportSummary.fromMap(item as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<void> approveReport(String reportId) async {
    final trimmedId = reportId.trim();

    if (trimmedId.isEmpty) {
      throw const AuthException('ID laporan tidak sah.');
    }

    await _client
        .from('durian_reports')
        .update({
          'is_approved': true,
          'status': 'approved',
          'status_text': 'Disahkan',
          'updated_time': 'Baru disahkan',
        })
        .eq('id', trimmedId);
  }

  static Future<void> rejectReport(String reportId) async {
    final trimmedId = reportId.trim();

    if (trimmedId.isEmpty) {
      throw const AuthException('ID laporan tidak sah.');
    }

    await _client
        .from('durian_reports')
        .update({
          'is_approved': false,
          'status': 'rejected',
          'status_text': 'Ditolak',
          'updated_time': 'Baru ditolak',
        })
        .eq('id', trimmedId);
  }

  static String getReadableError(Object error) {
    if (error is AuthException) {
      return error.message;
    }

    if (error is PostgrestException) {
      return error.message;
    }

    return 'Laporan gagal diproses. Sila cuba lagi.';
  }
}
