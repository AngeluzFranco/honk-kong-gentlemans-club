class Validators {
  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }
  
  // Validar contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }
  
  // Validar nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    return null;
  }
  
  // Validar campo requerido
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }
  
  // Validar placa
  static String? validateLicensePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La placa es requerida';
    }
    
    if (value.length < 3) {
      return 'La placa debe tener al menos 3 caracteres';
    }
    
    return null;
  }
  
  // Validar año
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'El año es requerido';
    }
    
    final year = int.tryParse(value);
    if (year == null) {
      return 'Ingresa un año válido';
    }
    
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Ingresa un año entre 1900 y ${currentYear + 1}';
    }
    
    return null;
  }
  
  // Validar kilometraje
  static String? validateMileage(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    
    final mileage = double.tryParse(value);
    if (mileage == null) {
      return 'Ingresa un kilometraje válido';
    }
    
    if (mileage < 0) {
      return 'El kilometraje no puede ser negativo';
    }
    
    return null;
  }
  
  // Validar teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Ingresa un teléfono válido';
    }
    
    return null;
  }
}
