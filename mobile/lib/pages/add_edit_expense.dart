import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/models/DTO/expense_request.dart';
import 'package:mobile/models/expense.dart';
import 'package:mobile/providers/real_provider.dart';

class AddEditExpensePage extends ConsumerStatefulWidget {
  final Expense? expense;

  const AddEditExpensePage({super.key, this.expense});

  @override
  ConsumerState<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends ConsumerState<AddEditExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectPaymentMethod;


List<int> _selectedCategoryIds = [];

  

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description;
      _selectedDate = widget.expense!.date;
      _selectPaymentMethod = widget.expense!.paymentMethod;
      _selectedCategoryIds = List.from(widget.expense!.categoryIds);
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
  if (_formKey.currentState!.validate()) {
    final expenseRequest = ExpenseRequest(
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      date: _selectedDate,
      paymentMethod: _selectPaymentMethod,
      categoryIds: _selectedCategoryIds,
    );

    if (widget.expense == null) {
      ref.read(expenseProvider.notifier).addExpense(expenseRequest);
    } else {
      ref.read(expenseProvider.notifier).updateExpense(widget.expense!.id, expenseRequest);
    }

    Navigator.pop(context);
  }
}

void _selectCategories() {
  final categoriesAsync = ref.read(categoryProvider);
  
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
                data: (categories) {
                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return CheckboxListTile(
                          title: Text(category.name),
                          value: _selectedCategoryIds.contains(category.id),
                          onChanged: (bool? selected) {
                            setDialogState(() {
                              if (selected == true) {
                                _selectedCategoryIds.add(category.id);
                              } else {
                                _selectedCategoryIds.remove(category.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      backgroundColor: Colors.deepPurpleAccent,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            ListTile(
              title: Text(
                _selectedDate == null 
                  ? 'Select Date' 
                  : 'Date: ${_selectedDate!.toString().split(' ')[0]}'
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                DropdownMenuItem(value: 'CARD', child: Text('Credit Card')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectPaymentMethod = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a payment method';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Categories'),
              subtitle: Text(
                _selectedCategoryIds.isEmpty 
                  ? 'Select categories' 
                  : '${_selectedCategoryIds.length} category selected'
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectCategories,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                widget.expense == null ? 'Add Expense' : 'Update Expense',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            if (widget.expense != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
}
