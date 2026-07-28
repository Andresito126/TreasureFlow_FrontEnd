/// Validadores de formulario reutilizables entre pantallas de auth.
/// Puro formato de UI (sin red ni dominio) — pensado para conectarse
/// directamente al `validator:` de un `TextFormField`.
class FormValidators {
  static final _emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final _strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$',
  );

  /// Correo requerido y con formato válido.
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa tu correo';
    if (!_emailRegex.hasMatch(v)) return 'Correo no válido';
    return null;
  }

  /// Solo exige que no esté vacía (login: no se re-valida complejidad).
  static String? requiredPassword(String? value) {
    return (value == null || value.isEmpty) ? 'Ingresa tu contraseña' : null;
  }

  /// Exige longitud mínima, sin complejidad (registro).
  static String? minLengthPassword(String? value, {int minLength = 8}) {
    return (value == null || value.length < minLength)
        ? 'Mínimo $minLength caracteres'
        : null;
  }

  /// Longitud mínima + mayúscula, minúscula y número (cambio/recuperación).
  static String? strongPassword(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    if (!_strongPasswordRegex.hasMatch(v)) {
      return 'Necesita mayúscula, minúscula y número';
    }
    return null;
  }

  /// Igual que [strongPassword] pero como predicado booleano, para
  /// pantallas que validan manualmente en vez de usar un `Form`.
  static bool isStrongPassword(String value) {
    return value.length >= 8 && _strongPasswordRegex.hasMatch(value);
  }
}
