import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/app_user.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final appUserStreamProvider = StreamProvider.family<AppUser?, String>((ref, userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('users').doc(userId).snapshots().map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      return AppUser(
        id: userId,
        name: 'User',
        baseCurrency: 'USD',
        readyToAssign: 0,
        createdAt: DateTime.now(),
      );
    }
    
    final data = snapshot.data()!;
    DateTime createdAt = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAt = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    }

    return AppUser(
      id: snapshot.id,
      name: data['name'] ?? 'User',
      baseCurrency: data['baseCurrency'] ?? 'USD',
      readyToAssign: data['readyToAssign'] ?? 0,
      createdAt: createdAt,
    );
  });
});
