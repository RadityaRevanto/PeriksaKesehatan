import 'package:equatable/equatable.dart';

/// Base class untuk semua Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk login
class LoginEvent extends AuthEvent {
  final String identifier;
  final String password;

  const LoginEvent({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object?> get props => [identifier, password];
}

/// Event untuk register
class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, password, confirmPassword];
}

/// Event untuk logout
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Event untuk check authentication status
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

