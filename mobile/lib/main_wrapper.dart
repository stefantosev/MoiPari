import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/pages/add_edit_expense.dart';
import 'package:mobile/pages/analytics.dart';
import 'package:mobile/pages/budget.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/expenses.dart';
import 'package:mobile/pages/auth.dart';
import 'package:mobile/pages/profile.dart';
import 'package:mobile/pages/welcome.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/widgets/nav_bar.dart';

import 'providers/navigation_provider.dart';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentIndex = ref.watch(navigationIndexProvider);


    if (authState.isLoading && !authState.isAuthenticated && !authState.isFirstLaunch) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.isFirstLaunch) {
      return WelcomePage();
    }

    if (!authState.isAuthenticated) {
      return AuthPage();
    }

    return Scaffold(
      body: _getPage(currentIndex),
      bottomNavigationBar: NavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseModal(context);
        },
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return BudgetPage();
      case 2:
        return ExpensePage();
      case 3:
        return AnalyticsPage();
      case 4:
        return ProfilePage();
      default:
        return AuthPage();
    }
  }

void _showAddExpenseModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9, 
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const AddEditExpensePage(),
        ),
      ),
    ),
  );
}
}
 
