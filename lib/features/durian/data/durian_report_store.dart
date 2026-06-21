import 'package:flutter/foundation.dart';

import '../models/durian_report.dart';
import 'dummy_durian_reports.dart';

class DurianReportStore extends ValueNotifier<List<DurianReport>> {
  DurianReportStore() : super(List<DurianReport>.from(dummyDurianReports));

  List<DurianReport> get reports => value;

  void addReport(DurianReport report) {
    value = [report, ...value];
  }

  void resetToDummyData() {
    value = List<DurianReport>.from(dummyDurianReports);
  }
}

final DurianReportStore durianReportStore = DurianReportStore();
