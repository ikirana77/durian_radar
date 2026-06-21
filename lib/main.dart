import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/supabase_service.dart';
import 'features/durian/data/durian_report_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();
  await durianReportStore.loadApprovedReportsFromSupabase();

  runApp(const DurianRadarApp());
}
