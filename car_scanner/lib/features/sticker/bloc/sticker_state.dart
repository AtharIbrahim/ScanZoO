import 'package:equatable/equatable.dart';
import '../models/sticker.dart';
import '../models/emergency_contact.dart';

enum StickerSubmissionStatus {
  initial,
  checking,
  valid,
  invalid,
  activating,
  success,
  failure,
  loading,
}

class StickerState extends Equatable {
  final String stickerId;
  final StickerSubmissionStatus status;
  final List<Sticker> userStickers;
  final String? errorMessage;
  final Sticker? validatedSticker;
  final List<EmergencyContact> availableContacts;
  final List<EmergencyContact> linkedContacts;

  const StickerState({
    this.stickerId = '',
    this.status = StickerSubmissionStatus.initial,
    this.userStickers = const [],
    this.errorMessage,
    this.validatedSticker,
    this.availableContacts = const [],
    this.linkedContacts = const [],
  });

  bool get isStickerIdValid => stickerId.isNotEmpty && stickerId.length >= 6;

  StickerState copyWith({
    String? stickerId,
    StickerSubmissionStatus? status,
    List<Sticker>? userStickers,
    String? errorMessage,
    Sticker? validatedSticker,
    List<EmergencyContact>? availableContacts,
    List<EmergencyContact>? linkedContacts,
  }) {
    return StickerState(
      stickerId: stickerId ?? this.stickerId,
      status: status ?? this.status,
      userStickers: userStickers ?? this.userStickers,
      errorMessage: errorMessage,
      validatedSticker: validatedSticker ?? this.validatedSticker,
      availableContacts: availableContacts ?? this.availableContacts,
      linkedContacts: linkedContacts ?? this.linkedContacts,
    );
  }

  @override
  List<Object?> get props => [
        stickerId,
        status,
        userStickers,
        errorMessage,
        validatedSticker,
        availableContacts,
        linkedContacts,
      ];
}
