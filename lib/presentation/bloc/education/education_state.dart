import 'package:equatable/equatable.dart';
import 'package:periksa_kesehatan/data/models/education/education_model.dart';

/// Base class untuk semua education states
abstract class EducationState extends Equatable {
  const EducationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EducationInitial extends EducationState {
  const EducationInitial();
}

/// Loading state
class EducationLoading extends EducationState {
  const EducationLoading();
}

/// State ketika data berhasil dimuat
class EducationDataLoaded extends EducationState {
  final List<EducationCategoryModel> categories;

  const EducationDataLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// State ketika data kategori tertentu berhasil dimuat
class EducationCategoryLoaded extends EducationState {
  final EducationCategoryModel category;

  const EducationCategoryLoaded({required this.category});

  @override
  List<Object?> get props => [category];
}

/// State ketika data kosong
class EducationDataEmpty extends EducationState {
  const EducationDataEmpty();
}

/// Error state
class EducationError extends EducationState {
  final String message;

  const EducationError({required this.message});

  @override
  List<Object?> get props => [message];
}
