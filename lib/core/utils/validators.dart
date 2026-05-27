class Validators {
  static String? required(String? value, String campo) {
    if (value == null || value.trim().isEmpty) return '$campo não pode ser vazio';
    return null;
  }

  static String? minLength(String? value, int min, String campo) {
    if (value == null || value.trim().length < min) {
      return '$campo deve ter ao menos $min caracteres';
    }
    return null;
  }
}
