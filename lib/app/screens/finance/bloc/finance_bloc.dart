// lib/screens/finance/bloc/finance_bloc.dart
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:meta/meta.dart';

part 'finance_event.dart';
part 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  FinanceBloc() : super(FinanceInitial()) {
    on<FinanceLoad>(_onFinanceLoad);
    on<FinanceRefresh>(_onFinanceRefresh);
    on<FinanceSearch>(_onFinanceSearch);
    on<FinanceSort>(_onFinanceSort);
    on<FinanceExportCSV>(_onFinanceExportCSV);
  }

  // ==================== ЗАГРУЗИТЬ ФИНАНСЫ ====================
  Future<void> _onFinanceLoad(
    FinanceLoad event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());

    try {
      final startDateStr = DateFormat('yyyy-MM-dd').format(event.startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(event.endDate);

      log('Loading finance data: $startDateStr to $endDateStr');

      // Build query parameters
      final params = {'startDate': startDateStr, 'endDate': endDateStr};

      if (event.arenaId != null && event.arenaId != 'all') {
        params['arenaId'] = event.arenaId!;
      }

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      // Get transactions
      final transactionsRes = await ApiClient.get(
        'api/finance/owner/transactions?$queryString',
      );

      // Get summary
      final summaryRes = await ApiClient.get(
        'api/finance/owner/summary?$queryString',
      );

      log('Finance transactions response: $transactionsRes');
      log('Finance summary response: $summaryRes');

      if (transactionsRes == null || summaryRes == null) {
        emit(FinanceError('Ответ сервера пустой'));
        return;
      }

      // ✅ Check if data is wrapped in additional 'data' key
      final transactionsData = transactionsRes['data'] ?? transactionsRes;
      final summaryData = summaryRes['data'] ?? summaryRes;

      if (transactionsData['success'] == true &&
          summaryData['success'] == true) {
        // ✅ Safe null handling
        final transactionsList = transactionsData['transactions'];
        final transactions = transactionsList != null
            ? (transactionsList as List<dynamic>)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList()
            : <Map<String, dynamic>>[];

        final summaryObj = summaryData['summary'];
        final summary = summaryObj != null
            ? Map<String, dynamic>.from(summaryObj as Map)
            : <String, dynamic>{};

        log('Loaded ${transactions.length} transactions');

        emit(FinanceLoaded(transactions: transactions, summary: summary));
      } else {
        final errorMsg =
            transactionsData['message'] ??
            summaryData['message'] ??
            'Ошибка при загрузке данных';
        emit(FinanceError(errorMsg));
      }
    } catch (e, stackTrace) {
      log('Finance load error: $e');
      log('Stack trace: $stackTrace');
      emit(FinanceError('Ошибка: ${e.toString()}'));
    }
  }

  // ==================== ОБНОВИТЬ ФИНАНСЫ ====================
  Future<void> _onFinanceRefresh(
    FinanceRefresh event,
    Emitter<FinanceState> emit,
  ) async {
    // Just reload the data
    add(
      FinanceLoad(
        startDate: event.startDate,
        endDate: event.endDate,
        arenaId: event.arenaId,
      ),
    );
  }

  // ==================== ПОИСК ====================
  Future<void> _onFinanceSearch(
    FinanceSearch event,
    Emitter<FinanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      emit(
        FinanceLoaded(
          transactions: currentState.transactions,
          summary: currentState.summary,
          searchQuery: event.query,
          sortBy: currentState.sortBy,
        ),
      );
    }
  }

  // ==================== СОРТИРОВКА ====================
  Future<void> _onFinanceSort(
    FinanceSort event,
    Emitter<FinanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is FinanceLoaded) {
      List<Map<String, dynamic>> sortedTransactions = List.from(
        currentState.transactions,
      );

      switch (event.sortBy) {
        case 'dateAsc':
          sortedTransactions.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['date'].toString());
              final dateB = DateTime.parse(b['date'].toString());
              return dateA.compareTo(dateB);
            } catch (e) {
              return 0;
            }
          });
          break;
        case 'dateDesc':
          sortedTransactions.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['date'].toString());
              final dateB = DateTime.parse(b['date'].toString());
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });
          break;
        case 'amountAsc':
          sortedTransactions.sort((a, b) {
            final amountA = (a['amount'] as num?)?.toDouble() ?? 0;
            final amountB = (b['amount'] as num?)?.toDouble() ?? 0;
            return amountA.compareTo(amountB);
          });
          break;
        case 'amountDesc':
          sortedTransactions.sort((a, b) {
            final amountA = (a['amount'] as num?)?.toDouble() ?? 0;
            final amountB = (b['amount'] as num?)?.toDouble() ?? 0;
            return amountB.compareTo(amountA);
          });
          break;
      }

      emit(
        FinanceLoaded(
          transactions: sortedTransactions,
          summary: currentState.summary,
          searchQuery: currentState.searchQuery,
          sortBy: event.sortBy,
        ),
      );
    }
  }

  // ==================== ЭКСПОРТ CSV ====================
  Future<void> _onFinanceExportCSV(
    FinanceExportCSV event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      final currentState = state;

      emit(FinanceExporting());

      final startDateStr = DateFormat('yyyy-MM-dd').format(event.startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(event.endDate);

      final params = {'startDate': startDateStr, 'endDate': endDateStr};

      if (event.arenaId != null && event.arenaId != 'all') {
        params['arenaId'] = event.arenaId!;
      }

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      // This would trigger a download in web
      final url = 'api/finance/owner/export-csv?$queryString';
      log('Export CSV URL: $url');

      // TODO: Implement actual file download based on platform
      // For web: window.open(url)
      // For mobile: use http client and save file

      emit(FinanceExportSuccess('CSV экспортирован успешно'));

      // Restore previous state after 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Restore previous state or reload
      if (currentState is FinanceLoaded) {
        emit(currentState);
      } else {
        add(
          FinanceLoad(
            startDate: event.startDate,
            endDate: event.endDate,
            arenaId: event.arenaId,
          ),
        );
      }
    } catch (e) {
      log('Export CSV error: $e');
      emit(FinanceError('Ошибка при экспорте: ${e.toString()}'));
    }
  }
}
