import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/expense.dart';
import 'package:mobile/service/expense_service.dart';

class ExamplePage extends StatefulWidget {
  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final ExpenseService _expenseService = ExpenseService();
  late Future<List<Expense>> _expensesFuture;

  final String currentUserId = "1";

  @override
  void initState() {
    super.initState();
    _expensesFuture = _expenseService.getExpensesByUserId(currentUserId);
  }

  void _refreshExpenses() {
    setState(() {
      _expensesFuture = _expenseService.getExpensesByUserId(currentUserId);
    });
  }

  double _calculateTotalBalance(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateTotalIncome(List<Expense> expenses) {
    return expenses
        .where((expense) => expense.amount > 0)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateTotalExpenses(List<Expense> expenses) {
    return expenses
        .where((expense) => expense.amount < 0)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Tracker'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshExpenses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final expenses = snapshot.data!;
            return _buildContent(expenses);
          } else {
            return _buildEmptyState();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildContent(List<Expense> expenses) {
    final totalBalance = _calculateTotalBalance(expenses);
    final totalIncome = _calculateTotalIncome(expenses);
    final totalExpenses = _calculateTotalExpenses(expenses);

    return Column(
      children: [
        _buildBalanceCard(totalBalance, totalIncome, totalExpenses),
        _buildSummaryCards(expenses),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'See All',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildTransactionsList(expenses),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(double totalBalance, double totalIncome, double totalExpenses) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceItem('Income', totalIncome, Colors.green[300]!),
              _buildBalanceItem('Expenses', totalExpenses.abs(), Colors.red[300]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(List<Expense> expenses) {
    final weeklyTotal = _calculateWeeklyTotal(expenses);
    final monthlyTotal = _calculateMonthlyTotal(expenses);
    final yearlyTotal = _calculateYearlyTotal(expenses);

    return Container(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildSummaryCard('Weekly', '\$${weeklyTotal.toStringAsFixed(0)}', Colors.green),
          _buildSummaryCard('Monthly', '\$${monthlyTotal.toStringAsFixed(0)}', Colors.blue),
          _buildSummaryCard('Yearly', '\$${yearlyTotal.toStringAsFixed(0)}', Colors.orange),
        ],
      ),
    );
  }

  double _calculateWeeklyTotal(List<Expense> expenses) {
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    return expenses
        .where((expense) => expense.date != null && expense.date!.isAfter(weekAgo))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateMonthlyTotal(List<Expense> expenses) {
    final monthAgo = DateTime.now().subtract(Duration(days: 30));
    return expenses
        .where((expense) => expense.date != null && expense.date!.isAfter(monthAgo))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateYearlyTotal(List<Expense> expenses) {
    final yearAgo = DateTime.now().subtract(Duration(days: 365));
    return expenses
        .where((expense) => expense.date != null && expense.date!.isAfter(yearAgo))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Widget _buildSummaryCard(String period, String amount, Color color) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 12.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            period,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Expense> expenses) {
    expenses.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildTransactionItem(expense);
      },
    );
  }

  Widget _buildTransactionItem(Expense expense) {
    final categoryText = expense.categoryIds.isEmpty
        ? 'Uncategorized'
        : expense.categoryIds.length == 1
        ? 'Category ${expense.categoryIds.first}'
        : 'Multiple Categories';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: expense.amount > 0
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            expense.amount > 0 ? Icons.arrow_upward : Icons.arrow_downward,
            color: expense.amount > 0 ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          expense.description.isEmpty ? 'No Description' : expense.description,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${expense.date != null ? DateFormat('MMM dd, yyyy').format(expense.date!) : 'No date'} • $categoryText',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '\$${expense.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: expense.amount > 0 ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading expenses...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Failed to load expenses'),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshExpenses,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No expenses found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Add your first expense to get started'),
        ],
      ),
    );
  }

  void _addTransaction() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Transaction'),
          content: Text('Transaction addition functionality would go here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}