import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isFirstLaunch;
  final String? error;
  final String? token;
  final String? userId;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isFirstLaunch = true,
    this.error,
    this.token,
    this.userId,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isFirstLaunch,
    String? error,
    String? token,
    String? userId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      error: error ?? this.error,
      token: token ?? this.token,
      userId: userId ?? this.userId,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState()) {
    _checkAuthStatus();
    _checkFirstLaunch();
  }

  Future<void> _checkAuthStatus() async {
    final isAuthenticated = await AuthService.checkAuthStatus();
    state = state.copyWith(isAuthenticated: isAuthenticated);
  }

  Future<void> _checkFirstLaunch() async {
    final isFirstLaunch = await AuthService.isFirstLaunch();
    state = state.copyWith(isFirstLaunch: isFirstLaunch);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.login(email, password);

      if (result['success'] == true) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: result['token'],
        );
      } else {
        state = state.copyWith(isLoading: false, error: result['error']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Login failed: $e');
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AuthService.register(email, password, name);

      // after successful registration login the user
      if (result.containsKey('id')) {
        await login(email, password);
      } else {
        state = state.copyWith(isLoading: false, error: 'Registration failed');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed: $e',
      );
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = AuthState(isFirstLaunch: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }


  Future<void> completeWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFirstLaunch", false);
    state = AuthState(
      isFirstLaunch: false,
      isAuthenticated: state.isAuthenticated,
    );
  }
}
