import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/service/auth_service.dart';
import '../service/budget_service_2.dart';

class CreditCardWidget extends ConsumerStatefulWidget {
  const CreditCardWidget({super.key});

  @override
  ConsumerState<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends ConsumerState<CreditCardWidget> {
  final BudgetService _budgetService = BudgetService();
  double? _totalBudget;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTotalBudget();
  }

  Future<void> _loadTotalBudget() async {
    if (!AuthService.isLoggedIn) {
      setState(() {
        _totalBudget = null;
        _isLoading = false;
      });
      return;
    }

    try {
      final userId = await AuthService.getUserId();
      if (userId == null) {
        setState(() {
          _totalBudget = null;
          _isLoading = false;
        });
        return;
      }

      final now = DateTime.now();

      final Map<String, dynamic> budget = await _budgetService.getRemainingBudget(1,2026);

      setState(() {
        _totalBudget = budget['remaining'];
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      print("Error loading total budget: $e");
      setState(() {
        _totalBudget = null;
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAuth = authState.isAuthenticated;
    final cardHolderName = isAuth ? "AUTHENTICATED USER" : "GUEST USER";

    final now = DateTime.now();
    final displayMonthYear = "${now.month.toString().padLeft(2, '0')}/${now.year}";

    void navigateToBudget() {
      if (!isAuth) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to manage budgets.')),
        );
        return;
      } else {
        ref.read(navigationIndexProvider.notifier).state = 1;
      }
    }

    String budgetDisplay;
    if (!isAuth) {
      budgetDisplay = "N/A";
    } else if (_isLoading) {
      budgetDisplay = "Loading...";
    } else if (_error != null) {
      budgetDisplay = "Error";
    } else if (_totalBudget == null) {
      budgetDisplay = "No Budget";
    } else {
      budgetDisplay = "MKD ${_totalBudget!.toStringAsFixed(2)}";
    }

    return GestureDetector(
      onTap: navigateToBudget,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCreditCard(
              color: const Color(0xFF090943),
              cardExpiration: displayMonthYear,
              cardHolder: cardHolderName,
              cardNumber: budgetDisplay,
            ),
          ],
        ),
      ),
    );
  }

  Card _buildCreditCard({
    required Color color,
    required String cardNumber,
    required String cardHolder,
    required String cardExpiration,
  }) {
    return Card(
      elevation: 8.0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 200,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 22, top: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildLogosBlock(),
            const Spacer(),
            Text(
              cardNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildDetailsBlock(label: "CARDHOLDER", value: cardHolder),
                _buildDetailsBlock(label: "TOTAL BUDGET FOR", value: cardExpiration),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row _buildLogosBlock() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Image.asset("assets/images/contact_less.png", height: 20, width: 18),
        Image.asset("assets/images/mastercard.png", height: 50, width: 50),
      ],
    );
  }

  Column _buildDetailsBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}