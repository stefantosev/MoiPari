import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/service/budget_service_2.dart';
import '../models/budget.dart';

class BudgetPopup extends ConsumerStatefulWidget {
  final Budget? budget;

  const BudgetPopup({super.key, this.budget});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BudgetPopupState();
}

class _BudgetPopupState extends ConsumerState<BudgetPopup> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  final BudgetService _service = BudgetService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      _amountController.text = widget.budget!.monthlyLimit.toStringAsFixed(2);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(
        isEditing ? "Edit Budget" : "Create New Budget",
        style: theme.textTheme.titleLarge,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Budget Amount",
                hintText: "Enter amount",
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainer.withValues(alpha: .3),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid number';
                }
                if (amount <= 0) {
                  return 'Amount must be greater than 0';
                }
                if (amount > 1000000) {
                  return 'Amount is too large';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _monthController,
                    keyboardType: TextInputType.number,
                    readOnly: isEditing,
                    decoration: InputDecoration(
                      labelText: "Month",
                      hintText: "MM",
                      prefixIcon: const Icon(Icons.calendar_month),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isEditing
                          ? colorScheme.onSurface.withValues(alpha: .05)
                          : colorScheme.surfaceContainerHigh.withValues(
                              alpha: .3,
                            ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a month';
                      }
                      final month = int.tryParse(value);
                      if (month == null || month < 1 || month > 12) {
                        return 'Enter a valid month (1-12)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    readOnly: isEditing,
                    decoration: InputDecoration(
                      labelText: "Year",
                      hintText: "YYYY",
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isEditing
                          ? colorScheme.onSurface.withValues(alpha: .05)
                          : colorScheme.surfaceContainerHighest.withValues(
                              alpha: .3,
                            ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a year';
                      }
                      final year = int.tryParse(value);
                      final currentYear = DateTime.now().year;
                      if (year == null ||
                          year < 2000 ||
                          year > currentYear + 5) {
                        return 'Enter a valid year (2000-${currentYear + 5})';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            if (!isEditing) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Month and year cannot be changed after creation",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitBudget,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(100, 48),
          ),
          child: _isSubmitting
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(isEditing ? "Save Changes" : "Create Budget"),
        ),
      ],
    );
  }

  Future<void> _submitBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final double amount = double.parse(_amountController.text.trim());
      final int month = int.parse(_monthController.text.trim());
      final int year = int.parse(_yearController.text.trim());

      if (widget.budget != null) {
        await _service.updateBudget(
          id: widget.budget!.id,
          amount: amount,
          month: month,
          year: year,
          currency: "USD",
        );
        if (mounted) {
          _showSuccessSnackbar("Budget updated successfully!");
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
          _showSuccessSnackbar("Budget created successfully!");
          Navigator.pop(context, "created");
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackbar(String error) {
    String userMessage;
    if (error.contains('403') || error.contains('Forbidden')) {
      userMessage = "You don't have permission to modify this budget";
    } else if (error.contains('409') || error.contains('Conflict')) {
      userMessage = "A budget already exists for this month and year";
    } else if (error.contains('Network')) {
      userMessage = "Network error. Please check your connection";
    } else {
      userMessage = "Failed to save budget: ${error.split(':').last.trim()}";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.onError),
            const SizedBox(width: 8),
            Expanded(child: Text(userMessage)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
