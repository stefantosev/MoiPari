

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/pages/welcome.dart';
import 'package:mobile/pages/login.dart';
import 'package:mobile/pages/register.dart';
import 'package:mobile/main_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Provider was not overridden');
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MoiPari',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const MainWrapper(),
        '/main': (context) => const MainWrapper(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/welcome': (context) => const WelcomePage(),
      },
      initialRoute: '/',

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const MainWrapper(),
        );
      },
    );
  }
}