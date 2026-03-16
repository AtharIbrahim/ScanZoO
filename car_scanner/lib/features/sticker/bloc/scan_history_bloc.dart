import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/sticker_repository.dart';
import 'scan_history_event.dart';
import 'scan_history_state.dart';

class ScanHistoryBloc extends Bloc<ScanHistoryEvent, ScanHistoryState> {
  final StickerRepository stickerRepository;

  ScanHistoryBloc({
    required this.stickerRepository,
  }) : super(const ScanHistoryState()) {
    on<LoadScanHistory>(_onLoadScanHistory);
    on<RefreshScanHistory>(_onRefreshScanHistory);
  }

  Future<void> _onLoadScanHistory(
    LoadScanHistory event,
    Emitter<ScanHistoryState> emit,
  ) async {
    emit(state.copyWith(status: ScanHistoryStatus.loading));

    try {
      final historyWithDetails = await stickerRepository.getScanHistoryWithDetails(
        limit: event.limit,
      );

      emit(state.copyWith(
        status: ScanHistoryStatus.success,
        historyWithDetails: historyWithDetails,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScanHistoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshScanHistory(
    RefreshScanHistory event,
    Emitter<ScanHistoryState> emit,
  ) async {
    try {
      final historyWithDetails = await stickerRepository.getScanHistoryWithDetails();

      emit(state.copyWith(
        status: ScanHistoryStatus.success,
        historyWithDetails: historyWithDetails,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScanHistoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
