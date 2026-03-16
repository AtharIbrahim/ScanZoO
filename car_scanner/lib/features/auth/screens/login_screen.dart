import 'package:car_scanner/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../bloc/login_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../repositories/auth_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(authRepository: AuthRepository()),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Login failed'),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status.isSuccess) {
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
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentAmber.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Welcome Text
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textLight.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Email Field
                  const _EmailInput(),
                  const SizedBox(height: AppSpacing.md),

                  // Password Field
                  const _PasswordInput(),
                  const SizedBox(height: AppSpacing.md),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/forgot-password');
                      },
                      child: Text(
                        'Forgot password?',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textLight.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Login Button
                  const _LoginButton(),
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

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textLight.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signup');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign Up',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.accentAmber,
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

class _EmailInput extends StatelessWidget {
  const _EmailInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          onChanged: (email) {
            context.read<LoginBloc>().add(LoginEmailChanged(email));
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
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          onChanged: (password) {
            context.read<LoginBloc>().add(LoginPasswordChanged(password));
          },
          obscureText: _obscureText,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state.isValid && !state.status.isInProgress
              ? () {
                  context.read<LoginBloc>().add(const LoginSubmitted());
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
              : const Text('Login'),
        );
      },
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return OutlinedButton.icon(
          onPressed: !state.status.isInProgress
              ? () {
                  context.read<LoginBloc>().add(const GoogleSignInRequested());
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
