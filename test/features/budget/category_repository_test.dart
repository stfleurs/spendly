import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/category.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CategoryRepository repository;
  const userId = 'test_user_budget';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = CategoryRepository(fakeFirestore);
  });

  group('CategoryRepository Tests', () {
    test('addCategory should save to users/{userId}/categories', () async {
      final category = Category(
        id: '',
        userId: userId,
        name: 'Dining',
        group: 'Food',
        availableBalance: 0,
      );

      await repository.addCategory(category);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();
      
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['name'], 'Dining');
    });

    test('updateCategory should modify existing document', () async {
      final docRef = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .add({
        'userId': userId,
        'name': 'Old Name',
        'group': 'Old Group',
        'availableBalance': 100,
      });

      final category = Category(
        id: docRef.id,
        userId: userId,
        name: 'New Name',
        group: 'New Group',
        availableBalance: 200,
      );

      await repository.updateCategory(category);

      final updatedDoc = await docRef.get();
      expect(updatedDoc.data()!['name'], 'New Name');
      expect(updatedDoc.data()!['availableBalance'], 200);
    });

    test('deleteCategory should remove document', () async {
      final docRef = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .add({'name': 'To Delete'});
      
      await repository.deleteCategory(userId, docRef.id);

      final deletedDoc = await docRef.get();
      expect(deletedDoc.exists, false);
    });
  });
}
