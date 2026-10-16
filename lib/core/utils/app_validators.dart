class AppValidators {
  AppValidators._();

  static String? required(String? value, {String message = 'Campo requerido'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(
    String? value, {
    String requiredMessage = 'El correo es requerido',
  }) {
    final emptyError = required(value, message: requiredMessage);
    if (emptyError != null) return emptyError;

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value!)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String? customMessage,
    String requiredMessage = 'Campo requerido',
  }) {
    final emptyError = required(value, message: requiredMessage);
    if (emptyError != null) return emptyError;

    if (value!.length < min) {
      return customMessage ?? 'Debe tener al menos $min caracteres';
    }
    return null;
  }

  static String? repeatPassword(String? value, String passwordValue) {
    if (value == null || value.length < 8) {
      return 'La contraseña debe tener mínimo 8 caracteres';
    }

    if (value != passwordValue) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result; // Retorna el primer error que encuentre
      }
    }
    return null;
  }
}
