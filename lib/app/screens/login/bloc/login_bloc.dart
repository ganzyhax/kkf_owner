import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:kff_owner_admin/app/utils/local_utils.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    bool isLoading = false;
    on<LoginEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is LoginLoad) {
        emit(LoginLoaded(isLoading: isLoading));
      }
      if (event is LoginLog) {
        isLoading = true;
        emit(LoginLoaded(isLoading: isLoading));
        var res = await ApiClient.post('api/auth/login', {
          'email': event.login,
          'password': event.password,
          'role': 'Owner',
        });
        log(res.toString());
        if (res['success']) {
          await LocalUtils.setAccessToken(res['data']['accessToken']);
          emit(LoginSuccess());
          isLoading = false;
          emit(LoginLoaded(isLoading: isLoading));
        } else {
          emit(LoginError(message: res['message'] ?? 'Something went wrong'));
          isLoading = false;
          emit(LoginLoaded(isLoading: isLoading));
        }
      }
    });
  }
}
