import 'package:car_scanner/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../repositories/auth_repository.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupBloc(authRepository: AuthRepository()),
      child: const SignupView(),
    );
  }
}

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Signup failed'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            // Navigate to home after successful signup
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 35,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  Text(
                    'Create Your Account',
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Join us for safer journeys',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textLight.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Name Field
                  const _NameInput(),
                  const SizedBox(height: AppSpacing.md),

                  // Email Field
                  const _EmailInput(),
                  const SizedBox(height: AppSpacing.md),

                  // Password Field
                  const _PasswordInput(),
                  const SizedBox(height: AppSpacing.md),

                  // Confirm Password Field
                  const _ConfirmPasswordInput(),
                  const SizedBox(height: AppSpacing.sm),

                  // Privacy notice
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text(
                      'By signing up, you agree to our Terms of Service and Privacy Policy. Your data is secure and will only be used for emergency contact purposes.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textLight.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Signup Button
                  const _SignupButton(),
                  const SizedBox(height: AppSpacing.lg),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.textLight.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          'OR',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textLight.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.textLight.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Google Sign In Button
                  const _GoogleSignInButton(),
                  const SizedBox(height: AppSpacing.xl),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textLight.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Login',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return TextField(
          onChanged: (name) {
            context.read<SignupBloc>().add(SignupNameChanged(name));
          },
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
            errorText: state.name.displayError != null
                ? 'Please enter your name'
                : null,
          ),
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          onChanged: (email) {
            context.read<SignupBloc>().add(SignupEmailChanged(email));
          },
          keyboardType: TextInputType.emailAddress,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: state.email.displayError != null
                ? 'Please enter a valid email'
                : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput();

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) {
            context.read<SignupBloc>().add(SignupPasswordChanged(password));
          },
          obscureText: _obscureText,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Create a password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            errorText: state.password.displayError != null
                ? 'Password must be at least 6 characters'
                : null,
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatefulWidget {
  const _ConfirmPasswordInput();

  @override
  State<_ConfirmPasswordInput> createState() => _ConfirmPasswordInputState();
}

class _ConfirmPasswordInputState extends State<_ConfirmPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) =>
          previous.confirmPassword != current.confirmPassword ||
          previous.password != current.password,
      builder: (context, state) {
        final passwordsMatch =
            state.password.value == state.confirmPassword.value;
        final showError = state.confirmPassword.value.isNotEmpty && !passwordsMatch;

        return TextField(
          onChanged: (confirmPassword) {
            context
                .read<SignupBloc>()
                .add(SignupConfirmPasswordChanged(confirmPassword));
          },
          obscureText: _obscureText,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            errorText: showError ? 'Passwords do not match' : null,
          ),
        );
      },
    );
  }
}

class _SignupButton extends StatelessWidget {
  const _SignupButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.isValid && !state.status.isInProgress
              ? () {
                  context.read<SignupBloc>().add(const SignupSubmitted());
                }
              : null,
          child: state.status.isInProgress
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textLight,
                    ),
                  ),
                )
              : const Text('Create Account'),
        );
      },
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return OutlinedButton.icon(
          onPressed: !state.status.isInProgress
              ? () {
                  context.read<SignupBloc>().add(const GoogleSignInRequested());
                }
              : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surfaceWhite,
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
          icon: Image.asset(
            'assets/google_logo.png',
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if image not found
              return const Icon(Icons.login, size: 24);
            },
          ),
          label: Text(
            'Continue with Google',
            style: AppTypography.button.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}
