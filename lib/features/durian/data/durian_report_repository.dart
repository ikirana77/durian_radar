import '../../../core/services/supabase_service.dart';
import '../models/durian_report.dart';

class DurianReportRepository {
  const DurianReportRepository();

  static const String _tableName = 'durian_reports';

  Future<List<DurianReport>?> fetchApprovedReports() async {
    final client = SupabaseService.client;

    if (client == null) {
      return null;
    }

    final data = await client
        .from(_tableName)
        .select()
        .eq('is_approved', true)
        .order('created_at', ascending: false);

    final rows = data.map<Map<String, dynamic>>((row) {
      return Map<String, dynamic>.from(row as Map);
    }).toList();

    return rows.map(DurianReport.fromMap).toList();
  }
}
