import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ScanHistory extends Equatable {
  final String id;
  final String stickerId;
  final String userId;
  final DateTime scannedAt;
  final String action; // 'activated', 'viewed', 'blocked', 'unblocked'
  final Map<String, dynamic>? metadata;

  const ScanHistory({
    required this.id,
    required this.stickerId,
    required this.userId,
    required this.scannedAt,
    required this.action,
    this.metadata,
  });

  factory ScanHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScanHistory(
      id: doc.id,
      stickerId: data['stickerId'] ?? '',
      userId: data['userId'] ?? '',
      scannedAt: (data['scannedAt'] as Timestamp).toDate(),
      action: data['action'] ?? 'viewed',
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'stickerId': stickerId,
      'userId': userId,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'action': action,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [id, stickerId, userId, scannedAt, action, metadata];
}
