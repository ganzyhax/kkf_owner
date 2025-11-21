// lib/app/screens/my_arena/bloc/my_arena_state.dart

part of 'my_arena_bloc.dart';

@immutable
sealed class MyArenaState {}

final class MyArenaInitial extends MyArenaState {}

final class MyArenaLoading extends MyArenaState {}

final class MyArenaLoaded extends MyArenaState {
  final List<Map<String, dynamic>> arenas; // ← БЕЗ МОДЕЛЕЙ!
  MyArenaLoaded({required this.arenas});
}

final class MyArenaError extends MyArenaState {
  final String message;
  MyArenaError({required this.message});
}

final class MyArenaSuccess extends MyArenaState {
  final String message;
  MyArenaSuccess({required this.message});
}
