import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

class MerchantPreference {
  final String merchantName;
  final String categoryId;
  final String accountId;

  MerchantPreference({
    required this.merchantName,
    required this.categoryId,
    required this.accountId,
  });

  Map<String, dynamic> toMap() => {
    'merchantName': merchantName,
    'categoryId': categoryId,
    'accountId': accountId,
  };

  factory MerchantPreference.fromMap(Map<String, dynamic> map) => MerchantPreference(
    merchantName: map['merchantName'] ?? '',
    categoryId: map['categoryId'] ?? '',
    accountId: map['accountId'] ?? '',
  );
}

class MerchantRepository {
  final FirebaseFirestore _firestore;

  MerchantRepository(this._firestore);

  Future<void> savePreference(String userId, MerchantPreference pref) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('merchant_preferences')
        .doc(pref.merchantName.toLowerCase().trim())
        .set(pref.toMap());
  }

  Future<MerchantPreference?> getPreference(String userId, String merchantName) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('merchant_preferences')
        .doc(merchantName.toLowerCase().trim())
        .get();
    
    if (doc.exists) {
      return MerchantPreference.fromMap(doc.data()!);
    }
    return null;
  }
}

final merchantRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return MerchantRepository(firestore);
});
