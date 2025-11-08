import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/pages/home.dart';
import 'package:mobile/pages/login.dart';
import 'package:mobile/pages/register.dart';
import 'package:mobile/pages/tracker_home.dart';
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
        return HomePage();
      case 3:
        return FinanceTrackerHome();
      default:
        return HomePage();
    }
  }
}
