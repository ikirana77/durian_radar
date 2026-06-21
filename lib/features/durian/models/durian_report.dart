enum DurianStockStatus { available, lowStock, soldOut }

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
}
