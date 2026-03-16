import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sticker.dart';
import '../models/vehicle_info.dart';
import '../models/emergency_contact.dart';
import '../models/scan_history.dart';

class StickerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StickerRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Check if sticker exists and is available for activation
  Future<Sticker?> checkStickerValidity(String stickerId) async {
    try {
      final doc = await _firestore.collection('stickers').doc(stickerId).get();

      if (!doc.exists) {
        throw Exception('Sticker not found');
      }

      final sticker = Sticker.fromMap(doc.data()!, docId: doc.id);

      // Check if sticker is inactive and not assigned to anyone
      if (sticker.status != StickerStatus.inactive || 
          (sticker.userId != null && sticker.userId!.isNotEmpty && sticker.userId != 'null')) {
        throw Exception('Sticker is already activated or unavailable');
      }

      return sticker;
    } catch (e) {
      rethrow;
    }
  }

  /// Activate sticker and assign to current user
  Future<void> activateSticker(String stickerId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // First check if sticker is valid
      await checkStickerValidity(stickerId);

      final batch = _firestore.batch();

      // Update sticker document
      final stickerRef = _firestore.collection('stickers').doc(stickerId);
      batch.update(stickerRef, {
        'status': StickerStatus.active.value,
        'userId': userId,
        'activatedAt': FieldValue.serverTimestamp(),
      });

      // Update user document - use set with merge to handle missing fields
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'hasActiveSticker': true,
        'activeStickerIds': FieldValue.arrayUnion([stickerId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      
      // Add to scan history
      await addScanHistory(
        stickerId: stickerId,
        action: 'activated',
        metadata: {'activatedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Add vehicle information to sticker
  Future<void> addVehicleInfo(String stickerId, VehicleInfo vehicleInfo) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify user owns this sticker
      final stickerDoc = await _firestore.collection('stickers').doc(stickerId).get();
      if (!stickerDoc.exists || stickerDoc.data()?['userId'] != userId) {
        throw Exception('You do not own this sticker');
      }

      await _firestore.collection('stickers').doc(stickerId).update({
        'vehicleInfo': vehicleInfo.toMap(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Add emergency contacts to user profile
  Future<void> addEmergencyContacts(List<EmergencyContact> contacts) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('users').doc(userId).update({
        'emergencyContacts': contacts.map((c) => c.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's active stickers (including suspended ones)
  Future<List<Sticker>> getUserStickers() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('stickers')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: [StickerStatus.active.value, StickerStatus.suspended.value])
          .get();

      return querySnapshot.docs
          .map((doc) => Sticker.fromMap(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get sticker details by ID
  Future<Sticker?> getStickerById(String stickerId) async {
    try {
      final doc = await _firestore.collection('stickers').doc(stickerId).get();

      if (!doc.exists) {
        return null;
      }

      return Sticker.fromMap(doc.data()!, docId: doc.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Get emergency contacts from user profile
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore.collection('users').doc(userId).get();
      final contacts = doc.data()?['emergencyContacts'] as List?;

      if (contacts == null) {
        return [];
      }

      return contacts
          .map((c) => EmergencyContact.fromMap(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Deactivate sticker (admin or user)
  Future<void> deactivateSticker(String stickerId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final stickerDoc = await _firestore.collection('stickers').doc(stickerId).get();
      if (!stickerDoc.exists || stickerDoc.data()?['userId'] != userId) {
        throw Exception('You do not own this sticker');
      }

      final batch = _firestore.batch();

      // Update sticker document
      final stickerRef = _firestore.collection('stickers').doc(stickerId);
      batch.update(stickerRef, {
        'status': StickerStatus.inactive.value,
        'userId': FieldValue.delete(),
        'activatedAt': FieldValue.delete(),
        'vehicleInfo': FieldValue.delete(),
      });

      // Update user document
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'activeStickerIds': FieldValue.arrayRemove([stickerId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Check if user has other active stickers
      final userStickers = await getUserStickers();
      if (userStickers.length <= 1) {
        // This was the last sticker
        batch.set(userRef, {'hasActiveSticker': false}, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Temporarily block/suspend sticker
  Future<void> blockSticker(String stickerId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final stickerDoc = await _firestore.collection('stickers').doc(stickerId).get();
      if (!stickerDoc.exists || stickerDoc.data()?['userId'] != userId) {
        throw Exception('You do not own this sticker');
      }

      await _firestore.collection('stickers').doc(stickerId).update({
        'status': StickerStatus.suspended.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Add to scan history
      await addScanHistory(
        stickerId: stickerId,
        action: 'blocked',
        metadata: {'blockedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Unblock/reactivate suspended sticker
  Future<void> unblockSticker(String stickerId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final stickerDoc = await _firestore.collection('stickers').doc(stickerId).get();
      if (!stickerDoc.exists || stickerDoc.data()?['userId'] != userId) {
        throw Exception('You do not own this sticker');
      }

      await _firestore.collection('stickers').doc(stickerId).update({
        'status': StickerStatus.active.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Add to scan history
      await addScanHistory(
        stickerId: stickerId,
        action: 'unblocked',
        metadata: {'unblockedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Add scan history entry
  Future<void> addScanHistory({
    required String stickerId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final scanHistory = ScanHistory(
        id: '', // Firestore will generate this
        stickerId: stickerId,
        userId: userId,
        scannedAt: DateTime.now(),
        action: action,
        metadata: metadata,
      );

      await _firestore.collection('scanHistory').add(scanHistory.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Get scan history for current user
  Future<List<ScanHistory>> getScanHistory({int limit = 50}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection('scanHistory')
          .where('userId', isEqualTo: userId)
          .orderBy('scannedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ScanHistory.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get scan history with sticker details
  Future<List<Map<String, dynamic>>> getScanHistoryWithDetails({int limit = 50}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('Fetching scan history for user: $userId');

      final historyDocs = await _firestore
          .collection('scanHistory')
          .where('userId', isEqualTo: userId)
          .orderBy('scannedAt', descending: true)
          .limit(limit)
          .get();

      print('Found ${historyDocs.docs.length} history documents');

      final historyWithDetails = <Map<String, dynamic>>[];

      for (final historyDoc in historyDocs.docs) {
        try {
          final scanHistory = ScanHistory.fromFirestore(historyDoc);
          
          // Fetch sticker details
          final stickerDoc = await _firestore
              .collection('stickers')
              .doc(scanHistory.stickerId)
              .get();

          if (stickerDoc.exists) {
            final sticker = Sticker.fromMap(stickerDoc.data()!, docId: stickerDoc.id);
            historyWithDetails.add({
              'history': scanHistory,
              'sticker': sticker,
            });
          } else {
            print('Sticker ${scanHistory.stickerId} not found');
          }
        } catch (e) {
          print('Error processing history document: $e');
          // Continue with other documents
        }
      }

      print('Returning ${historyWithDetails.length} history items with details');
      return historyWithDetails;
    } catch (e) {
      print('Error fetching scan history: $e');
      rethrow;
    }
  }

  /// Link emergency contacts to a specific sticker
  Future<void> linkContactsToSticker(String stickerId, List<String> contactIds) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify user owns this sticker
      final stickerDoc = await _firestore.collection('stickers').doc(stickerId).get();
      if (!stickerDoc.exists || stickerDoc.data()?['userId'] != userId) {
        throw Exception('You do not own this sticker');
      }

      await _firestore.collection('stickers').doc(stickerId).update({
        'emergencyContactIds': contactIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get emergency contacts for a specific sticker
  Future<List<EmergencyContact>> getContactsForSticker(String stickerId) async {
    try {
      // Get sticker to find linked contact IDs
      final stickerDoc = await _firestore.collection('stickers').doc(stickerId).get();
      
      if (!stickerDoc.exists) {
        throw Exception('Sticker not found');
      }

      final sticker = Sticker.fromMap(stickerDoc.data()!, docId: stickerDoc.id);
      
      if (sticker.userId == null) {
        return [];
      }

      // Get user's emergency contacts
      final userDoc = await _firestore.collection('users').doc(sticker.userId).get();
      final allContacts = userDoc.data()?['emergencyContacts'] as List?;

      if (allContacts == null || sticker.emergencyContactIds.isEmpty) {
        return [];
      }

      // Filter contacts by IDs
      return allContacts
          .map((c) => EmergencyContact.fromMap(c as Map<String, dynamic>))
          .where((contact) => sticker.emergencyContactIds.contains(contact.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
