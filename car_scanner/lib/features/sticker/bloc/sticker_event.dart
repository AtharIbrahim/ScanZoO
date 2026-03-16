import 'package:equatable/equatable.dart';
import '../models/vehicle_info.dart';
import '../models/emergency_contact.dart';

abstract class StickerEvent extends Equatable {
  const StickerEvent();

  @override
  List<Object?> get props => [];
}

class StickerIdChanged extends StickerEvent {
  final String stickerId;

  const StickerIdChanged(this.stickerId);

  @override
  List<Object?> get props => [stickerId];
}

class CheckStickerValidity extends StickerEvent {
  final String stickerId;

  const CheckStickerValidity(this.stickerId);

  @override
  List<Object?> get props => [stickerId];
}

class ActivateStickerRequested extends StickerEvent {
  final String stickerId;
  final List<String> emergencyContactIds;
  final VehicleInfo? vehicleInfo;

  const ActivateStickerRequested({
    required this.stickerId,
    this.emergencyContactIds = const [],
    this.vehicleInfo,
  });

  @override
  List<Object?> get props => [stickerId, emergencyContactIds, vehicleInfo];
}

class LoadUserStickers extends StickerEvent {
  const LoadUserStickers();
}

class AddVehicleInfoRequested extends StickerEvent {
  final String stickerId;
  final VehicleInfo vehicleInfo;

  const AddVehicleInfoRequested({
    required this.stickerId,
    required this.vehicleInfo,
  });

  @override
  List<Object?> get props => [stickerId, vehicleInfo];
}

class AddEmergencyContactsRequested extends StickerEvent {
  final List<EmergencyContact> contacts;

  const AddEmergencyContactsRequested(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class DeactivateStickerRequested extends StickerEvent {
  final String stickerId;

  const DeactivateStickerRequested(this.stickerId);

  @override
  List<Object?> get props => [stickerId];
}

class BlockStickerRequested extends StickerEvent {
  final String stickerId;

  const BlockStickerRequested(this.stickerId);

  @override
  List<Object?> get props => [stickerId];
}

class UnblockStickerRequested extends StickerEvent {
  final String stickerId;

  const UnblockStickerRequested(this.stickerId);

  @override
  List<Object?> get props => [stickerId];
}

class LinkContactsToStickerRequested extends StickerEvent {
  final String stickerId;
  final List<String> contactIds;

  const LinkContactsToStickerRequested({
    required this.stickerId,
    required this.contactIds,
  });

  @override
  List<Object?> get props => [stickerId, contactIds];
}

class LoadContactsForSticker extends StickerEvent {
  final String stickerId;

  const LoadContactsForSticker(this.stickerId);

  @override
  List<Object?> get props => [stickerId];
}
