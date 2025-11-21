// lib/screens/finance/bloc/finance_event.dart
part of 'finance_bloc.dart';

@immutable
abstract class FinanceEvent {}

class FinanceLoad extends FinanceEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? arenaId;

  FinanceLoad({required this.startDate, required this.endDate, this.arenaId});
}

class FinanceRefresh extends FinanceEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? arenaId;

  FinanceRefresh({
    required this.startDate,
    required this.endDate,
    this.arenaId,
  });
}

class FinanceSearch extends FinanceEvent {
  final String query;

  FinanceSearch(this.query);
}

class FinanceSort extends FinanceEvent {
  final String sortBy; // 'dateAsc', 'dateDesc', 'amountAsc', 'amountDesc'

  FinanceSort(this.sortBy);
}

class FinanceExportCSV extends FinanceEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? arenaId;

  FinanceExportCSV({
    required this.startDate,
    required this.endDate,
    this.arenaId,
  });
}
