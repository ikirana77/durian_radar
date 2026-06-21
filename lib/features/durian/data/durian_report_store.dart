import 'package:flutter/foundation.dart';

import '../models/durian_report.dart';
import 'dummy_durian_reports.dart';
import 'durian_report_repository.dart';

class DurianReportStore extends ValueNotifier<List<DurianReport>> {
  DurianReportStore({DurianReportRepository? repository})
    : _repository = repository ?? const DurianReportRepository(),
      super(List<DurianReport>.from(dummyDurianReports));

  final DurianReportRepository _repository;

  bool _isLoadingFromRemote = false;
  bool _hasLoadedRemoteData = false;
  String? _lastRemoteError;

  List<DurianReport> get reports => value;

  int get totalReports => value.length;

  bool get isLoadingFromRemote => _isLoadingFromRemote;

  bool get hasLoadedRemoteData => _hasLoadedRemoteData;

  String? get lastRemoteError => _lastRemoteError;

  void addReport(DurianReport report) {
    value = [report, ...value];
  }

  void replaceAllReports(List<DurianReport> reports) {
    value = List<DurianReport>.from(reports);
  }

  void resetToDummyData() {
    _hasLoadedRemoteData = false;
    _lastRemoteError = null;
    value = List<DurianReport>.from(dummyDurianReports);
  }

  Future<void> loadApprovedReportsFromSupabase() async {
    if (_isLoadingFromRemote) {
      return;
    }

    _isLoadingFromRemote = true;
    _lastRemoteError = null;

    try {
      final remoteReports = await _repository.fetchApprovedReports();

      if (remoteReports == null) {
        debugPrint(
          'Supabase client is not ready. Keeping local dummy durian reports.',
        );
        return;
      }

      if (remoteReports.isEmpty) {
        debugPrint(
          'Supabase returned 0 approved reports. Keeping local dummy durian reports.',
        );
        return;
      }

      value = remoteReports;
      _hasLoadedRemoteData = true;

      debugPrint(
        'Loaded ${remoteReports.length} approved reports from Supabase.',
      );
    } catch (error, stackTrace) {
      _lastRemoteError = error.toString();

      debugPrint('Failed to load durian reports from Supabase.');
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      debugPrint('Keeping local dummy durian reports.');
    } finally {
      _isLoadingFromRemote = false;
    }
  }

  List<Map<String, dynamic>> toMapList() {
    return value.map((report) => report.toMap()).toList();
  }
}

final DurianReportStore durianReportStore = DurianReportStore();
