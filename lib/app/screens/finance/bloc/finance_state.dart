// lib/screens/finance/bloc/finance_state.dart
part of 'finance_bloc.dart';

@immutable
abstract class FinanceState {}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<Map<String, dynamic>> transactions;
  final Map<String, dynamic> summary;
  final String searchQuery;
  final String sortBy;

  FinanceLoaded({
    required this.transactions,
    required this.summary,
    this.searchQuery = '',
    this.sortBy = 'dateDesc',
  });

  List<Map<String, dynamic>> get filteredTransactions {
    if (searchQuery.isEmpty) return transactions;

    return transactions.where((transaction) {
      final query = searchQuery.toLowerCase();
      final clientName = (transaction['clientName'] ?? '')
          .toString()
          .toLowerCase();
      final arena = (transaction['arena'] ?? '').toString().toLowerCase();
      final phone = (transaction['phone'] ?? '').toString();

      return clientName.contains(query) ||
          arena.contains(query) ||
          phone.contains(query);
    }).toList();
  }
}

class FinanceError extends FinanceState {
  final String message;

  FinanceError(this.message);
}

class FinanceExporting extends FinanceState {}

class FinanceExportSuccess extends FinanceState {
  final String message;

  FinanceExportSuccess(this.message);
}
