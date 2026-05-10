import 'dart:convert';
import 'package:crypto/crypto.dart';
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

  String _getDocId(String merchantName) {
    final sanitized = merchantName.toLowerCase().trim();
    final bytes = utf8.encode(sanitized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Built-in global rules for common merchants
  static const Map<String, String> globalRules = {
    'uber': 'Transportation',
    'netflix': 'Entertainment',
    'spotify': 'Entertainment',
    'amazon': 'Shopping',
    'walmart': 'Groceries',
    'starbucks': 'Food',
    'mcdonald': 'Food',
    'digicel': 'Utilities',
    'natcom': 'Utilities',
    'rent': 'Housing',
  };

  Future<void> savePreference(String userId, MerchantPreference pref) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('merchant_preferences')
        .doc(_getDocId(pref.merchantName))
        .set(pref.toMap());
  }

  Future<MerchantPreference?> getPreference(String userId, String merchantName) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('merchant_preferences')
        .doc(_getDocId(merchantName))
        .get();
    
    if (doc.exists) {
      return MerchantPreference.fromMap(doc.data()!);
    }
    return null;
  }

  Future<String?> guessCategory(String userId, String description) async {
    final sanitized = description.toLowerCase().trim();
    
    // 1. Check user preferences (Exact match first)
    final pref = await getPreference(userId, sanitized);
    if (pref != null) return pref.categoryId;

    // 2. Check global rules (Contains match)
    for (var entry in globalRules.entries) {
      if (sanitized.contains(entry.key)) {
        return entry.value; // Note: This should ideally map to an ID, but for now we use the group name or similar. 
        // In a real app, you'd map "Transportation" to the actual category ID.
      }
    }

    return null;
  }
}

final merchantRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return MerchantRepository(firestore);
});
