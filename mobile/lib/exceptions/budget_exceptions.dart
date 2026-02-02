class BudgetException implements Exception {
  final String message;
  final int? statusCode;

  BudgetException(this.message, {this.statusCode});

  @override
  String toString() => 'BudgetException: $message';
}

class NoBudgetSetExcpetion extends BudgetException {
  NoBudgetSetExcpetion()
    : super("No budget set for current month", statusCode: 403);
}

class BudgetServiceException extends BudgetException {
  BudgetServiceException(super.message, {super.statusCode});
}
