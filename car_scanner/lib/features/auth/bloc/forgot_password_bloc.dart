import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../models/email.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordBloc extends Bloc<AuthEvent, ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
      ForgotPasswordEmailChanged event, Emitter<ForgotPasswordState> emit) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      email: email,
      isValid: Formz.validate([email]),
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitted(
      ForgotPasswordSubmitted event, Emitter<ForgotPasswordState> emit) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      await _authRepository.sendPasswordResetEmail(
        email: state.email.value,
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
        errorMessage: 'Failed to send reset email. Please try again.',
      ));
    }
  }
}
