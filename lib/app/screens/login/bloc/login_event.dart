part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

final class LoginLoad extends LoginEvent {}

final class LoginLog extends LoginEvent {
  final String login;
  final String password;
  LoginLog({required this.login, required this.password});
}
