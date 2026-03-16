import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'vehicle_info.dart';

enum StickerStatus {
  inactive,
  active,
  expired,
  suspended;

  String get value {
    switch (this) {
      case StickerStatus.inactive:
        return 'inactive';
      case StickerStatus.active:
        return 'active';
      case StickerStatus.expired:
        return 'expired';
      case StickerStatus.suspended:
        return 'suspended';
    }
  }

  static StickerStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'inactive':
        return StickerStatus.inactive;
      case 'active':
        return StickerStatus.active;
      case 'expired':
        return StickerStatus.expired;
      case 'suspended':
        return StickerStatus.suspended;
      default:
        return StickerStatus.inactive;
    }
  }
}

class Sticker extends Equatable {
  final String stickerId;
  final String qrCode;
  final StickerStatus status;
  final String? userId;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final DateTime? expiryDate;
  final VehicleInfo? vehicleInfo;
  final List<String> emergencyContactIds;

  const Sticker({
    required this.stickerId,
    required this.qrCode,
    required this.status,
    this.userId,
    required this.createdAt,
    this.activatedAt,
    this.expiryDate,
    this.vehicleInfo,
    this.emergencyContactIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'stickerId': stickerId,
      'qrCode': qrCode,
      'status': status.value,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'activatedAt': activatedAt != null ? Timestamp.fromDate(activatedAt!) : null,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'vehicleInfo': vehicleInfo?.toMap(),
      'emergencyContactIds': emergencyContactIds,
    };
  }

  factory Sticker.fromMap(Map<String, dynamic> map, {String? docId}) {
    // Helper function to safely convert to DateTime
    DateTime? _parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    // Helper function to safely get DateTime (required field)
    DateTime _parseRequiredTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    // Parse emergencyContactIds
    List<String> contactIds = [];
    if (map['emergencyContactIds'] != null) {
      if (map['emergencyContactIds'] is List) {
        contactIds = (map['emergencyContactIds'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return Sticker(
      stickerId: docId ?? map['stickerId']?.toString() ?? '',
      qrCode: map['qrCode']?.toString() ?? '',
      status: StickerStatus.fromString(map['status']?.toString() ?? 'inactive'),
      userId: map['userId']?.toString(),
      createdAt: _parseRequiredTimestamp(map['createdAt']),
      activatedAt: _parseTimestamp(map['activatedAt']),
      expiryDate: _parseTimestamp(map['expiryDate']),
      vehicleInfo: map['vehicleInfo'] != null 
          ? VehicleInfo.fromMap(map['vehicleInfo']) 
          : null,
      emergencyContactIds: contactIds,
    );
  }

  Sticker copyWith({
    String? stickerId,
    String? qrCode,
    StickerStatus? status,
    String? userId,
    DateTime? createdAt,
    DateTime? activatedAt,
    DateTime? expiryDate,
    VehicleInfo? vehicleInfo,
    List<String>? emergencyContactIds,
  }) {
    return Sticker(
      stickerId: stickerId ?? this.stickerId,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      emergencyContactIds: emergencyContactIds ?? this.emergencyContactIds,
    );
  }

  @override
  List<Object?> get props => [
        stickerId,
        qrCode,
        status,
        userId,
        createdAt,
        activatedAt,
        expiryDate,
        vehicleInfo,
        emergencyContactIds,
      ];
}
