import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    bool isLoading = false;
    on<RegisterEvent>((event, emit) async {
      if (event is RegisterLoad) {
        emit(RegisterLoaded(isLoading: isLoading));
      }
      if (event is RegisterReg) {
        isLoading = true;
        emit(RegisterLoaded(isLoading: isLoading));

        var res = await ApiClient.post('api/auth/register', {
          "email": event.email,
          "phone": event.phone,
          "name": event.username,
          "role": "Owner",
          "password": event.password,
        });
        log(res.toString());
        if (res['success']) {
          isLoading = false;
          emit(RegisterOpenOtpPage(email: event.email));
          emit(RegisterLoaded(isLoading: isLoading));
        } else {
          isLoading = false;
          emit(
            RegisterError(message: res['message'] ?? 'Something went wrong'),
          );
          emit(RegisterLoaded(isLoading: isLoading));
        }
      }
      if (event is RegisterVerifyEmail) {
        var res = await ApiClient.post('api/auth/verify-otp-email', {
          'email': event.email,
          'code': event.otp,
        });
        if (res['success']) {
          isLoading = false;

          emit(RegisterSuccess());
        } else {
          isLoading = false;

          emit(
            RegisterError(message: res['message'] ?? 'Something went wrong'),
          );
          emit(RegisterLoaded(isLoading: isLoading));
        }
      }
      // TODO: implement event handler
    });
  }
}
