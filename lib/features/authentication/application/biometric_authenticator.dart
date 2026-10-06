import 'package:local_auth/local_auth.dart';

enum BiometricAvailability {
  available,
  unavailable,
  notEnrolled,
  temporarilyUnavailable,
}

abstract interface class BiometricAuthenticator {
  Future<BiometricAvailability> availability();
  Future<bool> authenticate();
}

class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  LocalAuthBiometricAuthenticator([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();
  final LocalAuthentication _auth;

  @override
  Future<BiometricAvailability> availability() async {
    try {
      if (!await _auth.canCheckBiometrics || !await _auth.isDeviceSupported()) {
        return BiometricAvailability.unavailable;
      }
      return (await _auth.getAvailableBiometrics()).isEmpty
          ? BiometricAvailability.notEnrolled
          : BiometricAvailability.available;
    } on LocalAuthException {
      return BiometricAvailability.temporarilyUnavailable;
    }
  }

  @override
  Future<bool> authenticate() async {
    if (await availability() != BiometricAvailability.available) {
      return false;
    }
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock your Document Vault BD',
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}
