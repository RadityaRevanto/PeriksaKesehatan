import 'package:equatable/equatable.dart';

/// Base class untuk semua education events
abstract class EducationEvent extends Equatable {
  const EducationEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk fetch semua kategori dan video edukasi
class FetchEducationalVideosEvent extends EducationEvent {
  const FetchEducationalVideosEvent();
}

/// Event untuk fetch video berdasarkan kategori
class FetchEducationalVideosByCategoryEvent extends EducationEvent {
  final int categoryId;

  const FetchEducationalVideosByCategoryEvent({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

/// Event untuk reset state
class ResetEducationStateEvent extends EducationEvent {
  const ResetEducationStateEvent();
}
