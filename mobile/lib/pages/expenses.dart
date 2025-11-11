import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/expense.dart';
import 'package:mobile/providers/navigation_provider.dart';
import 'package:mobile/service/expense_service.dart';

class ExpensePage extends ConsumerWidget {
  const ExpensePage({super.key, required this.categoryId});
  final String? categoryId;



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ExpenseService();
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    final expenseFuture = service.getExpensesByCategoryId(
      selectedCategoryId ?? categoryId!,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: _refreshExpenses,
          //   tooltip: 'Refresh Expenses',
          // ),
        ],
      ),
      body: FutureBuilder<List<Expense>>(
        future: expenseFuture,
        builder:  (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final expenses = snapshot.data!;
            if (expenses.isEmpty) {
              return const Center(child: Text('No expenses found for this category.'));
            }
            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  title: Text(expense.description),
                  subtitle: Text('${expense.amount} \$'),
                );
              },
            );
          } else {
            return const Center(child: Text('No data.'));
          }
        },

      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed:() => ,
      //   backgroundColor: Colors.blue,
      //   foregroundColor: Colors.white,
      //   tooltip: 'Add New Expense',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading expenses...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }


  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load expenses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Error: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          // ElevatedButton(
          //   onPressed: _refreshExpenses,
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.deepPurpleAccent,
          //     foregroundColor: Colors.white,
          //   ),
          //   child: const Text('Retry'),
          // ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No expenses found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first expense to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }


  Widget _buildExpenseList(List<Expense> expenses) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          elevation: 2,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.attach_money, color: Colors.blue, size: 20),
            ),
            title: Text(
              '\$${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expense.description.isNotEmpty)
                  Text(
                    expense.description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (expense.date != null)
                  Text(
                    'Date: ${_formatDate(expense.date!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (expense.paymentMethod != null && expense.paymentMethod!.isNotEmpty)
                  Text(
                    'Payment: ${expense.paymentMethod!}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                if (expense.categoryIds.isNotEmpty)
                  Text(
                    'Categories: ${expense.categoryIds.length}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showExpenseDetails(context, expense),
          ),
        );
      },
    );
  }


  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }


  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Expense Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailItem('Amount', '\$${expense.amount.toStringAsFixed(2)}'),
                _buildDetailItem('Description', expense.description),
                if (expense.date != null)
                  _buildDetailItem('Date', _formatDate(expense.date!)),
                if (expense.paymentMethod != null && expense.paymentMethod!.isNotEmpty)
                  _buildDetailItem('Payment Method', expense.paymentMethod!),
                _buildDetailItem('User ID', expense.userId.toString()),
                _buildDetailItem('Category IDs', expense.categoryIds.join(', ')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // void _addNewExpense() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Add new expense functionality to be implemented'),
  //       duration: Duration(seconds: 2),
  //     ),
  //   );
  // }
}
