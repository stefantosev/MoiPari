import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/pages/categories.dart';
import 'package:mobile/pages/expenses.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/example.dart';
import 'package:mobile/pages/login.dart';
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

    if (authState.isFirstLaunch) {
      return WelcomePage();
    }

    if (!authState.isAuthenticated) {
      return LoginPage();
    }

    return Scaffold(
      body: _getPage(currentIndex),
      bottomNavigationBar: NavBar(),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return CategoryPage();
      case 2:
        return ExamplePage();
      case 3:
        return ExpensePage();
      case 4:
        return Placeholder();
      default:
        return HomePage();
    }
  }
}
