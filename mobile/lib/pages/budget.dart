import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/budget.dart';
import 'package:mobile/service/budget_service.dart';
import 'package:mobile/widgets/budget_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  final BudgetService _services = BudgetService();
  Future<List<Budget>>? _budgetsFuture;

  Budget? _originalBudget;
  String _currentCurrency = 'MKD';
  bool _isConverting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrencyPreference();
    _budgetsFuture = _loadBudget();
  }

  Future<List<Budget>> _loadBudget() async {
    final list = await _services.getBudgetByUserId();
    if(list.isNotEmpty){
      _originalBudget = list.first;
    }
    return list;
  }

  Future<void> _loadCurrencyPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCurrency = prefs.getString('currency') ?? 'MKD';
    setState(() {});
  }

  Future<void> _saveCurrencyPreference() async {
    final prefs  = await SharedPreferences.getInstance();
    await prefs.setString('currency', _currentCurrency);

  }

  Future<void> _changeCurrency(String newCurrency) async {
    if(_isConverting) return;
    setState(() => _isConverting = true);
    try{
        _currentCurrency = newCurrency;
        await _saveCurrencyPreference();

    }finally{
      setState(() {
        _isConverting = false;
      });
    }
  }

  Future<double> _convert(double mkdAmount) async{
    if(_currentCurrency == "MKD") return mkdAmount;
    try{
      return await _services.convertCurrency(mkdAmount, 'MKD', _currentCurrency);
    }catch(e){
      return mkdAmount;
    }
  }

  void _refresh() {
    setState(() {
      _budgetsFuture = _loadBudget();
    });
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
      await _services.deleteBudget(budgetId);
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete budget: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FutureBuilder<List<Budget>>(
        future: _budgetsFuture,
        builder: (_, snapshot) {
          final hasBudget =
              snapshot.hasData && (snapshot.data?.isNotEmpty ?? false);

          if (hasBudget) return const SizedBox.shrink();

          return FloatingActionButton(
            onPressed: () => _openPopup(),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add, size: 30),
          );
        },
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
                child: FutureBuilder<List<Budget>>(
                  future: _budgetsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.deepPurpleAccent),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildError(snapshot.error.toString());
                    }

                    final data = snapshot.data ?? [];

                    if (data.isEmpty) {
                      return _buildEmpty();
                    }

                    final budget = data.first;

                    return FutureBuilder(
                        future: _prepareConvertedBudget(budget),
                        builder: (context, convertedSnapshot) {
                          if(!convertedSnapshot.hasData){
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return _buildBudgetCard(convertedSnapshot.data!);
                        }
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<_ConvertedBudget> _prepareConvertedBudget(Budget b) async {
    final limit = await _convert(b.monthlyLimit);
    final remaining = await _convert(b.remainingAmount);

    return _ConvertedBudget(
      limit: limit,
      remaining: remaining,
      used: limit - remaining,
      budget: b,
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
      child: Text(
        "No budget created yet.\nTap + to add one!",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }

  Widget _buildBudgetCard(_ConvertedBudget cb) {
    final b = cb.budget;

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
                  "Budget ${b.month.toString().padLeft(2, '0')}/${b.year}",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.calendar_month, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 20),

            PopupMenuButton<String>(
              icon: const Icon(Icons.currency_exchange,
                  color: Colors.deepPurpleAccent),
              color: Colors.white,
              onSelected: (value) => _changeCurrency(value),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'MKD', child: Text("MKD")),
                PopupMenuItem(value: 'EUR', child: Text("EUR")),
                PopupMenuItem(value: 'USD', child: Text("USD")),
              ],
            ),

            const SizedBox(height: 14),

            const Text("Monthly Limit",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text(
              "${cb.limit.toStringAsFixed(2)} $_currentCurrency",
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 20),

            const Text("Remaining Money",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text(
              "${cb.remaining.toStringAsFixed(2)} $_currentCurrency",
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.green),
            ),

            const SizedBox(height: 20),

            const Text("Used Amount",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            Text(
              "${cb.used.toStringAsFixed(2)} $_currentCurrency",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit,
                      color: Colors.deepPurpleAccent),
                  onPressed: () => _openPopup(edit: b),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _handleDelete(b.id),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ConvertedBudget {
  final double limit;
  final double remaining;
  final double used;
  final Budget budget;

  _ConvertedBudget({
    required this.limit,
    required this.remaining,
    required this.used,
    required this.budget,
  });
}