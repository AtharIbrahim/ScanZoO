import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../models/email.dart';
import '../models/password.dart';
import '../models/name.dart';
import '../repositories/auth_repository.dart';

class SignupBloc extends Bloc<AuthEvent, SignupState> {
  final AuthRepository _authRepository;

  SignupBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const SignupState()) {
    on<SignupNameChanged>(_onNameChanged);
    on<SignupEmailChanged>(_onEmailChanged);
    on<SignupPasswordChanged>(_onPasswordChanged);
    on<SignupConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<SignupSubmitted>(_onSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignIn);
  }

  void _onNameChanged(SignupNameChanged event, Emitter<SignupState> emit) {
    final name = Name.dirty(event.name);
    emit(state.copyWith(
      name: name,
      isValid: _validateForm(
        name,
        state.email,
        state.password,
        state.confirmPassword,
      ),
      errorMessage: null,
    ));
  }

  void _onEmailChanged(SignupEmailChanged event, Emitter<SignupState> emit) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      email: email,
      isValid: _validateForm(
        state.name,
        email,
        state.password,
        state.confirmPassword,
      ),
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(
      SignupPasswordChanged event, Emitter<SignupState> emit) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
      password: password,
      isValid: _validateForm(
        state.name,
        state.email,
        password,
        state.confirmPassword,
      ),
      errorMessage: null,
    ));
  }

  void _onConfirmPasswordChanged(
      SignupConfirmPasswordChanged event, Emitter<SignupState> emit) {
    final confirmPassword = Password.dirty(event.confirmPassword);
    emit(state.copyWith(
      confirmPassword: confirmPassword,
      isValid: _validateForm(
        state.name,
        state.email,
        state.password,
        confirmPassword,
      ),
      errorMessage: null,
    ));
  }

  bool _validateForm(
    Name name,
    Email email,
    Password password,
    Password confirmPassword,
  ) {
    final isFormValid = Formz.validate([name, email, password, confirmPassword]);
    final passwordsMatch = password.value == confirmPassword.value;
    return isFormValid && passwordsMatch;
  }

  Future<void> _onSubmitted(
      SignupSubmitted event, Emitter<SignupState> emit) async {
    if (!state.isValid) return;

    if (state.password.value != state.confirmPassword.value) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Passwords do not match',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
        name: state.name.value,
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
      GoogleSignInRequested event, Emitter<SignupState> emit) async {
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
