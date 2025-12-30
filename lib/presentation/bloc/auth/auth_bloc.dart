import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:periksa_kesehatan/data/repositories/auth_repository.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_event.dart';
import 'package:periksa_kesehatan/presentation/bloc/auth/auth_state.dart';

/// BLoC untuk mengelola authentication state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  /// Handle login event
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.login(
        identifier: event.identifier,
        password: event.password,
      );

      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(
          AuthAuthenticated(
            userId: user.id,
            email: user.email,
            name: user.name,
          ),
        ),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle register event
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );

      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(
          AuthAuthenticated(
            userId: user.id,
            email: user.email,
            name: user.name,
          ),
        ),
      );
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle logout event
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle check auth status event
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(
          AuthAuthenticated(
            userId: user.id,
            email: user.email,
            name: user.name,
          ),
        );
      } else {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}

