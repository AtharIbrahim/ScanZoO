import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import '../models/email.dart';
import '../models/password.dart';
import '../models/name.dart';

enum AuthStatus { initial, loading, success, failure }

// Login State
class LoginState extends Equatable {
  final Email email;
  final Password password;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  LoginState copyWith({
    Email? email,
    Password? password,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, status, isValid, errorMessage];
}

// Signup State
class SignupState extends Equatable {
  final Name name;
  final Email email;
  final Password password;
  final Password confirmPassword;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  const SignupState({
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  SignupState copyWith({
    Name? name,
    Email? email,
    Password? password,
    Password? confirmPassword,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return SignupState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [name, email, password, confirmPassword, status, isValid, errorMessage];
}

// Forgot Password State
class ForgotPasswordState extends Equatable {
  final Email email;
  final FormzSubmissionStatus status;
  final bool isValid;
  final String? errorMessage;

  const ForgotPasswordState({
    this.email = const Email.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isValid = false,
    this.errorMessage,
  });

  ForgotPasswordState copyWith({
    Email? email,
    FormzSubmissionStatus? status,
    bool? isValid,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, status, isValid, errorMessage];
}
