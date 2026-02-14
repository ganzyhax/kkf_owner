// lib/app/screens/my_arena/bloc/my_arena_state.dart
part of 'my_arena_bloc.dart';

@immutable
abstract class MyArenaState {}

class MyArenaInitial extends MyArenaState {}

class MyArenaLoading extends MyArenaState {}

class MyArenaLoaded extends MyArenaState {
  final List<Map<String, dynamic>> arenas;

  // ✅ ДОБАВЛЕННЫЕ ПОЛЯ ДЛЯ ВЕРИФИКАЦИИ
  final String? verificationStatus;
  final String? verificationRejectReason;

  MyArenaLoaded({
    required this.arenas,
    this.verificationStatus,
    this.verificationRejectReason,
  });
}

class MyArenaError extends MyArenaState {
  final String message;
  MyArenaError({required this.message});
}

class MyArenaSuccess extends MyArenaState {
  final String message;
  MyArenaSuccess({required this.message});
}
