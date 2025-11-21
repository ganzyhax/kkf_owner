part of 'register_bloc.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoaded extends RegisterState {
  final bool isLoading;
  RegisterLoaded({required this.isLoading});
}

final class RegisterOpenOtpPage extends RegisterState {
  final String email;
  RegisterOpenOtpPage({required this.email});
}

final class RegisterError extends RegisterState {
  final String message;
  RegisterError({required this.message});
}

final class RegisterSuccess extends RegisterState {}
