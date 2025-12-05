import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/service/budget_service.dart';
import '../models/budget.dart';

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
  final _limitController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  final BudgetService _service = BudgetService();

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      // Editing
      _limitController.text = widget.budget!.monthlyLimit.toString();
      _monthController.text = widget.budget!.month.toString();
      _yearController.text = widget.budget!.year.toString();
    } else {
      // Creating
      final now = DateTime.now();
      _monthController.text = now.month.toString();
      _yearController.text = now.year.toString();
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
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
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Monthly Limit",
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _monthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Month",
                  ),
                  readOnly: isEditing,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Year",
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
        TextButton(
          onPressed: () async {
            try {
              final double limit = double.tryParse(_limitController.text.trim()) ?? 0;
              final int month = int.tryParse(_monthController.text.trim()) ?? 0;
              final int year = int.tryParse(_yearController.text.trim()) ?? 0;

              if (limit <= 0 || month < 1 || month > 12 || year < 2000) {
                throw Exception("Invalid input");
              }

              if (isEditing) {
                final updatedBudget = Budget(
                  widget.budget!.id,
                  month,
                  year,
                  limit,
                  widget.budget!.userId,
                );
                await _service.updateBudget(updatedBudget);
                Navigator.pop(context, "updated");
              } else {
                final newBudget = Budget(
                  0,
                  month,
                  year,
                  limit,
                  0,
                );
                await _service.createBudget(newBudget);
                Navigator.pop(context, "created");
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            }
          },
          child: Text(isEditing ? "Save" : "Create"),
        ),
      ],
    );
  }
}