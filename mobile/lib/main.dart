import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/pages/welcome.dart';
import 'package:mobile/pages/login.dart';
import 'package:mobile/pages/register.dart';
import 'package:mobile/main_wrapper.dart';
import 'package:mobile/providers/theme_provider.dart';
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
    final seedColor = ref.watch(themeColorProvider);

    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'MoiPari',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorSchemeSeed: seedColor,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
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
        return MaterialPageRoute(builder: (context) => const MainWrapper());
      },
    );
  }
}
