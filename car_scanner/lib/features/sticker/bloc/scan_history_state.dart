import 'package:equatable/equatable.dart';

enum ScanHistoryStatus { initial, loading, success, failure }

class ScanHistoryState extends Equatable {
  final ScanHistoryStatus status;
  final List<Map<String, dynamic>> historyWithDetails;
  final String? errorMessage;

  const ScanHistoryState({
    this.status = ScanHistoryStatus.initial,
    this.historyWithDetails = const [],
    this.errorMessage,
  });

  ScanHistoryState copyWith({
    ScanHistoryStatus? status,
    List<Map<String, dynamic>>? historyWithDetails,
    String? errorMessage,
  }) {
    return ScanHistoryState(
      status: status ?? this.status,
      historyWithDetails: historyWithDetails ?? this.historyWithDetails,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, historyWithDetails, errorMessage];
}
