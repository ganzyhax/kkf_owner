part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

final class RegisterLoad extends RegisterEvent {}

final class RegisterReg extends RegisterEvent {
  final String username;
  final String email;
  final String password;
  final String phone;
  RegisterReg({
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
  });
}

final class RegisterVerifyEmail extends RegisterEvent {
  final String email;
  final String otp;
  RegisterVerifyEmail({required this.email, required this.otp});
}
