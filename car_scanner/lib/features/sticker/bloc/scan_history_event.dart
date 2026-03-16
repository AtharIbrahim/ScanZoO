import 'package:equatable/equatable.dart';

abstract class ScanHistoryEvent extends Equatable {
  const ScanHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadScanHistory extends ScanHistoryEvent {
  final int limit;

  const LoadScanHistory({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

class RefreshScanHistory extends ScanHistoryEvent {}
