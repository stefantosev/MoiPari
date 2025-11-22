import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/pages/add_edit_expense.dart';
import '../providers/real_provider.dart';

class ExpensePage extends ConsumerWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: expenseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(
              child: Text('No expenses found.'),
            );
          }

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final e = expenses[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.category, color: Colors.purple),
                  title: Text(
                    e.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${e.amount} \$"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditExpensePage(expense: e),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref.read(expenseProvider.notifier).deleteExpense(e.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
     
    );
  }
}