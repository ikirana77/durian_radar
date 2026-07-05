import 'package:shared_preferences/shared_preferences.dart';

import 'report_service.dart';

class FavoriteService {
  static const String _favoriteKeysStorageKey = 'durian_radar_favorite_keys';

  static String keyForReport(DurianReportSummary report) {
    final stallName = report.stallName.trim().toLowerCase();
    final area = report.area.trim().toLowerCase();
    final variety = report.variety.trim().toLowerCase();
    final latitude = report.latitude.toStringAsFixed(6);
    final longitude = report.longitude.toStringAsFixed(6);

    return '$stallName|$area|$variety|$latitude|$longitude';
  }

  static Future<Set<String>> fetchFavoriteKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteKeysStorageKey)?.toSet() ?? <String>{};
  }

  static Future<bool> isFavorite(DurianReportSummary report) async {
    final favoriteKeys = await fetchFavoriteKeys();
    return favoriteKeys.contains(keyForReport(report));
  }

  static Future<bool> toggleReport(DurianReportSummary report) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteKeys =
        prefs.getStringList(_favoriteKeysStorageKey)?.toSet() ?? <String>{};

    final reportKey = keyForReport(report);
    final isNowFavorite = !favoriteKeys.contains(reportKey);

    if (isNowFavorite) {
      favoriteKeys.add(reportKey);
    } else {
      favoriteKeys.remove(reportKey);
    }

    await prefs.setStringList(_favoriteKeysStorageKey, favoriteKeys.toList());
    return isNowFavorite;
  }

  static Future<void> removeReport(DurianReportSummary report) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteKeys =
        prefs.getStringList(_favoriteKeysStorageKey)?.toSet() ?? <String>{};

    favoriteKeys.remove(keyForReport(report));

    await prefs.setStringList(_favoriteKeysStorageKey, favoriteKeys.toList());
  }
}
