part of 'review_bloc.dart';

@immutable
sealed class ReviewState {}

final class ReviewInitial extends ReviewState {}

final class ReviewLoaded extends ReviewState {
  final data;

  ReviewLoaded({required this.data});
}

final class ReviewLoading extends ReviewState {}

final class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
}
