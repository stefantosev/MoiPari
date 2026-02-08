import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/models/DTO/expense_request.dart';
import 'package:mobile/service/category_service.dart';
import 'package:mobile/models/category.dart';
import '../models/expense.dart';
import '../service/expense_service.dart';

// service providers
final expenseServiceProvider = Provider((ref) => ExpenseService());
final categoryServiceProvider = Provider((ref) => CategoryService());

// state providers
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
      return CategoryNotifier(ref.watch(categoryServiceProvider));
    });

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
      return ExpenseNotifier(ref.watch(expenseServiceProvider));
    });

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryService _categoryService;

  CategoryNotifier(this._categoryService) : super(const AsyncValue.loading()) {
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

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseService _expenseService;
  List<Expense> _allExpenses = [];

  ExpenseNotifier(this._expenseService) : super(const AsyncValue.loading()) {
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

final categorySpendingProvider = Provider<Map<String, double>>((ref) {
  final expensesAsync = ref.watch(expenseProvider);
  final categoriesAsync = ref.watch(categoryProvider);

  if (expensesAsync is AsyncData && categoriesAsync is AsyncData) {
    final expenses = expensesAsync.value!;
    final categories = categoriesAsync.value!;
    final Map<String, double> categoryMap = {};

    for (var expense in expenses) {
      if (expense.categoryIds.isNotEmpty) {
        final categoryId = expense.categoryIds.first;
        final category = categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => Category(-1, "Unknown", "category", "red", 0, [0]),
        );
        categoryMap[category.name] =
            (categoryMap[category.name] ?? 0) + expense.amount;
      }
    }
    return categoryMap; 
  }
  return {};
});

final weeklySpendingProvider = Provider<Map<int, double>>((ref) {
  final expensesAsync = ref.watch(expenseProvider);
  
  return expensesAsync.maybeWhen(
    data: (expenses) {
      final Map<int, double> weeklyMap = {
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
        7: 0,
      };
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      for (var expense in expenses) {
        if (expense.date.isAfter(weekStart)) {
          final day = expense.date.weekday;
          weeklyMap[day] = (weeklyMap[day] ?? 0) + expense.amount;
        }
      }
      return weeklyMap;
    },
    orElse: () => {},
  );
});


final monthlySpendingProvider = Provider<Map<int, double>>((ref) {
  final expensesAsync = ref.watch(expenseProvider);
  
  return expensesAsync.maybeWhen(
    data: (expenses) {
      final Map<int, double> monthlyMap = {};
      final now = DateTime.now();
      
      // last 6 months
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        monthlyMap[month.month] = 0;
      }
      
      for (var expense in expenses) {
        final monthKey = expense.date.month;
        if (monthlyMap.containsKey(monthKey)) {
          monthlyMap[monthKey] = (monthlyMap[monthKey] ?? 0) + expense.amount;
        }
      }
      return monthlyMap;
    },
    orElse: () => {},
  );
});

