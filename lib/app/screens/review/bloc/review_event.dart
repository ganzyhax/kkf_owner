part of 'review_bloc.dart';

@immutable
sealed class ReviewEvent {}

final class ReviewLoad extends ReviewEvent {
}