import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../models/email.dart';
import '../models/password.dart';
import '../repositories/auth_repository.dart';

class LoginBloc extends Bloc<AuthEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignIn);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.password]),
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(
      LoginPasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
      password: password,
      isValid: Formz.validate([state.email, password]),
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> _onGoogleSignIn(
      GoogleSignInRequested event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      await _authRepository.signInWithGoogle();

      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Google sign-in failed. Please try again.',
      ));
    }
  }
}
