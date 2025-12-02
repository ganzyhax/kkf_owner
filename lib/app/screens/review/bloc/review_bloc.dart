import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:kff_owner_admin/app/api/api.dart';
import 'package:meta/meta.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc() : super(ReviewInitial()) {
    on<ReviewEvent>((event, emit) async {
      emit(ReviewLoading());
      var res = await ApiClient.get('api/reviews/owner/');
      if (res['success']) {
        log(res.toString());
        emit(ReviewLoaded(data: res['data']));
      } else {
        emit(ReviewLoaded(data: []));
      }
    });
  }
}
