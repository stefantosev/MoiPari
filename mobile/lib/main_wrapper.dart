import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/pages/categories.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/login.dart';
import 'package:mobile/pages/register.dart';
import 'package:mobile/pages/examplePage.dart';
import 'package:mobile/pages/welcome.dart';
import 'package:mobile/widgets/nav_bar.dart';

import 'navigation_provider.dart';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: _getPage(currentIndex),
      bottomNavigationBar: NavBar(),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return LoginPage();
      case 1:
        return RegisterPage();
      case 2:
        return CategoryPage();
      case 3:
        return ExamplePage();
      case 4:
        return WelcomePage();
      default:
        return HomePage();
    }
  }
}
