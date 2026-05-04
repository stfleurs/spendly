import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/models/category.dart';
import 'package:spendly/core/providers/firebase_providers.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('categories');

  Stream<List<Category>> watchCategories(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  Future<void> addCategory(Category category) async {
    final data = category.toJson();
    data.remove('id');
    await _collection.add(data);
  }

  Future<void> updateCategory(Category category) async {
    final data = category.toJson();
    data.remove('id');
    await _collection.doc(category.id).update(data);
  }

  Future<void> deleteCategory(String id) async {
    await _collection.doc(id).delete();
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(firestoreProvider));
});

final categoriesStreamProvider = StreamProvider.family<List<Category>, String>((ref, userId) {
  return ref.watch(categoryRepositoryProvider).watchCategories(userId);
});
