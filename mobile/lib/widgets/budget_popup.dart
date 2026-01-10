import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/service/budget_service.dart';
import '../models/budget.dart';
import '../service/budget_service_2.dart';

class BudgetPopup extends ConsumerStatefulWidget {
  final Budget? budget;

  const BudgetPopup({
    super.key,
    this.budget,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BudgetPopupState();
}

class _BudgetPopupState extends ConsumerState<BudgetPopup> {
  final _amountController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  final BudgetService _service = BudgetService();

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      _amountController.text = widget.budget!.monthlyLimit.toString();
      _monthController.text = widget.budget!.month.toString();
      _yearController.text = widget.budget!.year.toString();
    } else {
      final now = DateTime.now();
      _monthController.text = now.month.toString();
      _yearController.text = now.year.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.budget != null;

    return AlertDialog(
      title: Text(isEditing ? "Edit Budget" : "Add Budget"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Budget Amount",
              hintText: "Enter amount",
              prefixText: "\$",
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _monthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Month",
                    hintText: "1-12",
                  ),
                  readOnly: isEditing,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Year",
                    hintText: "e.g., 2024",
                  ),
                  readOnly: isEditing,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submitBudget,
          child: Text(isEditing ? "Save" : "Create"),
        ),
      ],
    );
  }

  Future<void> _submitBudget() async {
    try {
      final double amount = double.tryParse(_amountController.text.trim()) ?? 0;
      final int month = int.tryParse(_monthController.text.trim()) ?? 0;
      final int year = int.tryParse(_yearController.text.trim()) ?? 0;

      if (amount <= 0) {
        throw Exception("Amount must be greater than 0");
      }
      if (month < 1 || month > 12) {
        throw Exception("Month must be between 1 and 12");
      }
      if (year < 2000 || year > 2100) {
        throw Exception("Year must be between 2000 and 2100");
      }

      if (widget.budget != null) {
        await _service.updateBudget(
          id: widget.budget!.id,
          amount: amount,
          month: month,
          year: year,
          currency: "USD",
        );
        if (mounted) {
          Navigator.pop(context, "updated");
        }
      } else {
        await _service.createOrUpdateBudget(
          amount: amount,
          month: month,
          year: year,
          currency: 'USD',
        );
        if (mounted) {
          Navigator.pop(context, "created");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}