import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/service/auth_service.dart';

class ProfilePage extends ConsumerWidget {
  ProfilePage({super.key});
  final userEmail = AuthService.getUserEmail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final userEmail = AuthService.getUserEmail();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text("Profile"),
      ),
      backgroundColor: theme.colorScheme.primary,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 80),
                  FutureBuilder(
                    future: userEmail,
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "Loading,..",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 40),

                  Column(
                    children: [
                      IconButton(
                        onPressed: () =>
                            ref.read(themeProvider.notifier).toggleTheme(),
                        icon: Icon(
                          isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        ),
                        color: theme.colorScheme.primary,
                      ),
                      Text(
                        "Change Theme",
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: () =>
                              ref.read(authStateProvider.notifier).logout(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.errorContainer,
                            foregroundColor: theme.colorScheme.onErrorContainer,
                          ),
                          child: const Text("Logout"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Future<String?> userEmail;
  final WidgetRef ref;

  const _ProfileContent({required this.userEmail, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 150,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 80),
            _EmailDisplay(userEmail: userEmail),
            SizedBox(height: 40),
            _LogoutButton(ref: ref),
            SizedBox(height: 40),
            _buildChangeThemeMethod(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeThemeMethod(WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            final currentColor = ref.read(themeColorProvider);
            // ref
            //     .read(themeColorProvider.notifier)
            //     .state = currentColor == Colors.deepPurpleAccent
            //     ? Colors.deepPurpleAccent
            //     : Colors.deepPurpleAccent;

            ref.read(themeProvider.notifier).toggleTheme();
            // final currentMode = ref.read(themeModeProvider);
            // ref
            //     .read(themeModeProvider.notifier)
            //     .state = currentMode == ThemeMode.light
            //     ? ThemeMode.dark
            //     : ThemeMode.light;
          },
          icon: Icon(
            ref.watch(themeProvider) ? Icons.light_mode : Icons.dark_mode,
          ),
        ),
        const Text("Change theme"),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            size: 70,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }
}

class _EmailDisplay extends StatelessWidget {
  final Future<String?> userEmail;

  const _EmailDisplay({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userEmail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return Text(
          snapshot.data ?? "No email",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;

  const _LogoutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ref.read(authStateProvider.notifier).logout();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        "Logout",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
