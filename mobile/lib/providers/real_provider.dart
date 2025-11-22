import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/models/DTO/expense_request.dart';
import 'package:mobile/service/category_service.dart';
import 'package:mobile/models/category.dart';
import '../models/expense.dart';
import '../service/expense_service.dart';



final categoryProvider = FutureProvider<List<Category>>((ref) async {
  final service = CategoryService();
  return await service.getCategories();
});

final expenseProvider = StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
  return ExpenseNotifier();
});

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseService _expenseService = ExpenseService();

  ExpenseNotifier() : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final expenses = await _expenseService.getExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addExpense(ExpenseRequest expenseRequest) async {
    try {
      await _expenseService.createExpense(expenseRequest);
      await _loadExpenses();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateExpense(int expenseId, ExpenseRequest expenseRequest) async {
    try {
      await _expenseService.updateExpense(expenseId, expenseRequest);
      await _loadExpenses(); 
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    try {
      await _expenseService.deleteExpense(expenseId);
      await _loadExpenses(); 
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}