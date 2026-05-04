import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/budget/repository/category_repository.dart';
import 'package:spendly/core/models/category.dart';

class UserSeeder {
  final CategoryRepository _categoryRepo;

  UserSeeder(this._categoryRepo);

  Future<void> seedUser(String userId) async {
    // 1. Create default categories
    final defaultCategories = [
      {'name': 'Housing', 'group': 'Housing'},
      {'name': 'Food', 'group': 'Food'},
      {'name': 'Transport', 'group': 'Transport'},
      {'name': 'Utilities', 'group': 'Utilities'},
      {'name': 'Entertainment', 'group': 'Entertainment'},
    ];

    for (final cat in defaultCategories) {
      await _categoryRepo.addCategory(Category(
        id: '',
        userId: userId,
        name: cat['name'] as String,
        group: cat['group'] as String,
        monthlyTarget: 0,
        currency: 'USD',
        recurrence: 'Monthly',
      ));
    }
  }
}

final userSeederProvider = Provider<UserSeeder>((ref) {
  return UserSeeder(
    ref.watch(categoryRepositoryProvider),
  );
});
