import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/service/budget_service_2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mobile/service/expense_service.dart';
import 'package:mobile/service/category_service.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/budget.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final ExpenseService _expenseService = ExpenseService();
  final CategoryService _categoryService = CategoryService();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final BudgetService _budgetService = BudgetService();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  Map<String, double> _categoryData = {};
  Map<String, double> _paymentMethodData = {};
  Map<String, double> _monthlyData = {};
  Map<String, List<Expense>> _categoryExpensesMap = {};
  List<Expense> _topExpenses = [];
  Map<int, String> _categoryNameMap = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      final budgetFuture = _budgetService.getCurrentBudget();
      final totalSpentFuture = _expenseService.getTotalSpentBetween(
        _startDate,
        _endDate,
      );
      final categoryBreakdownFuture = _expenseService
          .getExpensesByCategoryForPeriod(_startDate, _endDate);
      final paymentMethodFuture = _expenseService.getPaymentMethodBreakdown(
        _startDate,
        _endDate,
      );
      final monthlySpendingFuture = _expenseService.getMonthlySpending(
        DateTime.now().year,
      );
      final categoriesFuture = _categoryService.getCategories();

      final results = await Future.wait([
        totalSpentFuture,
        categoryBreakdownFuture,
        paymentMethodFuture,
        monthlySpendingFuture,
        categoriesFuture,
        budgetFuture,
      ]);

      final budget = results[5] as Budget?;
      final totalSpent = results[0] as double;

      _analyticsData = {
        'totalSpent': totalSpent,
        'categoryBreakdown': results[1],
        'paymentMethodBreakdown': results[2],
        'totalBudget': budget?.monthlyLimit ?? 0.0,
        'remainingBudget': (budget?.monthlyLimit ?? 0.0) - totalSpent,
      };

      _monthlyData = results[3] as Map<String, double>;
      final categories = results[4] as List<Category>;
      _categoryNameMap = {for (var c in categories) c.id: c.name};

      if (_analyticsData['categoryBreakdown'] is Map<String, List<Expense>>) {
        final categoryMap =
            _analyticsData['categoryBreakdown'] as Map<String, List<Expense>>;
        _categoryData = {};
        _categoryExpensesMap = {};
        List<Expense> allExpensesPeriod = [];

        categoryMap.forEach((key, expenses) {
          if (expenses.isEmpty) return;

          final total = expenses.fold(
            0.0,
            (sum, expense) => sum + expense.amount,
          );

          String label = 'Uncategorized';
          if (expenses.first.categoryIds.isNotEmpty) {
            final id = expenses.first.categoryIds.first;
            label = _categoryNameMap[id] ?? 'Unknown ($id)';
          }

          _categoryData[label] = total;
          _categoryExpensesMap[label] = expenses;
          allExpensesPeriod.addAll(expenses);
        });

        allExpensesPeriod.sort((a, b) => b.amount.compareTo(a.amount));
        _topExpenses = allExpensesPeriod.take(5).toList();
      }

      if (_analyticsData['paymentMethodBreakdown'] is Map<String, double>) {
        _paymentMethodData =
            _analyticsData['paymentMethodBreakdown'] as Map<String, double>;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading analytics: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null &&
        picked != DateTimeRange(start: _startDate, end: _endDate)) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAnalyticsData();
    }
  }

  void _showMonthlyExpenses(String monthYearStr) async {
    try {
      final date = DateTime.parse(monthYearStr);
      final startDate = DateTime(date.year, date.month, 1);
      final endDate = DateTime(date.year, date.month + 1, 0);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final expenses = await _expenseService.getExpensesForPeriod(
        startDate,
        endDate,
      );

      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Expenses for ${DateFormat('MMMM yyyy').format(date)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: expenses.isEmpty
                      ? const Center(child: Text('No expenses for this month'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            String categoryName = 'Uncategorized';
                            if (expense.categoryIds.isNotEmpty) {
                              categoryName =
                                  _categoryNameMap[expense.categoryIds.first] ??
                                  'Unknown';
                            }

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurpleAccent
                                    .withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.receipt,
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                              title: Text(expense.description),
                              subtitle: Text(categoryName),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${expense.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'MMM dd',
                                    ).format(expense.date ?? DateTime.now()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      );
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading monthly expenses: $e")),
      );
    }
  }

  void _showCategoryExpenses(String categoryLabel) {
    final expenses = _categoryExpensesMap[categoryLabel] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '$categoryLabel Expenses',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Text('No expenses for this category'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurpleAccent
                                  .withValues(alpha: 0.1),
                              child: Icon(
                                Icons.receipt,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                            title: Text(expense.description),
                            subtitle: Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(expense.date ?? DateTime.now()),
                            ),
                            trailing: Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: const Text('Analytics'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAnalyticsData,
          ),
        ],
      ),
      body: _isLoading
          ? Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAnalyticsData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDateSelector(),
                              const SizedBox(height: 20),
                              _buildSummaryCards(),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Spending Overview'),
                              const SizedBox(height: 12),
                              _buildCategoryChart(),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Payment Methods'),
                              const SizedBox(height: 12),
                              _buildPaymentMethodChart(),
                              const SizedBox(height: 24),
                              _buildSectionTitle(
                                'Monthly Trends (Tap to view details)',
                              ),
                              const SizedBox(height: 12),
                              _buildMonthlyChart(),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Top Expenses'),
                              const SizedBox(height: 12),
                              _buildTopExpensesList(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDateSelector() {
    return Center(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        elevation: 4,
        child: InkWell(
          onTap: _selectDateRange,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.deepPurpleAccent,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final total = (_analyticsData['totalSpent'] as double?) ?? 0.0;
    final remainingBudget =
        (_analyticsData['remainingBudget'] as double?) ?? 0.0;
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Total Spent',
            '\$${total.toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            'Remaining',
            '\$${remainingBudget.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            remainingBudget >= 0 ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            'Categories',
            '${_categoryData.length}',
            Icons.category,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    if (_categoryData.isEmpty) {
      return _buildEmptyState('No spending data for this period');
    }

    final chartData =
        _categoryData.entries
            .map((entry) => _ChartData(entry.key, entry.value))
            .toList()
          ..sort((a, b) => b.y.compareTo(a.y));

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SfCircularChart(
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          iconHeight: 10,
          iconWidth: 10,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        series: <CircularSeries>[
          DoughnutSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: const TextStyle(
                fontSize: 10,
                color: Colors.deepPurpleAccent,
              ),
              builder:
                  (
                    dynamic data,
                    dynamic point,
                    dynamic series,
                    int pointIndex,
                    int seriesIndex,
                  ) {
                    return Text(
                      '\$${(data as _ChartData).y.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
            ),
            innerRadius: '60%',
            startAngle: 90,
            endAngle: 90,
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex != null &&
                  details.pointIndex! < chartData.length) {
                final data = chartData[details.pointIndex!];
                _showCategoryExpenses(data.x);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    if (_monthlyData.isEmpty) {
      return _buildEmptyState('No monthly data available');
    }

    final chartData = _monthlyData.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          axisLabelFormatter: (AxisLabelRenderDetails details) {
            try {
              final date = DateTime.parse(details.text);
              return ChartAxisLabel(
                DateFormat('MMM').format(date),
                details.textStyle,
              );
            } catch (e) {
              return ChartAxisLabel(details.text, details.textStyle);
            }
          },
        ),
        primaryYAxis: NumericAxis(
          isVisible: false,
          majorGridLines: const MajorGridLines(width: 0),
        ),
        plotAreaBorderWidth: 0,
        series: <CartesianSeries>[
          ColumnSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.x,
            yValueMapper: (_ChartData data, _) => data.y,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              textStyle: const TextStyle(fontSize: 10),
              builder:
                  (
                    dynamic data,
                    dynamic point,
                    dynamic series,
                    int pointIndex,
                    int seriesIndex,
                  ) {
                    return Text(
                      '\$${(data as _ChartData).y.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
            ),
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(4),
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex != null &&
                  details.pointIndex! < chartData.length) {
                final data = chartData[details.pointIndex!];
                _showMonthlyExpenses(data.x);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopExpensesList() {
    if (_topExpenses.isEmpty) {
      return _buildEmptyState('No expenses found');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _topExpenses.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final expense = _topExpenses[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: const Icon(Icons.receipt_long, color: Colors.grey),
            ),
            title: Text(
              expense.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              expense.date != null
                  ? _dateFormat.format(expense.date!)
                  : 'Unknown Date',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            trailing: Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethodChart() {
    if (_paymentMethodData.isEmpty) {
      return _buildEmptyState('No payment method data');
    }

    final chartData =
        _paymentMethodData.entries
            .map((entry) => _ChartData(entry.key, entry.value))
            .toList()
          ..sort((a, b) => b.y.compareTo(a.y));

    final total = _paymentMethodData.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    return Column(
      children: [
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SfCircularChart(
            legend: Legend(
              isVisible: true,
              position: LegendPosition.right,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            series: <CircularSeries>[
              PieSeries<_ChartData, String>(
                dataSource: chartData,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: const TextStyle(fontSize: 10),
                  builder:
                      (
                        dynamic data,
                        dynamic point,
                        dynamic series,
                        int pointIndex,
                        int seriesIndex,
                      ) {
                        return Text(
                          '\$${(data as _ChartData).y.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chartData.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final data = chartData[index];
              final percentage = total > 0 ? (data.y / total * 100) : 0.0;

              IconData icon;
              Color iconColor;

              switch (data.x.toLowerCase()) {
                case 'cash':
                  icon = Icons.money;
                  iconColor = Colors.blue;
                  break;
                case 'credit card':
                case 'card':
                  icon = Icons.credit_card;
                  iconColor = Colors.purple;
                  break;
                default:
                  icon = Icons.payment;
                  iconColor = Colors.grey;
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                title: Text(
                  data.x,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${percentage.toStringAsFixed(1)}% of total',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: Text(
                  '\$${data.y.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _ChartData {
  final String x;
  final double y;

  _ChartData(this.x, this.y);
}
