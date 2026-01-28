import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/models/DTO/expense_request.dart';
import 'package:mobile/service/category_service.dart';
import 'package:mobile/models/category.dart';
import '../models/expense.dart';
import '../service/expense_service.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
      return CategoryNotifier();
    });

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryService _categoryService = CategoryService();

  CategoryNotifier() : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _categoryService.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refreshCategories() async {
    await loadCategories();
  }
}

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
      return ExpenseNotifier();
    });

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _allExpenses = [];

  ExpenseNotifier() : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _expenseService.getExpenses();
      _allExpenses = expenses;
      state = AsyncValue.data(expenses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void showAllExpenses() {
    state = AsyncValue.data(_allExpenses);
  }

  Future<void> addExpense(ExpenseRequest expenseRequest) async {
    try {
      await _expenseService.createExpense(expenseRequest);
      await loadExpenses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateExpense(
    int expenseId,
    ExpenseRequest expenseRequest,
  ) async {
    try {
      await _expenseService.updateExpense(expenseId, expenseRequest);
      await loadExpenses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    try {
      await _expenseService.deleteExpense(expenseId);
      await loadExpenses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
