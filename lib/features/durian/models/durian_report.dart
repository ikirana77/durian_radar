enum DurianStockStatus { available, lowStock, soldOut }

DurianStockStatus durianStockStatusFromDatabaseValue(String? value) {
  switch (value) {
    case 'available':
      return DurianStockStatus.available;
    case 'low_stock':
      return DurianStockStatus.lowStock;
    case 'sold_out':
      return DurianStockStatus.soldOut;
    default:
      return DurianStockStatus.available;
  }
}

String durianStockStatusToDatabaseValue(DurianStockStatus status) {
  switch (status) {
    case DurianStockStatus.available:
      return 'available';
    case DurianStockStatus.lowStock:
      return 'low_stock';
    case DurianStockStatus.soldOut:
      return 'sold_out';
  }
}

String durianStockStatusToDisplayText(DurianStockStatus status) {
  switch (status) {
    case DurianStockStatus.available:
      return 'Masih Ada';
    case DurianStockStatus.lowStock:
      return 'Stok Sikit';
    case DurianStockStatus.soldOut:
      return 'Dah Habis';
  }
}

class DurianReport {
  const DurianReport({
    required this.id,
    required this.markerLabel,
    required this.stallName,
    required this.area,
    required this.variety,
    required this.price,
    required this.stockStatus,
    required this.statusText,
    required this.updatedTime,
    required this.createdAt,
    this.updatedAt,
    this.note,
    this.latitude,
    this.longitude,
    this.reporterId,
    this.isApproved = false,
  });

  final String id;
  final String markerLabel;
  final String stallName;
  final String area;
  final String variety;
  final String price;
  final DurianStockStatus stockStatus;
  final String statusText;
  final String updatedTime;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? note;
  final double? latitude;
  final double? longitude;
  final String? reporterId;
  final bool isApproved;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get searchableText {
    return [
      id,
      markerLabel,
      stallName,
      area,
      variety,
      price,
      statusText,
      updatedTime,
      note ?? '',
      latitude?.toString() ?? '',
      longitude?.toString() ?? '',
      reporterId ?? '',
    ].join(' ').toLowerCase();
  }

  DurianReport copyWith({
    String? id,
    String? markerLabel,
    String? stallName,
    String? area,
    String? variety,
    String? price,
    DurianStockStatus? stockStatus,
    String? statusText,
    String? updatedTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
    double? latitude,
    double? longitude,
    String? reporterId,
    bool? isApproved,
  }) {
    return DurianReport(
      id: id ?? this.id,
      markerLabel: markerLabel ?? this.markerLabel,
      stallName: stallName ?? this.stallName,
      area: area ?? this.area,
      variety: variety ?? this.variety,
      price: price ?? this.price,
      stockStatus: stockStatus ?? this.stockStatus,
      statusText: statusText ?? this.statusText,
      updatedTime: updatedTime ?? this.updatedTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      reporterId: reporterId ?? this.reporterId,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marker_label': markerLabel,
      'stall_name': stallName,
      'area': area,
      'variety': variety,
      'price': price,
      'stock_status': durianStockStatusToDatabaseValue(stockStatus),
      'status_text': statusText,
      'updated_time': updatedTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'note': note,
      'latitude': latitude,
      'longitude': longitude,
      'reporter_id': reporterId,
      'is_approved': isApproved,
    };
  }

  factory DurianReport.fromMap(Map<String, dynamic> map) {
    final status = durianStockStatusFromDatabaseValue(
      map['stock_status']?.toString(),
    );

    return DurianReport(
      id: map['id']?.toString() ?? '',
      markerLabel: map['marker_label']?.toString() ?? 'NEW',
      stallName: map['stall_name']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      variety: map['variety']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      stockStatus: status,
      statusText:
          map['status_text']?.toString() ??
          durianStockStatusToDisplayText(status),
      updatedTime: map['updated_time']?.toString() ?? 'Baru sahaja',
      createdAt: _parseDateTime(map['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updated_at']),
      note: map['note']?.toString(),
      latitude: _parseDouble(map['latitude']),
      longitude: _parseDouble(map['longitude']),
      reporterId: map['reporter_id']?.toString(),
      isApproved: _parseBool(map['is_approved']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    final text = value.toString().toLowerCase();

    return text == 'true' || text == '1' || text == 'yes';
  }
}
