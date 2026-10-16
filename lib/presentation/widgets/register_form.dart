import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/utils/app_validators.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function({
    required String email,
    required String name,
    required String lastName,
    required String password,
  })
  onSubmit;
  final VoidCallback onLogin;

  const RegisterForm({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isLoading || !_formKey.currentState!.validate()) return;
    await widget.onSubmit(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      password: _passwordController.text,
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
            height: 50,
            fit: BoxFit.contain,
          ),
          AppText.titleLarge('Registrate'),
          const SizedBox(height: AppSpacing.xl),
          if (widget.errorMessage != null) ...[
            AppBanner.error(title: widget.errorMessage!),
            const SizedBox(height: AppSpacing.md),
          ],
          AppTextField(
            label: 'Nombres',
            hintText: 'juan',
            controller: _nameController,
            validator: (value) =>
                AppValidators.required(value, message: 'Ingresa tu nombre'),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Apellidos',
            hintText: 'Perez',
            controller: _lastNameController,
            validator: (value) =>
                AppValidators.required(value, message: 'Ingresa tu apellido'),
          ),
          const SizedBox(height: AppSpacing.lg),
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
          AppTextField.password(
            controller: _repeatPasswordController,
            label: 'Confirmar contraseña',
            hintText: 'Confirma tu clave',
            validator: (value) =>
                AppValidators.repeatPassword(value, _passwordController.text),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            isFullWidth: true,
            label: 'Crear cuenta',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText.labelLarge('ó'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText.titleMedium('Ya tienes una cuenta ?'),
              const SizedBox(width: AppSpacing.xs),
              InkWell(
                onTap: widget.onLogin,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AppText.titleMedium(
                    'Inicia sesion',
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
