import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/sticker_repository.dart';
import 'sticker_event.dart';
import 'sticker_state.dart';

class StickerBloc extends Bloc<StickerEvent, StickerState> {
  final StickerRepository _stickerRepository;

  StickerBloc({
    required StickerRepository stickerRepository,
  })  : _stickerRepository = stickerRepository,
        super(const StickerState()) {
    on<StickerIdChanged>(_onStickerIdChanged);
    on<CheckStickerValidity>(_onCheckStickerValidity);
    on<ActivateStickerRequested>(_onActivateStickerRequested);
    on<LoadUserStickers>(_onLoadUserStickers);
    on<AddVehicleInfoRequested>(_onAddVehicleInfoRequested);
    on<AddEmergencyContactsRequested>(_onAddEmergencyContactsRequested);
    on<DeactivateStickerRequested>(_onDeactivateStickerRequested);
    on<BlockStickerRequested>(_onBlockStickerRequested);
    on<UnblockStickerRequested>(_onUnblockStickerRequested);
    on<LinkContactsToStickerRequested>(_onLinkContactsToStickerRequested);
    on<LoadContactsForSticker>(_onLoadContactsForSticker);
  }

  void _onStickerIdChanged(
    StickerIdChanged event,
    Emitter<StickerState> emit,
  ) {
    emit(state.copyWith(
      stickerId: event.stickerId,
      status: StickerSubmissionStatus.initial,
      errorMessage: null,
    ));
  }

  Future<void> _onCheckStickerValidity(
    CheckStickerValidity event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.checking));

    try {
      final sticker = await _stickerRepository.checkStickerValidity(event.stickerId);

      if (sticker != null) {
        // Load available contacts for the user
        final contacts = await _stickerRepository.getEmergencyContacts();
        
        emit(state.copyWith(
          status: StickerSubmissionStatus.valid,
          validatedSticker: sticker,
          availableContacts: contacts,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          status: StickerSubmissionStatus.invalid,
          errorMessage: 'Sticker not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.invalid,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onActivateStickerRequested(
    ActivateStickerRequested event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.activating));

    try {
      await _stickerRepository.activateSticker(event.stickerId);
      
      // Link emergency contacts if provided
      if (event.emergencyContactIds.isNotEmpty) {
        await _stickerRepository.linkContactsToSticker(
          event.stickerId,
          event.emergencyContactIds,
        );
      }

      // Add vehicle info if provided
      if (event.vehicleInfo != null) {
        await _stickerRepository.addVehicleInfo(
          event.stickerId,
          event.vehicleInfo!,
        );
      }

      emit(state.copyWith(
        status: StickerSubmissionStatus.success,
        errorMessage: null,
      ));

      // Reload user stickers
      add(const LoadUserStickers());
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadUserStickers(
    LoadUserStickers event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.loading));

    try {
      final stickers = await _stickerRepository.getUserStickers();

      emit(state.copyWith(
        userStickers: stickers,
        status: StickerSubmissionStatus.initial,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAddVehicleInfoRequested(
    AddVehicleInfoRequested event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.loading));

    try {
      await _stickerRepository.addVehicleInfo(
        event.stickerId,
        event.vehicleInfo,
      );

      emit(state.copyWith(
        status: StickerSubmissionStatus.success,
        errorMessage: null,
      ));

      // Reload user stickers
      add(const LoadUserStickers());
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAddEmergencyContactsRequested(
    AddEmergencyContactsRequested event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.loading));

    try {
      await _stickerRepository.addEmergencyContacts(event.contacts);

      emit(state.copyWith(
        status: StickerSubmissionStatus.success,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeactivateStickerRequested(
    DeactivateStickerRequested event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.loading));

    try {
      await _stickerRepository.deactivateSticker(event.stickerId);

      emit(state.copyWith(
        status: StickerSubmissionStatus.success,
        errorMessage: null,
      ));

      // Reload user stickers
      add(const LoadUserStickers());
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onBlockStickerRequested(
    BlockStickerRequested event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.loading));

    try {
      await _stickerRepository.blockSticker(event.stickerId);

      emit(state.copyWith(
        status: StickerSubmissionStatus.success,
        errorMessage: null,
      ));

      // Reload user stickers
      add(const LoadUserStickers());
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUnblockStickerRequested(
    UnblockStickerRequested event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.loading));

    try {
      await _stickerRepository.unblockSticker(event.stickerId);

      emit(state.copyWith(
        status: StickerSubmissionStatus.success,
        errorMessage: null,
      ));

      // Reload user stickers
      add(const LoadUserStickers());
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLinkContactsToStickerRequested(
    LinkContactsToStickerRequested event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.loading));

    try {
      await _stickerRepository.linkContactsToSticker(
        event.stickerId,
        event.contactIds,
      );

      emit(state.copyWith(
        status: StickerSubmissionStatus.success,
        errorMessage: null,
      ));

      // Reload user stickers
      add(const LoadUserStickers());
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadContactsForSticker(
    LoadContactsForSticker event,
    Emitter<StickerState> emit,
  ) async {
    emit(state.copyWith(status: StickerSubmissionStatus.loading));

    try {
      final availableContacts = await _stickerRepository.getEmergencyContacts();
      final linkedContacts = await _stickerRepository.getContactsForSticker(event.stickerId);

      emit(state.copyWith(
        availableContacts: availableContacts,
        linkedContacts: linkedContacts,
        status: StickerSubmissionStatus.initial,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StickerSubmissionStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
