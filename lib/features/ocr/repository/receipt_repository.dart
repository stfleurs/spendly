import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/receipt.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

final receiptRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(storageProvider);
  return ReceiptRepository(firestore, storage);
});

class ReceiptRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ReceiptRepository(this._firestore, this._storage);

  CollectionReference get _collection => _firestore.collection('receipts');

  Future<String> uploadReceiptImage(String userId, File file) async {
    final ref = _storage.ref().child('receipts/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> saveReceipt(Receipt receipt) async {
    final data = receipt.toJson();
    // Ensure nested lists are converted to maps for Firestore
    data['lines'] = receipt.lines.map((l) => l.toJson()).toList();
    if (receipt.items != null) {
      data['items'] = receipt.items!.map((i) => i.toJson()).toList();
    }
    await _collection.doc(receipt.id).set(data);
  }

  Future<Receipt?> getReceiptById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Receipt.fromJson(doc.data() as Map<String, dynamic>);
  }

  Stream<List<Receipt>> getReceipts(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Receipt.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
