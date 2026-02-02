import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/exceptions/budget_exceptions.dart';
import 'package:mobile/models/budget.dart';
import 'package:mobile/widgets/budget_popup.dart';

import '../service/budget_service_2.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  final BudgetService _service = BudgetService();
  Future<List<Budget>>? _budgetsFuture;

  Future<Budget?>? _currentBudgetFuture;
  final bool _showSingleBudget = true;

  String _currentCurrency = 'MKD';
  double _conversionRate = 1;
  bool _isConverting = false;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    setState(() {
      if (_showSingleBudget) {
        _currentBudgetFuture = _service.getCurrentBudget();
        _budgetsFuture = null;
      } else {}
    });
  }

  void _refresh() {
    _loadBudgets();
  }

  void _openPopup({Budget? edit}) async {
    final result = await showDialog(
      context: context,
      builder: (_) => BudgetPopup(budget: edit),
    );

    if (result == "created" || result == "updated") {
      _refresh();
    }
  }

  void _handleDelete(int budgetId) async {
    try {
      await _service.deleteBudget(budgetId);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete budget: $e"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _toggleCurrency() async {
    if (_isConverting) return;

    setState(() => _isConverting = true);

    try {
      if (_currentCurrency == "MKD") {
        setState(() {
          _currentCurrency = 'EUR';
          _conversionRate = 0.016;
          _isConverting = false;
        });
      } else {
        setState(() {
          _currentCurrency = 'MKD';
          _conversionRate = 1.0;
          _isConverting = false;
        });
      }
    } catch (e) {
      setState(() => _isConverting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Currency conversion failed: $e")));
    }
  }

  double _convertAmount(double amount) {
    return amount * _conversionRate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPopup(),
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, size: 30),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: colorScheme.primary,
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _showSingleBudget
                    ? _buildSingleBudgetView()
                    : _buildMultipleBudgetsView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleBudgetView() {
    return FutureBuilder<Budget?>(
      future: _currentBudgetFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error);
        }

        final budget = snapshot.data;

        if (budget == null) {
          return _buildEmpty();
        }

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Column(
          children: [
            _buildBudgetCard(budget),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isConverting ? null : _toggleCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              icon: _isConverting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.currency_exchange),
              label: Text(
                'Convert ($_currentCurrency)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMultipleBudgetsView() {
    return FutureBuilder<List<Budget>>(
      future: _budgetsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final budgets = snapshot.data ?? [];

        if (budgets.isEmpty) {
          return _buildEmpty();
        }

        return ListView.builder(
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            final budget = budgets[index];
            return Column(
              children: [
                _buildBudgetCard(budget),
                if (index < budgets.length - 1) const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildError(Object? error) {
    if (error is NoBudgetSetExcpetion) {
      return _buildNoBudgetSetView();
    } else if (error is BudgetServiceException) {
      return _buildServiceError(error);
    } else {
      return _buildGenericError(error.toString());
    }
  }

  Widget _buildNoBudgetSetView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 96,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Budget Set For This Month',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't set a budget for this month yet. "
              "Create one to start tracking your expenses!",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: .8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openPopup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: const Text(
                "Set Budget for This Month",
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _refresh,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 60,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            "No budget created yet.\nTap + to add one!",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 5,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            _openPopup(edit: budget);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Budget ${budget.month.toString().padLeft(2, '0')}/${budget.year}",
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.calendar_month, color: colorScheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Monthly Limit",
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${_convertAmount(budget.monthlyLimit).toStringAsFixed(2)} $_currentCurrency",
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceError(BudgetServiceException error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 50),
            const SizedBox(height: 16),
            Text(
              "Something Went Wrong",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            if (error.statusCode != null) ...[
              const SizedBox(height: 8),
              Text(
                "Error Code: ${error.statusCode}",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: .7),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text("Retry"),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text("Get help??"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericError(String error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: colorScheme.error, size: 40),
          const SizedBox(height: 16),
          Text(
            "An Error Occured",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
