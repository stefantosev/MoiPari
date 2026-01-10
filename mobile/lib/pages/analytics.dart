import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mobile/service/expense_service.dart';
import 'package:mobile/service/auth_service.dart';

import '../models/expense.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final ExpenseService _expenseService = ExpenseService();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  Map<String, double> _categoryData = {};
  Map<String, double> _paymentMethodData = {};
  Map<String, double> _monthlyData = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      _analyticsData = {
        'totalSpent': await _expenseService.getTotalSpentBetween(_startDate, _endDate),
        'categoryBreakdown': await _expenseService.getExpensesByCategoryForPeriod(_startDate, _endDate),
        'paymentMethodBreakdown': await _expenseService.getPaymentMethodBreakdown(_startDate, _endDate),
      };

      if (_analyticsData['categoryBreakdown'] is Map<String, List<Expense>>) {
        final categoryMap = _analyticsData['categoryBreakdown'] as Map<String, List<Expense>>;
        _categoryData = {};
        categoryMap.forEach((category, expenses) {
          final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
          _categoryData[category] = total;
        });
      }

      if (_analyticsData['paymentMethodBreakdown'] is Map<String, double>) {
        _paymentMethodData = _analyticsData['paymentMethodBreakdown'] as Map<String, double>;
      }

      _monthlyData = await _expenseService.getMonthlySpending(DateTime.now().year);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null && picked != DateTimeRange(start: _startDate, end: _endDate)) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAnalyticsData();
    }
  }

  Widget _buildTotalSpentCard() {
    final total = (_analyticsData['totalSpent'] as double?) ?? 0.0;
    final days = _endDate.difference(_startDate).inDays;
    final averagePerDay = days > 0 ? total / days : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Spent',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Average per day: \$${averagePerDay.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    if (_categoryData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No category data available')),
        ),
      );
    }

    final chartData = _categoryData.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <CircularSeries>[
                  PieSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySpendingChart() {
    if (_monthlyData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No monthly data available')),
        ),
      );
    }

    final chartData = _monthlyData.entries
        .map((entry) => _ChartData(
      DateFormat('MMM').format(DateTime.parse(entry.key)),
      entry.value,
    ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Spending (${DateTime.now().year})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  labelFormat: '\${value}',
                ),
                series: <CartesianSeries>[
                  ColumnSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChart() {
    if (_paymentMethodData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No payment method data available')),
        ),
      );
    }

    final chartData = _paymentMethodData.entries
        .map((entry) => _ChartData(entry.key, entry.value))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Methods',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: SfCircularChart(
                series: <CircularSeries>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTotalSpentCard(),
            const SizedBox(height: 16),
            _buildCategoryPieChart(),
            const SizedBox(height: 16),
            _buildMonthlySpendingChart(),
            const SizedBox(height: 16),
            _buildPaymentMethodChart(),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Stats',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildStatItem(
                      'Date Range',
                      '${_dateFormat.format(_startDate)} - ${_dateFormat.format(_endDate)}',
                    ),
                    _buildStatItem(
                      'Days',
                      _endDate.difference(_startDate).inDays.toString(),
                    ),
                    _buildStatItem(
                      'Categories Tracked',
                      _categoryData.length.toString(),
                    ),
                    _buildStatItem(
                      'Payment Methods Used',
                      _paymentMethodData.length.toString(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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