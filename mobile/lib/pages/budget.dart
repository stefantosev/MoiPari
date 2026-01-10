import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/budget.dart';
import 'package:mobile/service/budget_service.dart';
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
  bool _showSingleBudget = true;

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
      } else {

      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete budget: $e")),
      );
    }
  }

  Future<void> _toggleCurrency() async {
    if (_isConverting) return;

    setState(() => _isConverting = true);

    try {
      if (_currentCurrency == "MKD") {
        // final rate = await _services.convertCurrency(1.0, "MKD", "EUR");
        setState(() {
          _currentCurrency = 'EUR';
          // _conversionRate = rate;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Currency conversion failed: $e")),
      );
    }
  }

  double _convertAmount(double amount) {
    return amount * _conversionRate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPopup(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, size: 30),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.deepPurpleAccent,
        child: Stack(
          children: [
            Positioned(
              top: 50,
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
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          );
        }

        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final budget = snapshot.data;

        if (budget == null) {
          return _buildEmpty();
        }

        return Column(
          children: [
            _buildBudgetCard(budget),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isConverting ? null : _toggleCurrency,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              icon: _isConverting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
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
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          );
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
                if (index < budgets.length - 1)
                  const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _refresh,
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 60,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            "No budget created yet.\nTap + to add one!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Budget ${budget.month.toString().padLeft(2, '0')}/${budget.year}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.calendar_month, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Monthly Budget",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              "${_convertAmount(budget.monthlyLimit).toStringAsFixed(2)} $_currentCurrency",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),


    ])));
  }
}