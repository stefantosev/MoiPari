import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../service/expense_service.dart';

final expenseProvider = FutureProvider<List<Expense>>((ref) async {
  final service = ExpenseService();
  return service.getExpenses();
});