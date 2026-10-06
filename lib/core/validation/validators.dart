class Validators {
  const Validators._();
  static String? required(
    String? value, {
    String message = 'This field is required.',
  }) => value == null || value.trim().isEmpty ? message : null;
  static String? sixDigitPin(String? value) {
    if (value == null || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Enter a 6-digit PIN.';
    }
    if (RegExp(r'^(\d)\1{5}$').hasMatch(value) ||
        const {
          '012345',
          '123456',
          '234567',
          '345678',
          '456789',
          '987654',
          '876543',
          '765432',
          '654321',
          '543210',
        }.contains(value)) {
      return 'Choose a less predictable PIN.';
    }
    return null;
  }
}
