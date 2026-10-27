import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore, AuthService? authService})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _authService = authService ?? AuthService();

  final FirebaseFirestore _firestore;
  final AuthService _authService;

  Future<CollectionReference<Map<String, dynamic>>> userCollection(
    String collectionPath,
  ) async {
    final uid = await _authService.requireUserId();
    return _firestore.collection('users').doc(uid).collection(collectionPath);
  }

  Future<void> setUserDocument(
    String collectionPath,
    String id,
    Map<String, dynamic> data,
  ) async {
    final collection = await userCollection(collectionPath);
    await collection.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> deleteUserDocument(String collectionPath, String id) async {
    final collection = await userCollection(collectionPath);
    await collection.doc(id).delete();
  }

  Future<void> clearUserCollection(String collectionPath) async {
    final collection = await userCollection(collectionPath);
    final snapshot = await collection.get();
    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> watchUserCollection(
    String collectionPath, {
    String orderBy = 'updatedAt',
    bool descending = true,
  }) async* {
    final collection = await userCollection(collectionPath);
    yield* collection
        .orderBy(orderBy, descending: descending)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }
}
