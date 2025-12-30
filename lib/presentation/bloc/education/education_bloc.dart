import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:periksa_kesehatan/core/network/api_exception.dart';
import 'package:periksa_kesehatan/data/repositories/education_repository.dart';
import 'package:periksa_kesehatan/presentation/bloc/education/education_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/education/education_state.dart';

/// BLoC untuk mengelola education data state
class EducationBloc extends Bloc<EducationEvent, EducationState> {
  final EducationRepository _educationRepository;

  EducationBloc({required EducationRepository educationRepository})
      : _educationRepository = educationRepository,
        super(const EducationInitial()) {
    on<FetchEducationalVideosEvent>(_onFetchEducationalVideos);
    on<FetchEducationalVideosByCategoryEvent>(_onFetchEducationalVideosByCategory);
    on<ResetEducationStateEvent>(_onResetEducationState);
  }

  /// Handle fetch all educational videos event
  Future<void> _onFetchEducationalVideos(
    FetchEducationalVideosEvent event,
    Emitter<EducationState> emit,
  ) async {
    emit(const EducationLoading());
    
    try {
      final categories = await _educationRepository.getEducationalVideos();

      if (categories.isEmpty) {
        emit(const EducationDataEmpty());
      } else {
        emit(EducationDataLoaded(categories: categories));
      }
    } on ApiException catch (e) {
      emit(EducationError(message: e.message));
    } catch (e) {
      emit(EducationError(message: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }

  /// Handle fetch educational videos by category event
  Future<void> _onFetchEducationalVideosByCategory(
    FetchEducationalVideosByCategoryEvent event,
    Emitter<EducationState> emit,
  ) async {
    emit(const EducationLoading());
    
    try {
      final category = await _educationRepository.getEducationalVideosByCategory(event.categoryId);
      emit(EducationCategoryLoaded(category: category));
    } on ApiException catch (e) {
      emit(EducationError(message: e.message));
    } catch (e) {
      emit(EducationError(message: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }

  /// Handle reset state event
  void _onResetEducationState(
    ResetEducationStateEvent event,
    Emitter<EducationState> emit,
  ) {
    emit(const EducationInitial());
  }
}
