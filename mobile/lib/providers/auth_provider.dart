import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier();
});

class AuthState {
  final bool isFirstLaunch;
  final bool isAuthenticated;

  AuthState({required this.isFirstLaunch, required this.isAuthenticated});
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier()
    : super(AuthState(
      isFirstLaunch: true,
      // TODO: set to false when we get auth working in the backend
      isAuthenticated: true)) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool("isFirstLaunch") ?? true;
    // TODO: set to false when we get auth working in the backend
    final isAuthenticated = prefs.getBool("isAuthenticated") ?? true;

    state = AuthState(
      isFirstLaunch: isFirstLaunch,
      isAuthenticated: isAuthenticated,
    );
  }

  Future<void> completeWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFirstLaunch", false);
    state = AuthState(
      isFirstLaunch: false,
      isAuthenticated: state.isAuthenticated,
    );
  }

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isAuthenticated", true);
    state = AuthState(
      isFirstLaunch: state.isFirstLaunch,
      isAuthenticated: true,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isAuthenticated", false);
    state = AuthState(
      isFirstLaunch: state.isFirstLaunch,
      isAuthenticated: false,
    );
  }
}
