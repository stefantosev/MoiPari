import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/service/budget_service.dart';

import '../service/budget_service_2.dart';

final totalBudgetProvider = FutureProvider.autoDispose<double?>((ref) async{
    final authState = ref.watch(authStateProvider);
    final budgetService = BudgetService();

    if(!authState.isAuthenticated || authState.token == null || authState.userId == null){
      return null;
    }

    final userIdInt = int.tryParse(authState.userId!);
    if(userIdInt == null) return null;
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    try{
    } catch (e){
      debugPrint("Error fetching total budget: $e");
      return null;
    }
});