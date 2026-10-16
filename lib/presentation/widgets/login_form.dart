import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/utils/app_validators.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function(String email, String password) onSubmit;
  final VoidCallback onRegister;

  const LoginForm({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onRegister,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isLoading || !_formKey.currentState!.validate()) return;
    await widget.onSubmit(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/login_logo.png',
            width: 400,
            height: 150,
            fit: BoxFit.contain,
          ),
          AppText.titleLarge('Bienvenido'),
          const SizedBox(height: AppSpacing.md),
          if (widget.errorMessage != null) ...[
            AppBanner.error(title: widget.errorMessage!),
            const SizedBox(height: AppSpacing.md),
          ],
          AppTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            hintText: 'ejemplo@correo.com',
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) => AppValidators.email(
              value,
              requiredMessage: 'Ingresa tu correo',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField.password(
            controller: _passwordController,
            label: 'Contraseña',
            hintText: 'Ingresa tu clave',
            validator: (value) => AppValidators.minLength(
              value,
              8,
              customMessage: 'La contraseña debe tener mínimo 8 caracteres',
              requiredMessage: 'La contraseña debe tener mínimo 8 caracteres',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            isFullWidth: true,
            label: 'Iniciar Sesion',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          AppText.labelLarge('ó'),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.titleMedium('No tienes una cuenta ?'),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: widget.onRegister,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AppText.titleMedium(
                    'Registrate',
                    color: AppColors.primary700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
