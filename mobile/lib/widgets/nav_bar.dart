import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/navigation_provider.dart';

class NavBar extends ConsumerWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return BottomAppBar(
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _buildNavItem(Icons.home, "Home", 0, currentIndex, ref, context),
            _buildNavItem(Icons.wallet, "Budget", 1, currentIndex, ref, context),
            _buildNavItem(Icons.wallet, "Anayltics", 3, currentIndex, ref, context),

            _buildNavItem(Icons.analytics, "Expenses", 2, currentIndex, ref, context),
            _buildNavItem(Icons.person, "Profile", 4, currentIndex, ref, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int currentIndex, WidgetRef ref, BuildContext context) {
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(navigationIndexProvider.notifier).state = index,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 5),
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}