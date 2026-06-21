import 'package:flutter/foundation.dart';

import '../models/durian_report.dart';
import 'dummy_durian_reports.dart';

class DurianReportStore extends ValueNotifier<List<DurianReport>> {
  DurianReportStore() : super(List<DurianReport>.from(dummyDurianReports));

  List<DurianReport> get reports => value;

  int get totalReports => value.length;

  void addReport(DurianReport report) {
    value = [report, ...value];
  }

  void replaceAllReports(List<DurianReport> reports) {
    value = List<DurianReport>.from(reports);
  }

  void resetToDummyData() {
    value = List<DurianReport>.from(dummyDurianReports);
  }

  List<Map<String, dynamic>> toMapList() {
    return value.map((report) => report.toMap()).toList();
  }
}

final DurianReportStore durianReportStore = DurianReportStore();
