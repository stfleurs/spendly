import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/receipt.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

final financialIntelligenceRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FinancialIntelligenceRepository(firestore);
});

class FinancialIntelligenceRepository {
  final FirebaseFirestore _firestore;

  FinancialIntelligenceRepository(this._firestore);

  Future<({String merchant, String? categoryId, String? accountId, String? currency})> predictMerchant(
    String userId,
    String rawMerchant,
  ) async {
    if (rawMerchant.trim().isEmpty) {
      return (merchant: rawMerchant, categoryId: null, accountId: null, currency: null);
    }

    // 1. Try User-Specific Learning First
    final userAliasDoc = await _userLearning(userId)
        .collection('merchant_aliases')
        .doc(_docId(rawMerchant))
        .get();

    if (userAliasDoc.exists) {
      final alias = userAliasDoc.data() ?? {};
      final canonicalMerchant = alias['canonicalMerchant'] as String?;
      final profileId = alias['profileId'] as String?;

      if (profileId != null && profileId.isNotEmpty) {
        final profileDoc = await _userLearning(userId)
            .collection('merchant_profiles')
            .doc(profileId)
            .get();
        final profile = profileDoc.data();
        return (
          merchant: canonicalMerchant ?? rawMerchant,
          categoryId: profile?['categoryId'] as String?,
          accountId: profile?['accountId'] as String?,
          currency: profile?['defaultCurrency'] as String?,
        );
      }
      return (merchant: canonicalMerchant ?? rawMerchant, categoryId: null, accountId: null, currency: null);
    }

    // 2. Try Global Intelligence
    final globalAliasDoc = await _globalLearning()
        .collection('merchant_aliases')
        .doc(_docId(rawMerchant))
        .get();

    if (globalAliasDoc.exists) {
      final alias = globalAliasDoc.data() ?? {};
      final canonicalMerchant = alias['canonicalMerchant'] as String?;
      final learnedCurrency = alias['defaultCurrency'] as String?;
      final learnedCategory = alias['categoryId'] as String?;

      return (
        merchant: canonicalMerchant ?? rawMerchant,
        categoryId: learnedCategory,
        accountId: null,
        currency: learnedCurrency,
      );
    }

    return (merchant: rawMerchant, categoryId: null, accountId: null, currency: null);
  }

  Future<Receipt> applyLearning(String userId, Receipt receipt) async {
    final rawMerchant = receipt.merchant;
    if (rawMerchant == null) return receipt;

    final prediction = await predictMerchant(userId, rawMerchant);

    return receipt.copyWith(
      merchant: prediction.merchant,
      originalCurrency: prediction.currency?.trim().isNotEmpty == true
          ? prediction.currency
          : receipt.originalCurrency,
    );
  }

  Future<void> recordMerchantInteraction({
    required String userId,
    required String rawMerchant,
    required String correctedMerchant,
    required String categoryId,
    required String accountId,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    final merchant = correctedMerchant.trim();
    if (merchant.isEmpty) return;

    final profileId = _docId(merchant);
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    // 1. Update Merchant Profile
    final profileRef = _userLearning(userId).collection('merchant_profiles').doc(profileId);
    batch.set(profileRef, {
      'merchantName': merchant,
      'normalizedMerchant': normalizeText(merchant),
      'categoryId': categoryId,
      'accountId': accountId,
      'defaultCurrency': currency,
      'useCount': FieldValue.increment(1),
      'updatedAt': now,
    }, SetOptions(merge: true));

    // 2. Update Aliases
    for (final alias in {merchant, rawMerchant.trim()}) {
      if (alias.isEmpty) continue;
      final aliasRef = _userLearning(userId).collection('merchant_aliases').doc(_docId(alias));
      batch.set(aliasRef, {
        'rawMerchant': alias,
        'normalizedRawMerchant': normalizeText(alias),
        'canonicalMerchant': merchant,
        'profileId': profileId,
        'seenCount': FieldValue.increment(1),
        'updatedAt': now,
      }, SetOptions(merge: true));
    }

    await batch.commit();

    // 3. Global Contribution (Async)
    if (rawMerchant.trim().isNotEmpty && normalizeText(rawMerchant) != normalizeText(merchant)) {
      _uploadGlobalContribution(
        userId: userId,
        rawMerchant: rawMerchant,
        correctedMerchant: merchant,
        changedFields: ['merchant'],
        currency: currency,
      ).catchError((e) => debugPrint('Error uploading global contribution: $e'));
    }
  }

  Future<void> recordConfirmedReceipt({
    required String userId,
    required Receipt originalReceipt,
    required Receipt correctedReceipt,
    required String categoryId,
    required String accountId,
    required String currency,
  }) async {
    final rawMerchant = originalReceipt.merchant ?? '';
    final correctedMerchant = correctedReceipt.merchant ?? '';

    await recordMerchantInteraction(
      userId: userId,
      rawMerchant: rawMerchant,
      correctedMerchant: correctedMerchant,
      categoryId: categoryId,
      accountId: accountId,
      currency: currency,
    );

    // Record other changed fields as events
    final changedFields = _changedFields(originalReceipt, correctedReceipt);
    if (changedFields.isNotEmpty && changedFields.any((f) => f != 'merchant')) {
      final eventRef = _userLearning(userId).collection('correction_events').doc();
      await eventRef.set({
        'receiptId': correctedReceipt.id,
        'merchantRaw': rawMerchant,
        'merchantCorrected': correctedMerchant,
        'changedFields': changedFields,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _uploadGlobalContribution({
    required String userId,
    required String rawMerchant,
    required String correctedMerchant,
    required List<String> changedFields,
    required String currency,
  }) async {
    if (rawMerchant.isEmpty && correctedMerchant.isEmpty) return;

    await _globalContributions().add({
      'userId': userId, // For anti-spam/security rules, but data is otherwise anonymized
      'rawMerchant': rawMerchant,
      'normalizedRaw': normalizeText(rawMerchant),
      'correctedMerchant': correctedMerchant,
      'normalizedCorrected': normalizeText(correctedMerchant),
      'changedFields': changedFields,
      'currency': currency,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  DocumentReference<Map<String, dynamic>> _userLearning(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('receipt_learning')
        .doc('v1');
  }

  DocumentReference<Map<String, dynamic>> _globalLearning() {
    return _firestore.collection('global_learning').doc('v1');
  }

  CollectionReference<Map<String, dynamic>> _globalContributions() {
    return _firestore.collection('global_contributions_v1');
  }

  static List<String> _changedFields(Receipt before, Receipt after) {
    final fields = <String>[];
    if (normalizeText(before.merchant ?? '') !=
        normalizeText(after.merchant ?? '')) {
      fields.add('merchant');
    }
    if (before.total != after.total) fields.add('total');
    if (before.subtotal != after.subtotal) fields.add('subtotal');
    if (before.tax != after.tax) fields.add('tax');
    if (!_sameDay(before.date, after.date)) fields.add('date');
    if ((before.paymentMethod ?? '') != (after.paymentMethod ?? '')) {
      fields.add('paymentMethod');
    }
    if ((before.receiptNumber ?? '') != (after.receiptNumber ?? '')) {
      fields.add('receiptNumber');
    }
    if (!_areItemsEqual(before.items, after.items)) {
      fields.add('items');
    }
    return fields;
  }

  static bool _areItemsEqual(List<ReceiptItem>? a, List<ReceiptItem>? b) {
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _docId(String value) {
    final normalized = normalizeText(value);
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}
