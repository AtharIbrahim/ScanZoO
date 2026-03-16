import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Login Events
class LoginEmailChanged extends AuthEvent {
  final String email;
  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends AuthEvent {
  final String password;
  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted();
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

// Signup Events
class SignupNameChanged extends AuthEvent {
  final String name;
  const SignupNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class SignupEmailChanged extends AuthEvent {
  final String email;
  const SignupEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class SignupPasswordChanged extends AuthEvent {
  final String password;
  const SignupPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class SignupConfirmPasswordChanged extends AuthEvent {
  final String confirmPassword;
  const SignupConfirmPasswordChanged(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class SignupSubmitted extends AuthEvent {
  const SignupSubmitted();
}

// Forgot Password Events
class ForgotPasswordEmailChanged extends AuthEvent {
  final String email;
  const ForgotPasswordEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordSubmitted extends AuthEvent {
  const ForgotPasswordSubmitted();
}
